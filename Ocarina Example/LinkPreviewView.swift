//
//  LinkPreviewView.swift
//  Beam
//
//  Created by Rens Verhoeven on 09/02/2017.
//  Copyright © 2017 Awkward. All rights reserved.
//

import UIKit
import Ocarina

@IBDesignable
class LinkPreviewView: UIControl {
    
    fileprivate var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.isOpaque = true
        imageView.clipsToBounds = true
        return imageView
    }()
    fileprivate var loadingPlaceholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.scaleToFill
        imageView.isOpaque = true
        imageView.clipsToBounds = true
        //imageView.image = #imageLiteral(resourceName: "empty_link_placeholder")
        return imageView
    }()
    
    fileprivate var titleLabel: UILabel = {
        let label = UILabel()
        label.font = LinkPreviewView.titleFont
        label.isOpaque = true
        label.numberOfLines = 2
        return label
    }()
    fileprivate var domainLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.isOpaque = true
        label.numberOfLines = 1
        return label
    }()
    
    fileprivate var link: URL?
    
    fileprivate var isLoading: Bool = false {
        didSet {
            self.loadingPlaceholderImageView.isHidden = !self.isLoading
            self.titleLabel.isHidden = self.isLoading
            self.domainLabel.isHidden = self.isLoading
        }
    }
    
    fileprivate var information: URLInformation? {
        didSet {
            self.reloadContents()
            self.displayModeDidChange()
            self.setNeedsLayout()
        }
    }
    
    fileprivate var request: OcarinaInformationRequest?
    fileprivate var imageTask: URLSessionTask?
    
    //Generating the UIFont everytime displayModeDidChange is called seems to cause some CPU time so that's why I'm saving it.
    fileprivate static let titleFont = UIFont.systemFont(ofSize: 12, weight: UIFontWeightMedium)
    fileprivate static let subtitleFont = UIFont.systemFont(ofSize: 12)
    
    fileprivate var attributedTitle: NSAttributedString? {
        let titleAttributes = [NSFontAttributeName: LinkPreviewView.titleFont, NSForegroundColorAttributeName:  UIColor.black]
        let descriptionAttributes = [NSFontAttributeName: LinkPreviewView.subtitleFont, NSForegroundColorAttributeName: UIColor(red:0.58, green:0.58, blue:0.58, alpha:1)]
        
        let string = NSMutableAttributedString()
        if let information = self.information {
            let hasTitle = information.title?.characters.count ?? 0 > 0
            let hasDescription = information.descriptionText?.characters.count ?? 0 > 0
            
            if hasTitle, let title = information.title {
                string.append(NSAttributedString(string: title, attributes: titleAttributes))
            }
            
            if hasTitle && hasDescription {
                string.append(NSAttributedString(string: " - ", attributes: descriptionAttributes))
            }
            
            if hasDescription, let description = information.descriptionText {
                string.append(NSAttributedString(string: description, attributes: descriptionAttributes))
            }
        } else {
            if let urlString = self.link?.absoluteString {
                string.append(NSAttributedString(string: urlString, attributes: descriptionAttributes))
            }
        }
        
        return string
    }
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupView()
    }
    
    fileprivate func setupView() {
        self.isOpaque = true
        
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.5
        
        self.addSubview(self.previewImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.domainLabel)
        self.addSubview(self.loadingPlaceholderImageView)
        
        self.previewImageView.isHidden = true
        self.titleLabel.isHidden = true
        self.domainLabel.isHidden = true
    }
    
    func changeLink(link: URL?) {
        guard self.link != link else {
            return
        }
        self.cancelAllRequests()
        self.information = nil
        self.isLoading = true
        
        self.link = link
        
        if let link = link, let cachedInformation = OcarinaManager.shared.cache[link] {
            self.information = cachedInformation
            self.doneLoading(animated: false)
        } else {
            self.reloadDomainName()
            self.startFetchingMetadata()
        }
        
        self.setNeedsLayout()
    }
    
    fileprivate func reloadContents() {
        self.previewImageView.isHidden = self.information?.imageURL == nil
        self.previewImageView.image = nil
        
        self.reloadDomainName()
        
        self.setNeedsLayout()
        
        if let imageURL = self.information?.imageURL {
            self.imageTask = URLSession.shared.downloadTask(with: imageURL, completionHandler: { (fileURL, reponse, error) in
                if let fileURL = fileURL {
                    let image = UIImage(contentsOfFile: fileURL.path)
                    DispatchQueue.main.async {
                        if self.previewImageView.alpha == 0 {
                            self.doneLoading(animated: true)
                        }
                        self.previewImageView.image = image
                    }
                    
                }
            })
            self.imageTask?.resume()
            self.updateConstraints()
            self.setNeedsLayout()
        } else {
            if self.previewImageView.alpha == 0 {
                self.doneLoading(animated: true)
            }
        }
    }
    
    fileprivate func reloadDomainName() {
        if let host = self.link?.host {
            let domain = host
            self.domainLabel.text = domain
        } else if let domain = self.link?.host {
            self.domainLabel.text = domain
        } else {
            self.domainLabel.text = nil
        }
    }
    
    private func doneLoading(animated: Bool = true) {
        let oldValue = self.isLoading
        self.isLoading = false
        if animated && oldValue == false {
            self.loadingPlaceholderImageView.isHidden = false
            self.titleLabel.alpha = 0.0
            self.domainLabel.alpha = 0.0
            self.previewImageView.alpha = 0.0
            
            UIView.animate(withDuration: 0.32, animations: {
                self.loadingPlaceholderImageView.alpha = 0.0
                self.titleLabel.alpha = 1.0
                self.domainLabel.alpha = 1.0
                self.previewImageView.alpha = 1.0
            }, completion: { (finished) in
                self.loadingPlaceholderImageView.isHidden = !self.isLoading
                self.loadingPlaceholderImageView.alpha = 1.0
            })
        } else {
            self.loadingPlaceholderImageView.alpha = 1.0
            self.loadingPlaceholderImageView.isHidden = true
            self.titleLabel.alpha = 1.0
            self.domainLabel.alpha = 1.0
            self.previewImageView.alpha = 1.0
        }
    }
    
    /// Directly start fetching metadata. Use scheduleFetchingMetadata instead, to prevent needlessly fetching metadata.
    @objc fileprivate func startFetchingMetadata() {
        self.cancelAllRequests()
        
        self.request = self.link?.oca.fetchInformation { (information, error) in
            self.information = information
        }
        
    }
    
    fileprivate func cancelAllRequests() {
        self.request?.cancel()
        self.request = nil
        self.doneLoading(animated: false)
        self.imageTask?.cancel()
    }
    
    //MARK: - Colors
    
    override var isHighlighted: Bool {
        didSet {
            self.displayModeDidChange()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.displayModeDidChange()
        }
    }
    
    func displayModeDidChange() {
        self.titleLabel.attributedText = self.attributedTitle
        
        var backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        if self.isHighlighted || self.isSelected {
            backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
        }
        self.backgroundColor = backgroundColor
        self.titleLabel.backgroundColor = backgroundColor
        self.domainLabel.backgroundColor = backgroundColor
        self.loadingPlaceholderImageView.backgroundColor = backgroundColor
        
        //The color used for the border, loading placeholder and empty imageView
        let secondColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha:1)
        self.previewImageView.backgroundColor = secondColor
        self.layer.borderColor = secondColor.cgColor
        //Setting the tintColor when it's already the correct tintColor causes the image to be tinted again, this leads to high CPU usage
        if self.loadingPlaceholderImageView.tintColor != secondColor {
            self.loadingPlaceholderImageView.tintColor = secondColor
        }
        
        
        self.domainLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        
    }
    
    //MARK: - Layout
    
    private let videoRatio: CGFloat = 16 / 9
    private let viewInsetsLink = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
    private let viewInsetsVideo = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.previewImageView.layer.cornerRadius = 2
    
        self.previewImageView.layer.masksToBounds = true
        
        self.layoutForLinkPreview()

    }
    
    private func layoutForLinkPreview() {
        var insets = self.viewInsetsLink
        
        let imageToTitleSpacing: CGFloat = 10
        let titleToDomainSpacing: CGFloat = 4
        
        var xPosition = insets.left
        if !self.previewImageView.isHidden {
            //First, layout the image
            let imageHeight = self.bounds.height-insets.top-insets.bottom
            let imageFrame = CGRect(x: xPosition, y: insets.top, width: imageHeight, height: imageHeight)
            self.previewImageView.frame = imageFrame
            
            xPosition += imageHeight
            xPosition += imageToTitleSpacing
        }
        
        insets.left = xPosition
        
        let descriptionRect = UIEdgeInsetsInsetRect(self.bounds, insets)
        var maxSize = descriptionRect.size
        
        var placeholderFrame = UIEdgeInsetsInsetRect(self.bounds, self.viewInsetsLink)
        placeholderFrame.size.height = self.loadingPlaceholderImageView.image?.size.height ?? 0
        self.loadingPlaceholderImageView.frame = placeholderFrame
        
        self.domainLabel.preferredMaxLayoutWidth = maxSize.width
        var domainSize = self.domainLabel.sizeThatFits(maxSize)
        domainSize.width = min(domainSize.width, descriptionRect.width)
        
        guard self.titleLabel.attributedText != nil else {
            var yPosition = (descriptionRect.height-domainSize.height)/2
            yPosition += insets.top
            
            self.domainLabel.frame = CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: domainSize)
            return
        }
        
        maxSize.height -= domainSize.height
        maxSize.height -= titleToDomainSpacing
        
        self.titleLabel.preferredMaxLayoutWidth = descriptionRect.width
        var titleSize = self.titleLabel.sizeThatFits(maxSize)
        titleSize.width = min(titleSize.width, descriptionRect.width)
        let combinedHeight = titleSize.height + domainSize.height + titleToDomainSpacing
        var yPosition = (descriptionRect.height-combinedHeight)/2
        yPosition += insets.top
        
        self.titleLabel.frame = CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: titleSize)
        yPosition += titleSize.height
        yPosition += titleToDomainSpacing
        
        self.domainLabel.frame = CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: domainSize)
        
    }
    
    //MARK: - Size
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 78)
    }
    
    class func height(for link: URL?, inWidth width: CGFloat, isVideoPreview: Bool) -> CGFloat {
        return 78
    }

}
