//
//  URLInformation.swift
//  Ocarina
//
//  Created by Rens Verhoeven on 15/02/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import UIKit
import AVFoundation
import Kanna

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
    public let originalURL: URL
    
    /// The contents of the og:url tag of the link.
    /// If the Open Graph URL is not present, this will match the original or have the redirect URL if a redirect occured.
    public var url: URL
    
    /// The contents of the og:title tag of the link.
    /// If og:title is not present, there is a fallback to the `<title>` html tag.
    public var title: String?
    
    /// The contents of the og:description tag of the link.
    /// If og:description is not present, there is a fallback to the `<meta type="description">` html tag.
    public var descriptionText: String?
    
    /// An URL to an image that was provided as the og:image tag. 
    /// If no og:image tag is present, it falls back to the `<meta type="thumbnail">` html tag.
    public var imageURL: URL?
    
    /// The possible size of the image from the imageURL property. This size is parsed from the `og:image:width` and `og:image:height`. 
    /// However since the implemenation of some websites doesn't follow the OGP standard, this size might be incorrect.
    public var imageSize: CGSize?
    
    /// An URL to the Favicon image that was provided by the icon link tag. 
    /// Domains may also have a faveicon at `http://DOMAIN.TLD/favicon.ico`. However this property only checks for the tag in the head of a page.
    /// You may still do a HEAD request to see if the icon is avaible at that URL.
    public var faviconURL: URL?
    
    /// An URL to the Apple Touch Icon (Homescreen icon) that was provided by the apple-touch-icon tag.
    /// Domains may also have a icon at `http://DOMAIN.TLD/apple-touch-icon.png`. However this property only checks for the tag in the head of a page.
    /// You may still do a HEAD request to see if the icon is avaible at that URL.
    /// This property ignores additional sizes.
    public var appleTouchIconURL: URL?
    
    /// Twitter card information, if this is available. Can be used as a fallback in case some tags are missing.
    public var twitterCard: TwitterCardInformation?
    
    /// The type of the content behind the URL, this is determented (in order) by the `og:type` tag or mimetype
    public var type: URLInformationType
    
    /// Create a new instance of URLInformation with the given URL and title
    ///
    /// - Parameters:
    ///   - originalURL: The original URL the request was created with
    ///   - url: The URL which the information corrisponds to. This might be an redirected url.
    ///   - html: The html of the page, this is used to search for (head) tags.
    ///   - response: The HTTP response for the page, this includes the status code.
    init?(originalURL: URL, url: URL, html: HTMLDocument?, response: HTTPURLResponse?) {
        self.originalURL = originalURL
        self.url = url
        if let html = html {
            
            if let typeString = html.xpath("//meta[(@property|@name)=\"og:type\"]/@content").first?.text, let type = URLInformationType.type(for: typeString) {
                self.type = type
            } else {
                self.type = .website
            }
            
            if let title = html.xpath("//meta[(@property|@name)=\"og:title\"]/@content").first?.text {
                self.title = title
            } else if let title = html.title {
                self.title = title
            }
            
            if let descriptionText = html.xpath("//meta[@property=\"og:description\"]/@content ").first?.text {
                self.descriptionText = descriptionText
            } else if let descriptionText = html.xpath("//meta[(@property|@name)=\"description\"]/@content").first?.text {
                self.descriptionText = descriptionText
            }

            if var urlString = html.xpath("//meta[(@property|@name)=\"og:url\"]/@content").first?.text {
                urlString = urlString.trimmingCharacters(in: .whitespaces)

                if let url = URL(string: urlString) {
                    self.url = url
                }
            }
            
            if let imageURLString = html.xpath("//meta[(@property|@name)=\"og:image\"]/@content").first?.text {
                self.imageURL = URL(string: imageURLString, relativeTo: url)
            } else if let imageURLString = html.xpath("//meta[(@property|@name)=\"thumbnail\"]/@content").first?.text {
                self.imageURL = URL(string: imageURLString, relativeTo: url)
            }
            
            if let imageWidthString = html.xpath("//meta[(@property|@name)=\"og:image:width\"]/@content").first?.text,
                let imageHeightString = html.xpath("//meta[(@property|@name)=\"og:image:height\"]/@content").first?.text {
                let imageWidth: CGFloat = CGFloat(Float(imageWidthString) ?? 0)
                let imageHeight: CGFloat = CGFloat(Float(imageHeightString) ?? 0)
                if imageWidth > 0 && imageHeight > 0 {
                    self.imageSize = CGSize(width: imageWidth, height: imageHeight)
                }
            }
            
            if let faviconURLString = html.xpath("/html/head/link[@rel=\"shortcut icon\"]/@href").first?.text {
                self.faviconURL = URL(string: faviconURLString, relativeTo: url)
            } else if let faviconURLString = html.xpath("/html/head/link[@rel=\"icon\"]/@href").first?.text {
                self.faviconURL = URL(string: faviconURLString, relativeTo: url)
            }
            
            if let appleTouchIconURLString = html.xpath("/html/head/link[@rel=\"apple-touch-icon\" and not(@sizes)]/@href").first?.text {
                self.appleTouchIconURL = URL(string: appleTouchIconURLString, relativeTo: url)
            } else if let appleTouchIconURLString = html.xpath("/html/head/link[@rel=\"apple-touch-icon\" and @sizes=\"180x180\"]/@href").first?.text {
                self.appleTouchIconURL = URL(string: appleTouchIconURLString, relativeTo: url)
            } else if let appleTouchIconURLString = html.xpath("/html/head/link[@rel=\"apple-touch-icon-precomposed\" and not(@sizes)]/@href").first?.text {
                self.appleTouchIconURL = URL(string: appleTouchIconURLString, relativeTo: url)
            }
            
            self.twitterCard = TwitterCardInformation(html: html)
            
        } else {
            //If the HTML is not available, we only determine the type based on the mime type
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
        guard let originalURL = aDecoder.decodeObject(forKey: "originalURL") as? URL, let url = aDecoder.decodeObject(forKey: "url") as? URL else {
            return nil
        }
        self.originalURL = originalURL
        self.url = url
        self.title = aDecoder.decodeObject(forKey: "title") as? String
        self.descriptionText = aDecoder.decodeObject(forKey: "description") as? String
        self.imageURL = aDecoder.decodeObject(forKey: "imageURL") as? URL
        self.imageSize = aDecoder.decodeCGSize(forKey: "imageSize")
        self.appleTouchIconURL = aDecoder.decodeObject(forKey: "appleTouchIconURL") as? URL
        self.faviconURL = aDecoder.decodeObject(forKey: "faviconURL") as? URL
        self.twitterCard = aDecoder.decodeObject(forKey: "twitterCard") as? TwitterCardInformation
        if let typeString = aDecoder.decodeObject(forKey: "type") as? String {
            self.type = URLInformationType(rawValue: typeString) ?? URLInformationType.website
        } else {
            self.type = URLInformationType.website
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.originalURL, forKey: "originalURL")
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.descriptionText, forKey: "description")
        aCoder.encode(self.imageURL, forKey: "imageURL")
        aCoder.encode(self.imageSize, forKey: "imageSize")
        aCoder.encode(self.appleTouchIconURL, forKey: "appleTouchIconURL")
        aCoder.encode(self.faviconURL, forKey: "faviconURL")
                aCoder.encode(self.twitterCard, forKey: "twitterCard")
        aCoder.encode(self.type.rawValue, forKey: "type")

    }
    
    public static func ==(lhs: URLInformation, rhs: URLInformation) -> Bool {
        return lhs.url == rhs.url
    }
    
}
