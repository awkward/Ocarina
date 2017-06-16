//
//  PrefetcherTests.swift
//  Ocarina
//
//  Created by Rens Verhoeven on 03/04/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import XCTest
@testable import Ocarina

class PrefetcherTests: XCTestCase {

    func testPrefetcher() {
        let urls = ["http://youtube.com", "http://reddit.com", "http://apple.com", "http://twitter.com", "http://awkward.co"].flatMap { (string) -> URL? in
            return URL(string: string)
        }
        
        let expectation = self.expectation(description: "Link prefetcher shouldn't have any errors fetching links")
        _ = OcarinaPrefetcher(urls: urls, manager: nil) { (errors) in
            XCTAssert(errors.count == 0, "There shouldn't be any errors pre-fetching the URls")
            
            if OcarinaManager.shared.cache[urls.first!]?.title?.characters.count ?? 0 > 0 {
                expectation.fulfill()
            } else {
                XCTFail("Information is missing from the cache after pre-fetching")
            }
        }
        
        self.waitForExpectations(timeout: 4) { (error) in
            if let error = error {
                XCTFail("Expectation Failed with error: \(error)");
            }
        }
    }
    
    func testPrefetcherCancel() {
        let urls = ["http://youtube.com", "http://reddit.com/r/nintendo", "http://apple.com", "http://twitter.com", "http://awkward.co"].flatMap { (string) -> URL? in
            return URL(string: string)
        }
        
        let fetcher = OcarinaPrefetcher(urls: urls, manager: nil)
        fetcher.cancel()
    }
    
    func testPrefetcherWithError() {
        let urls = ["http://youtube.com","http://reddit.table.chair", "http://reddit.com", "http://apple.com", "http://twitter.com", "http://awkward.co"].flatMap { (string) -> URL? in
            return URL(string: string)
        }
        
        let expectation = self.expectation(description: "Link prefetcher shouldn't have any errors fetching links")
        _ = OcarinaPrefetcher(urls: urls, manager: nil) { (errors) in
            XCTAssert(errors.count == 1, "There should be one error pre-fetching the URLs")
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 4) { (error) in
            if let error = error {
                XCTFail("Expectation Failed with error: \(error)");
            }
        }
    }
    
}
