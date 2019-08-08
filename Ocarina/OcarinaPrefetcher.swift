//
//  OcarinaPrefetcher.swift
//  Ocarina
//
//  Created by Rens Verhoeven on 26/02/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import Foundation

open class OcarinaPrefetcher: NSObject {

    public typealias OcarinaPrefetcherCompletionHandler = ((_ errors: [Error]) -> Void)
    
    var requests: [OcarinaInformationRequest] = [OcarinaInformationRequest]()
    let manager: OcarinaManager
    let completionHandler: OcarinaPrefetcherCompletionHandler?
    
    var errors: [Error] = [Error]()
    
    public init(urls: [URL], manager: OcarinaManager? = nil, completionHandler: OcarinaPrefetcherCompletionHandler? = nil) {
        self.manager = manager ?? OcarinaManager.shared
        self.completionHandler = completionHandler
        super.init()
        
        let requests = urls.compactMap { (url) -> OcarinaInformationRequest? in
            return self.manager.requestInformation(for: url, completionHandler: { (information, error) in
                self.requestCompleted(error: error)
            })
        }
        self.requests = requests
        self.requestCompleted(error: nil)
    }
    
    func requestCompleted(error: Error?) {
        if let error = error {
            self.errors.append(error)
        }
        let incompleteRequests = self.requests.filter({ (request) -> Bool in
            return !request.hasBeenCompleted
        })
        if incompleteRequests.count <= 0 {
            self.completionHandler?(self.errors)
        }
    }
    
    public func cancel() {
        for request in requests {
            self.manager.cancel(request: request)
        }
    }
    
    
}
