//
//  OcarinaManager.swift
//  Ocarina
//
//  Created by Rens Verhoeven on 15/02/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import Foundation

/// Manages the requests of informations for each URL and makes sure the information is cached.
open class OcarinaManager: NSObject {
    
    /// A shared instance of the OcarinaManager on which methods can be called to fetch information about a URL
    open static let shared: OcarinaManager = OcarinaManager()
    
    /// The cache used for caching URLInformation models
    open let cache: URLInformationCache
    
    /// The requests that are currently in progress
    open var currentRequests: [OcarinaInformationRequest] = [OcarinaInformationRequest]();
    
    /// The delegate for the Ocarina Manager. See OcarinaManagerDelegate
    open var delegate: OcarinaManagerDelegate?
    
    /// The received data per task identifier.
    fileprivate var dataPerTask = [Int: Data]()
    
    /// If the OcarinaManager should cache the URLInformation models
    open var shouldCacheResults = true {
        didSet {
            if !self.shouldCacheResults {
                self.cache.clear()
            }
        }
    }
    
    /// The barrier queue used when accessing dataPerTask.
    let barrierQueue = DispatchQueue(label: "ocarina-barrier-handling-queue")
    
    lazy fileprivate var urlSession: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }()
    
    override public init() {
        self.cache = URLInformationCache()
    }
    
    public init(cache: URLInformationCache) {
        self.cache = cache
    }
    
    /// Schedules a request for the page at the given URL and returns the request
    ///
    /// - Parameters:
    ///   - url: The URL to get the information from
    ///   - completionHandler: A handler called, when the information about the link is found
    /// - Returns: The scheduled request for information about the URL. If nil is returned, the request is either invalid or information is already available and the completionsHandler is directly called
    @discardableResult
    open func requestInformation(for url: URL, completionHandler: @escaping InformationCompletionHandler) -> OcarinaInformationRequest? {
        if self.shouldCacheResults, let result = self.cache[url] {
            DispatchQueue.main.async {
                completionHandler(result, nil)
            }
            return nil
        }
        let existingRequest = self.requests(for: url).first
        
        if let task = existingRequest?.task {
            let request = OcarinaInformationRequest(url: url, task: task, completionHandler: completionHandler)
            self.currentRequests.append(request)
            return request
        } else {
            let downloadTask = self.dataTask(for: url)
            let request = OcarinaInformationRequest(url: url, task: downloadTask, completionHandler: completionHandler)
            self.currentRequests.append(request)
            downloadTask.resume()
            return request
        }
        
    }
    
    /// Creates a new data task for the given URL
    ///
    /// - Parameter url: The URL to create the data task for
    /// - Returns: The data task
    fileprivate func dataTask(for url: URL) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("Ocarinabot", forHTTPHeaderField: "User-agent")
        request.setValue("text/html", forHTTPHeaderField: "Accept")
        return self.urlSession.dataTask(with: request)
    }
    
    /// Returns all the scheduled and in-profress OcarinaInformationRequests corrosponding to the given URL.
    ///
    /// - Parameter url: The url to get the requests for
    /// - Returns: The requests
    open func requests(for url: URL) -> [OcarinaInformationRequest] {
        return self.currentRequests.filter({ (request) -> Bool in
            return request.url == url
        })
    }
    
    /// Returns all the scheduled and in-profress OcarinaInformationRequests corrosponding to the given URL.
    ///
    /// - Parameter url: The url to get the requests for
    /// - Returns: The requests
    fileprivate func requests(for task: URLSessionTask) -> [OcarinaInformationRequest] {
        return self.currentRequests.filter({ (request) -> Bool in
            return request.task == task
        })
    }
    
    /// Cancels a given request. If all requests for the same URL are cancelled, the actual data retrieving is also cancelled
    ///
    /// - Parameter request: The request to cancel. Also see `func cancel()` on OcarinaInformationRequest
    open func cancel(request: OcarinaInformationRequest) {
        let requests = self.requests(for: request.url)
        
        if let index = self.currentRequests.index(of: request) {
            request.completionHandler(nil, nil)
            self.currentRequests.remove(at: index)
            if requests.count == 1 {
                request.task.cancel()
            }
        }
    }
    
    fileprivate func information(for url: URL, originalURL: URL, html: HTMLDocument?, response: HTTPURLResponse?) -> URLInformation? {
        var urlInformation = URLInformation(originalURL: originalURL, url: url, html: html, response: response)
        if let delegate = self.delegate, let information = urlInformation {
            urlInformation = delegate.ocarinaManager(manager: self, doAdditionalParsingForInformation: information, html: nil)
        }
        return urlInformation
    }
    
    
    fileprivate func completeRequestsWithError(_ error: Error, for url: URL) {
        DispatchQueue.main.async {
            let requests = self.requests(for: url)
            for request in requests {
                request.hasBeenCompleted = true
                request.completionHandler(nil, error)
            }
            self.remove(requests: requests)
        }
    }
    
    fileprivate func completeRequestsWithInformation(_ information: URLInformation, for url: URL) {
        DispatchQueue.main.async {
            let requests = self.requests(for: url)
            for request in requests {
                request.hasBeenCompleted = true
                request.completionHandler(information, nil)
                
            }
            self.remove(requests: requests)
        }
    }
    
    fileprivate func remove(requests: [OcarinaInformationRequest]) {
        for request in requests {
            if let index = self.currentRequests.index(of: request) {
                self.currentRequests.remove(at: index)
            }
        }
    }
}

extension OcarinaManager: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let httpResponse = response as? HTTPURLResponse, let mimeType = response.mimeType?.lowercased() {
            if URLInformationType.htmlFileMimeTypes.contains(mimeType) {
                completionHandler(URLSession.ResponseDisposition.allow)
                return
            } else {
                self.taskDidComplete(dataTask, data: nil, error: nil, response: httpResponse)
                completionHandler(URLSession.ResponseDisposition.cancel)
                return
            }
        }
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.barrierQueue.sync {
            if var existingData = self.dataPerTask[dataTask.taskIdentifier] {
                existingData.append(data)
                self.dataPerTask[dataTask.taskIdentifier] = existingData
            } else {
                self.dataPerTask[dataTask.taskIdentifier] = data
            }
        }
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let data = dataPerTask[task.taskIdentifier]
        barrierQueue.sync(flags: .barrier) {
            self.dataPerTask.removeValue(forKey: task.taskIdentifier)
            return
        }
        self.taskDidComplete(task, data: data, error: error, response: task.response as? HTTPURLResponse)
        
    }
    
    fileprivate func taskDidComplete(_ task: URLSessionTask, data: Data?, error: Error?, response: HTTPURLResponse?) {
        guard let originalURL = self.requests(for: task).first?.url else {
            return
        }
        let url = task.currentRequest?.url ?? originalURL
        if let response = response, response.statusCode < 200 && response.statusCode >= 300 {
            //We don't have a valid response, we end it here! If we don't have a response at all, we will just continue
            let newError = NSError(domain: "co.awkward.ocarina", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response receibved from URL"])
            self.completeRequestsWithError(newError, for: originalURL)
            return
        }
        if let error = error, data == nil {
            self.completeRequestsWithError(error, for: originalURL)
            return
        }
        
        var html: HTMLDocument? = nil
        if let data = data {
            html = HTML(html: data, encoding: .utf8)
        }
        
        if let urlInformation = self.information(for: url, originalURL: originalURL, html: html, response: response) {
            self.cache[originalURL] = urlInformation
            self.completeRequestsWithInformation(urlInformation, for: originalURL)
        } else {
            let newError = error ?? NSError(domain: "co.awkward.ocarina", code: 501, userInfo: [NSLocalizedDescriptionKey: "Invalid data received from URL"])
            self.completeRequestsWithError(newError, for: originalURL)
        }
    }
    
}
