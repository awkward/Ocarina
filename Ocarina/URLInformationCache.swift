//
//  URLInformationCache.swift
//  Ocarina
//
//  Created by Rens Verhoeven on 15/02/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import Foundation

/// The cache used by a OrcarinaManager to hold a cache of URLInformation
public class URLInformationCache {
    
    /// The internal NSCache used to cache the URLInformation
    let cache = NSCache<NSURL, URLInformation>()
    
    subscript(url: URL) -> URLInformation? {
        get {
            return self.cache.object(forKey: url as NSURL)
        }
        set {
            guard let information = newValue else {
                self.cache.removeObject(forKey: url as NSURL)
                return
            }
            self.cache.setObject(information, forKey: url as NSURL)
        }
    }
    
    
    /// Clears all the URLInformation models from the cache
    func clear() {
        self.cache.removeAllObjects()
    }
    
}
