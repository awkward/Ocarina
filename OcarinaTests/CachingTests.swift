//
//  CachingTests.swift
//  Ocarina
//
//  Created by Rens Verhoeven on 03/04/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import XCTest
@testable import Ocarina

class CachingTests: XCTestCase {
    
    func testGettingFromCache() {
        guard let url = URL(string: "https://www.reddit.com") else {
            XCTFail("Invalid URL")
            return
        }
        
        let expectation = self.expectation(description: "After getting a link once, information should be available in the cache.")
        url.oca.fetchInformation { (information, error) in
            XCTAssertNil(error, "An error occured fetching the information")
            XCTAssertNotNil(information, "Information is missing")
            
            XCTAssert(information?.title?.characters.count ?? 0 > 0, "The article should have a title of at least 1 character.")
            
            if OcarinaManager.shared.cache[url]?.title?.characters.count ?? 0 > 0 {
                expectation.fulfill()
            } else {
                XCTFail("Information should be in the cache.")
            }
        }
        
        self.waitForExpectations(timeout: 4) { (error) in
            if let error = error {
                XCTFail("Expectation Failed with error: \(error)");
            }
        }
    }
    
    func testSecondRequest() {
        guard let url = URL(string: "https://www.reddit.com") else {
            XCTFail("Invalid URL")
            return
        }
        
        let expectation = self.expectation(description: "After getting a link once, the next requests should also return data.")
        url.oca.fetchInformation { (information, error) in
            url.oca.fetchInformation { (information, error) in
                XCTAssertNil(error, "An error occured fetching the information")
                XCTAssertNotNil(information, "Information is missing")
                
                XCTAssert(information?.title?.characters.count ?? 0 > 0, "The article should have a title of at least 1 character.")
                
                if OcarinaManager.shared.cache[url]?.title?.characters.count ?? 0 > 0 {
                    expectation.fulfill()
                } else {
                    XCTFail("Information should be in the cache.")
                }
            }
        }
        
        self.waitForExpectations(timeout: 4) { (error) in
            if let error = error {
                XCTFail("Expectation Failed with error: \(error)");
            }
        }
    }
    
    func testRemovingFromCache() {
        guard let url = URL(string: "https://www.reddit.com/r/worldnews") else {
            XCTFail("Invalid URL")
            return
        }
        
        let expectation = self.expectation(description: "After getting a link once, information should be available in the cache.")
        url.oca.fetchInformation { (information, error) in
            XCTAssertNil(error, "An error occured fetching the information")
            XCTAssertNotNil(information, "Information is missing")
            
            XCTAssert(information?.title?.characters.count ?? 0 > 0, "The article should have a title of at least 1 character.")
            
            if OcarinaManager.shared.cache[url]?.title?.characters.count ?? 0 > 0 {
                OcarinaManager.shared.cache[url] = nil
                if OcarinaManager.shared.cache[url] == nil {
                    expectation.fulfill()
                } else {
                    XCTFail("Information should not be in the cache after removing.")
                }
            } else {
                XCTFail("Information should be in the cache.")
            }
        }
        
        self.waitForExpectations(timeout: 4) { (error) in
            if let error = error {
                XCTFail("Expectation Failed with error: \(error)");
            }
        }
    }
    
    func testClearingCache() {
        guard let url = URL(string: "https://www.reddit.com/r/zelda") else {
            XCTFail("Invalid URL")
            return
        }
        
        let expectation = self.expectation(description: "After getting a link once, information should be available in the cache.")
        url.oca.fetchInformation { (information, error) in
            XCTAssertNil(error, "An error occured fetching the information")
            XCTAssertNotNil(information, "Information is missing")
            
            XCTAssert(information?.title?.characters.count ?? 0 > 0, "The article should have a title of at least 1 character.")
            
            if OcarinaManager.shared.cache[url]?.title?.characters.count ?? 0 > 0 {
                OcarinaManager.shared.cache.clear()
                
                if OcarinaManager.shared.cache[url] == nil {
                    expectation.fulfill()
                } else {
                    XCTFail("Information should not be in the cache after clearing the cache.")
                }
            } else {
                XCTFail("Information should be in the cache.")
            }
        }
        
        self.waitForExpectations(timeout: 4) { (error) in
            if let error = error {
                XCTFail("Expectation Failed with error: \(error)");
            }
        }
    }
    


}
