//
//  JSQMessagesViewController+Ext.swift
//  iChatLab
//
//  Created by Han Luong on 4/18/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation
import JSQMessagesViewController

extension JSQMessagesInputToolbar {
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if self.window?.safeAreaLayoutGuide != nil {
                self.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: (self.window?.safeAreaLayoutGuide.bottomAnchor)!, multiplier: 1.0).isActive = true
            }
        }
    }
}

extension JSQVideoMediaItem {
    
    func addThumbnail() {
        /* NOTE: https://stackoverflow.com/questions/49772623/show-image-preview-of-video-sent-in-jsqmessagesviewcontroller
         * Move this line below from JSQVideoMediaItem.m to JSQVideoMediaItem.h for public access
         * @property (strong, nonatomic) UIImageView *cachedVideoImageView;
         */
        
        var img: UIImage? = nil
        // Create video image thumbnail
        do {
            let asset = AVURLAsset(url: self.fileURL)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0,timescale: 1), actualTime: nil)
            img = UIImage(cgImage: cgImage)
        }
        catch let error as NSError {
            print("Image generator error :  \(error.localizedDescription)")
        }
        
        // Create play image buttom
        let size:CGSize = self.mediaViewDisplaySize()
        let playIcon = UIImage.jsq_defaultPlay()?.jsq_imageMasked(with: .white)
        let imageView:UIImageView = UIImageView(image: playIcon)
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        imageView.contentMode = UIView.ContentMode.center
        imageView.clipsToBounds = true
        JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageView, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
        
        if (img != nil) {
            let thumbnailImageView: UIImageView = UIImageView(image: img)
            thumbnailImageView.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
            thumbnailImageView.contentMode = UIView.ContentMode.scaleAspectFill
            thumbnailImageView.clipsToBounds = true
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: thumbnailImageView, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
            
            imageView.backgroundColor = .clear
            thumbnailImageView.addSubview(imageView)
            self.cachedVideoImageView = thumbnailImageView;
            
        }
        else {
            imageView.backgroundColor = .black
            self.cachedVideoImageView = imageView
        }
    }
}

