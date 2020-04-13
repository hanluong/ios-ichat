//
//  UIImageView+Ext.swift
//  iChatLab
//
//  Created by Han Luong on 3/19/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit

extension UIImageView {

    func styleImageView() {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
}

extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
