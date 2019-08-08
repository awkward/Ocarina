//
//  URL+URLInformation.swift
//  Ocarina
//
//  Created by Rens Verhoeven on 15/02/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import Foundation

/// The ocarine object that is a property on URL for easy access
public final class Ocarina {
    public let url: URL
    public init(_ url: URL) {
        self.url = url
    }
}

extension URL {
    
    
    /// The Ocarina object for this URL. Can be used to request information for this URL
    public var oca: Ocarina {
        return Ocarina(self)
    }
}


public extension Ocarina {
    
    
    /// Fetches information about the given URL
    ///
    /// - Parameter completionHandler: Called when the data is retreived or the request has been cancelled
    /// - Returns: The request that is sheduled to be performed. Or nil if the request is invalid or already has cached data
    @discardableResult
    func fetchInformation(completionHandler: @escaping InformationCompletionHandler) -> OcarinaInformationRequest? {
        return OcarinaManager.shared.requestInformation(for: self.url, completionHandler: completionHandler)
    }
    
}
