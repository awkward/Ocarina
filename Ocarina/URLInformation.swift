//
//  URLInformation.swift
//  Ocarina
//
//  Created by Rens Verhoeven on 15/02/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import Foundation
import AVFoundation

public enum URLInformationType: String {
    
    static let imageFileMimeTypes: [String] = ["image/bmp",
                                               "image/x-windows-bmp",
                                               "image/gif", "image/jpeg",
                                               "image/pjpeg",
                                               "image/x-icon",
                                               "image/png",
                                               "image/tiff",
                                               "image/x-tiff"]
    
    static let documentFileMimeTypes: [String] = ["application/vnd.ms-powerpoint",
                                                  "application/mspowerpoint",
                                                  "application/mspowerpoint",
                                                  "application/x-mspowerpoint",
                                                  "application/msword",
                                                  "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                                                  "application/vnd.openxmlformats-officedocument.wordprocessingml.template",
                                                  "application/vnd.ms-excel.addin.macroEnabled.12",
                                                  "application/vnd.ms-excel",
                                                  "application/vnd.ms-excel.sheet.binary.macroEnabled.12",
                                                  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                                                  "application/vnd.openxmlformats-officedocument.spreadsheetml.template",
                                                  "text/plain",
                                                  "application/rtf",
                                                  "application/x-rtf",
                                                  "text/richtext",
                                                  "application/pdf"]
    
    static let htmlFileMimeTypes: [String] =  ["text/html",
                                               "text/x-server-parsed-html"]
    
    static let archiveFileMimeTypes: [String] = ["application/x-compress",
                                                 "application/x-compressed",
                                                 "application/x-zip-compressed",
                                                 "application/zip",
                                                 "multipart/x-zip"]

    case music = "music"
    case musicSong = "music.song"
    case musicPlaylist = "music.playlist"
    case musicAlbum = "music.album"
    case musicRadioStation = "music.radio_station"
    
    case videoMovie = "video.movie"
    case videoEpisode = "video.episode"
    case videoTvShow = "video.tv_show"
    case video = "video"
    case article = "article"
    case book = "book"
    case profile = "profile"
    case website = "website"
    
    case fileImage = "file.image"
    case fileVideo = "file.video"
    case fileAudio = "file.audio"
    case fileDocument = "file.document"
    case fileArchive = "file.archive"
    case fileOther = "file.other"
    
    var isFileURL: Bool {
        return self.rawValue.hasPrefix("file")
    }
    
    static func type(for typeString: String) -> URLInformationType? {
        if let type = URLInformationType(rawValue: typeString) {
            return type
        }
        switch typeString {
        case "music.other":
            return .music
        case "music.track", "song", "track":
            return .musicSong
        case "playlist":
            return .musicPlaylist
        case "album", "record":
            return .musicAlbum
        case "radio_station", "radio":
            return .musicRadioStation
        case "video.other":
            return .video
        case "movie", "film":
            return .videoMovie
        case "episode":
            return .videoEpisode
        case "tv_show", "tv_series":
            return .videoTvShow
        default:
            return nil
        }
    }
    
    static func type(forMimeType mimeType: String) -> URLInformationType {
        let audioFileMimeTypes = AVURLAsset.audiovisualMIMETypes().filter({ (type) -> Bool in
            return type.hasPrefix("audio/")
        })

        if AVURLAsset.audiovisualMIMETypes().contains(mimeType) && !mimeType.hasPrefix("text/") {
            //We have an audio or video URL!
            
            if audioFileMimeTypes.contains(mimeType) {
                return URLInformationType.fileAudio
            } else {
                return URLInformationType.fileVideo
            }
        } else if self.imageFileMimeTypes.contains(mimeType) {
            return URLInformationType.fileImage
        } else if self.documentFileMimeTypes.contains(mimeType) {
            return URLInformationType.fileDocument
        } else if self.htmlFileMimeTypes.contains(mimeType) {
            return URLInformationType.website
        } else if self.archiveFileMimeTypes.contains(mimeType) {
            return URLInformationType.fileArchive
        }
        return URLInformationType.fileOther
    }
    
}

/// A model containing information about a URL
public class URLInformation: NSCoding, Equatable {
    
    /// The original URL the information was requested for.
    public let originalUrl: URL
    
    /// The contents of the og:url tag of the link.
    /// If the Open Graph URL is not present, this will match the original or have the redirect URL if a redirect occured.
    public let url: URL
    
    /// The contents of the og:title tag of the link.
    /// If og:title is not present, there is a fallback to the `<title>` html tag.
    public var title: String?
    
    /// The contents of the og:title tag of the link.
    /// If og:title is not present, there is a fallback to the `<meta type="description">` html tag.
    public var descriptionText: String?
    
    /// An URL to an image that was provided as the og:image tag.
    /// If og:image is not present, it will fallback to the "apple touch icon" if present.
    public var imageUrl: URL?
    
    /// The type of the content behind the URL, this is determented (in order) by the `og:type` tag or mimetype
    public var type: URLInformationType
    
    /// Create a new instance of URLInformation with the given URL and title
    ///
    /// - Parameters:
    ///   - url: The URL which the information corrisponds to
    ///   - title: The title of the page or article
    init(originalUrl: URL, url: URL, title: String?) {
        self.originalUrl = originalUrl
        self.url = url
        self.title = title
        self.descriptionText = nil
        self.type = .website
    }
    
    init?(originalUrl: URL, url: URL, html: HTMLDocument?, response: HTTPURLResponse?) {
        self.originalUrl = originalUrl
        self.url = url
        if let html = html {
            
            if let typeString = html.xpath("/html/head/meta[(@property|@name)=\"og:type\"]/@content").first?.text, let type = URLInformationType.type(for: typeString) {
                self.type = type
            } else {
                self.type = .website
            }
            
            if let title = html.xpath("/html/head/meta[(@property|@name)=\"og:title\"]/@content").first?.text {
                self.title = title
            } else if let title = html.title {
                self.title = title
            } else {
                self.title = nil
            }
            
            if let descriptionText = html.xpath("/html/head/meta[(@property|@name)=\"og:description\"]/@content").first?.text {
                self.descriptionText = descriptionText
            } else if let descriptionText = html.xpath("/html/head/meta[(@property|@name)=\"description\"]/@content").first?.text {
                self.descriptionText = descriptionText
            } else {
                self.descriptionText = nil
            }
            
            if let imageUrlString = html.xpath("/html/head/meta[(@property|@name)=\"og:image\"]/@content").first?.text {
                if let imageUrl = URL(string: imageUrlString), url.host != nil && url.scheme != nil {
                    self.imageUrl = imageUrl
                } else {
                    self.imageUrl = URL(string: imageUrlString, relativeTo: url)
                }
            } else if let imageUrlString = html.xpath("/html/head/link[@rel=\"apple-touch-icon\"]/@content").first?.text {
                if let imageUrl = URL(string: imageUrlString), url.host != nil && url.scheme != nil {
                    self.imageUrl = imageUrl
                } else {
                    self.imageUrl = URL(string: imageUrlString, relativeTo: url)
                }
            } else {
                self.imageUrl = nil
            }
            
        } else {
            //If the HTML is not available, we only determine the type based on the extension of mime type
            if let mimeType = response?.mimeType {
                self.type = URLInformationType.type(forMimeType: mimeType)
            } else {
                self.type = .website
            }
            self.title = nil
            self.descriptionText = nil
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let originalUrl = aDecoder.decodeObject(forKey: "originalUrl") as? URL, let url = aDecoder.decodeObject(forKey: "url") as? URL else {
            return nil
        }
        self.originalUrl = originalUrl
        self.url = url
        self.title = aDecoder.decodeObject(forKey: "title") as? String
        self.descriptionText = aDecoder.decodeObject(forKey: "description") as? String
        if let typeString = aDecoder.decodeObject(forKey: "type") as? String {
            self.type = URLInformationType(rawValue: typeString) ?? URLInformationType.website
        } else {
            self.type = URLInformationType.website
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.originalUrl, forKey: "originalUrl")
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.descriptionText, forKey: "descriptiom")
    }
    
    public static func ==(lhs: URLInformation, rhs: URLInformation) -> Bool {
        return lhs.url == rhs.url
    }
    
}
