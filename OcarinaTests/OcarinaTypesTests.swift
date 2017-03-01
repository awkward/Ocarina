//
//  OcarinaTypesTests.swift
//  Ocarina
//
//  Created by Rens Verhoeven on 16/02/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import XCTest
@testable import Ocarina
import Kanna

class OcarinaTypesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        OcarinaManager.shared.delegate = self
    }
    
    override func tearDown() {
        super.tearDown()
        
        OcarinaManager.shared.delegate = nil
    }
    
//    public enum URLInformationType: String {
//        
//        case musicSong = "music.song"
//        case musicPlaylist = "music.playlist"
//        case musicAlbum = "music.album"
//        case musicRadioStation = "music.radio_station"
//        case videoMovie = "video.movie"
//        case videoEpisode = "video.episode"
//        case videoTvShow = "video.tv_show"
//        case videoOther = "video.other"
//        case article = "article"
//        case book = "book"
//        case profile = "profile"
//        case website = "website"
//        
//        case fileImage = "file.image"
//        case fileVideo = "file.video"
//        case fileAudio = "file.audio"
//        case fileDocument = "file.document"
//        case fileArchive = "file.archive"
//        case fileOther = "file.other"
//        
//    }
    
//    func testMusicSongType() {
//        let url = URL(string: "")
//    }
    
    func testMusicPlaylistType() {
        self.testTypeOfInformation(for: "http://www.deezer.com/playlist/68020160", expectedType: .musicPlaylist)
    }
    
    func testSpotifyMusicSongType() {
        self.testTypeOfInformation(for: "https://play.spotify.com/track/35uTIuGU2vTSjovoFLzul7?play=true&utm_source=open.spotify.com&utm_medium=open", expectedType: .musicSong)
    }
    
    func testSpotifyMusicAlbumType() {
        self.testTypeOfInformation(for: "https://play.spotify.com/album/5zFkQHvRimPKxjwDwkkeNL?play=true&utm_source=open.spotify.com&utm_medium=open", expectedType: .musicAlbum)
    }
    
    func testSpotifuMusicPlaylistType() {
        self.testTypeOfInformation(for: "https://play.spotify.com/user/thewhitehouse/playlist/3fAriv8eMWELCwbWrhMKy2", expectedType: .musicPlaylist)
    }
    
    func testTypeOfInformation(for urlString: String, expectedType: URLInformationType) {
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
        
        self.waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("Expectation Failed with error: \(error)");
            }
        }
        
    }
    
}

extension OcarinaTypesTests: OcarinaManagerDelegate {
    
    func ocarinaManager(manager: OcarinaManager, doAdditionalParsingForInformation information: URLInformation, HTML: HTMLDocument?) -> URLInformation? {
        let newInformation = information
        
        // Spotify redirects to a browser-not-supported url. So we use the original URL
        if information.originalUrl.host == "play.spotify.com" {
            newInformation.title = "Spotify"
            if information.originalUrl.pathComponents.contains("track") {
                newInformation.type = .musicSong
            } else if information.originalUrl.pathComponents.contains("album") {
                newInformation.type = .musicAlbum
            } else if information.originalUrl.pathComponents.contains("playlist") {
                newInformation.type = .musicPlaylist
            }
        }
        return newInformation
    }
    
}
