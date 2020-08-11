//
//  InformationFetchingTests.swift
//  Ocarina
//
//  Created by Rens Verhoeven on 03/04/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import XCTest
@testable import Ocarina

class InformationFetchingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    
    }
    
    override func tearDown() {
        super.tearDown()
        
       OcarinaManager.shared.userAgent = nil
        OcarinaManager.shared.cache.clear()
    }
    
    /// Tests an URL that supports Open Graph Data.
    func testInformationFetchingWithOGP() {
        guard let url = URL(string: "https://www.nytimes.com/interactive/2017/04/02/technology/uber-drivers-psychological-tricks.html") else {
            XCTFail("Invalid URL")
            return
        }
        
        let expectation = self.expectation(description: "The new york times article should have some basic information.")
        url.oca.fetchInformation { (information, error) in
            XCTAssertNil(error, "An error occured fetching the information")
            XCTAssertNotNil(information, "Information is missing")
            
            XCTAssert(information?.type == .article, "The link should be of type article.")
            XCTAssert(information?.title?.count ?? 0 > 0, "The article should have a title of at least 1 character.")
            XCTAssert(information?.descriptionText?.count ?? 0 > 0, "The article should have a description of at least 1 character.")
            XCTAssert(information?.imageURL != nil, "The article should have an image.")
            XCTAssert(information?.faviconURL != nil, "The link should have a favicon.")
            XCTAssert(information?.appleTouchIconURL != nil, "The link should have a apple touch icon.")
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 4) { (error) in
            if let error = error {
                XCTFail("Expectation Failed with error: \(error)");
            }
        }
    }
    
    /// Tests an URL that doesn't have OGP data, but does has the default title and description.
    func testInformationFetchingWithoutOGP() {
        guard let url = URL(string: "https://www.reddit.com") else {
            XCTFail("Invalid URL")
            return
        }
        
        // Reddit doesn't accept a user agent with "bot" in the name, if it gets one it doesn't include "og:" elements.
        OcarinaManager.shared.userAgent = "xctest"
        
        let expectation = self.expectation(description: "This link should have basic information but, not from OGP")
        url.oca.fetchInformation { (information, error) in
            XCTAssertNil(error, "An error occured fetching the information")
            XCTAssertNotNil(information, "Information is missing")
            
            XCTAssert(information?.type == .website, "The link should be of type website.")
            XCTAssert(information?.title?.count ?? 0 > 0, "The article should have a title of at least 1 character.")
            XCTAssert(information?.descriptionText?.count ?? 0 > 0, "The article should have a description of at least 1 character.")
            XCTAssert(information?.imageURL != nil, "The link should have an image.")
            XCTAssert(information?.faviconURL != nil, "The link should have a favicon.")
            XCTAssert(information?.appleTouchIconURL != nil, "The link should have a apple touch icon.")
            
            expectation.fulfill()
            
        }
        
        self.waitForExpectations(timeout: 4) { (error) in
            if let error = error {
                XCTFail("Expectation Failed with error: \(error)");
            }
        }
    }
    
    /// Tests the fetching of information for a file. This should only give a type of no custom parsing is given.
    func testFileInformationFetching() {
        guard let url = URL(string: "https://www.nintendo.com/consumer/downloads/WiiOpMn_setup.pdf") else {
            XCTFail("Invalid URL")
            return
        }
        
        let expectation = self.expectation(description: "The file should have a file URL and be of type file.")
        url.oca.fetchInformation { (information, error) in
            XCTAssertNil(error, "An error occured fetching the information")
            XCTAssertNotNil(information, "Information is missing")
            
            XCTAssert(information?.type == .fileDocument, "The link should be of type file document.")
            XCTAssert(information?.type.isFileURL == true, "The information type should be a file URL")
            
            expectation.fulfill()
            
        }
        
        self.waitForExpectations(timeout: 4) { (error) in
            if let error = error {
                XCTFail("Expectation Failed with error: \(error)");
            }
        }
    }
    
    /// Tests the cancelling of a request for a URL.
    func testCancelingInformationRequest() {
        guard let url = URL(string: "https://www.awkward.co") else {
            XCTFail("Invalid URL")
            return
        }
        
        let expectation = self.expectation(description: "The request should immediately be cancelled")
        let request = url.oca.fetchInformation { (information, error) in
            XCTAssert(information == nil, "A cancelled request shouldn't have information.")
            XCTAssert(error == nil, "A cancelled request shouldn't have an error.")
            
            expectation.fulfill()
        }
        request?.cancel()
        
        self.waitForExpectations(timeout: 4) { (error) in
            if let error = error {
                XCTFail("Expectation Failed with error: \(error)");
            }
        }
    }
    
    /// Tests an URL that doesn't exist, because the TLD doesn't exist.
    func testErroringInformationRequest() {
        guard let url = URL(string: "https://www.awkward.tablechairchees") else {
            XCTFail("Invalid URL")
            return
        }
        
        let expectation = self.expectation(description: "The request should end in a error because the TLD doesn't exist.")
        url.oca.fetchInformation { (information, error) in
            XCTAssert(information == nil, "The request shouldn't have information.")
            XCTAssert(error != nil, "The request should have an error.")
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 4) { (error) in
            if let error = error {
                XCTFail("Expectation Failed with error: \(error)");
            }
        }
    }

}
