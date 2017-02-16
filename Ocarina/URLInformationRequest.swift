//
//  URLInformationRequest.swift
//  Ocarina
//
//  Created by Rens Verhoeven on 15/02/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import Foundation

/// A request for information of a certain URL
public class URLInformationRequest: Equatable {
    
    /// The URL this request is requesting information for
    public var url: URL
    
    /// The task that is requesting the actual page
    let task: URLSessionTask
    
    /// The completion handler, called when the request is cancelled or finished
    let completionHandler: InformationCompletionHandler
    
    //TODO: Return optional, use URL from task
    init(url: URL, task: URLSessionTask, completionHandler: @escaping InformationCompletionHandler) {
        self.url = url
        self.task = task
        self.completionHandler = completionHandler
    }
    
    /// Cancels the request for information. Only works when the shared OcarinaManager is used.
    /// For custom istances of the OcarinaManager, use `func cancel(request:)`
    public func cancel() {
        OcarinaManager.shared.cancel(request: self)
    }
    
    
    public static func ==(lhs: URLInformationRequest, rhs: URLInformationRequest) -> Bool {
        return lhs.url == rhs.url
    }
}
