//
//  AdditionalParsingTests.swift
//  Ocarina
//
//  Created by Rens Verhoeven on 16/02/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import XCTest
@testable import Ocarina

/// This test checks if addtional parsing using the delegate works.
/// In the example we use Spotify which doesn't have any public OGP tags, so we determine the type based on the URL.
class AdditionalParsingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        OcarinaManager.shared.delegate = self
    }
    
    override func tearDown() {
        super.tearDown()
        
        OcarinaManager.shared.delegate = nil
        OcarinaManager.shared.cache.clear()
    }
    
// This test has been disabled for now. Deezer now shows a login page before showing the playlist, so the type is incorrect.
//    func testMusicPlaylistType() {
//        self.testTypeOfInformation(for: "http://www.deezer.com/playlist/68020160", expectedType: .musicPlaylist)
//    }
    
    func testSpotifyMusicSongType() {
        self.testTypeOfInformation(for: "https://play.spotify.com/track/35uTIuGU2vTSjovoFLzul7?play=true&utm_source=open.spotify.com&utm_medium=open", expectedType: .musicSong)
    }
    
    func testSpotifyMusicAlbumType() {
        self.testTypeOfInformation(for: "https://play.spotify.com/album/5zFkQHvRimPKxjwDwkkeNL?play=true&utm_source=open.spotify.com&utm_medium=open", expectedType: .musicAlbum)
    }
    
    func testSpotifuMusicPlaylistType() {
        self.testTypeOfInformation(for: "https://play.spotify.com/user/thewhitehouse/playlist/3fAriv8eMWELCwbWrhMKy2", expectedType: .musicPlaylist)
    }
    
    fileprivate func testTypeOfInformation(for urlString: String, expectedType: URLInformationType) {
        guard let url = URL(string: urlString) else {
            XCTAssert(false, "The given URLString is invalid")
            return
        }
        
        let expectation = self.expectation(description: "Information type is correct")
        url.oca.fetchInformation { (information, error) in
            XCTAssertNil(error, "An error occured fetching the information")
            XCTAssertNotNil(information, "Information is missing")
            if information?.type == expectedType {
                expectation.fulfill()
            } else {
                XCTFail("Information type does not match expected type")
            }
        }
        
        self.waitForExpectations(timeout: 4) { (error) in
            if let error = error {
                XCTFail("Expectation Failed with error: \(error)");
            }
        }
        
    }
    
}

extension AdditionalParsingTests: OcarinaManagerDelegate {
    
    func ocarinaManager(manager: OcarinaManager, doAdditionalParsingForInformation information: URLInformation, html: HTMLDocument?) -> URLInformation? {
        let newInformation = information
        
        // Spotify redirects to a browser-not-supported url. So we use the original URL
        if information.originalURL.host == "play.spotify.com" {
            newInformation.title = "Spotify"
            if information.originalURL.pathComponents.contains("track") {
                newInformation.type = .musicSong
            } else if information.originalURL.pathComponents.contains("album") {
                newInformation.type = .musicAlbum
            } else if information.originalURL.pathComponents.contains("playlist") {
                newInformation.type = .musicPlaylist
            }
        }
        return newInformation
    }
    
}
