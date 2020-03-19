//
//  Common.swift
//  iChatLab
//
//  Created by Han Luong on 3/19/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation
import UIKit

class Common {
    static func generateImageFromUserName(firstName: String, lastName: String, withBlock: @escaping (_ image: UIImage) -> Void) {
        let imgFromStr = firstName.first!.uppercased() + lastName.first!.uppercased()
        let lblNameInit = UILabel()
        lblNameInit.frame.size = CGSize(width: 100, height: 100)
        lblNameInit.textColor = .white
        lblNameInit.font = UIFont(name: lblNameInit.font.fontName, size: CGFloat(36))
        lblNameInit.text = imgFromStr
        lblNameInit.textAlignment = .center
        lblNameInit.backgroundColor = .lightGray
        lblNameInit.layer.cornerRadius = lblNameInit.frame.size.width/2
        
        UIGraphicsBeginImageContext(lblNameInit.frame.size)
        lblNameInit.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        withBlock(img!)
    }

    static func imageFromdata(imageData: String, withBlock: @escaping (_ image: UIImage?) -> Void) {
        var image: UIImage?
        let decodedImageData = NSData(base64Encoded: imageData, options: .init(rawValue: 0))
        image = UIImage(data: decodedImageData! as Data)
        withBlock(image)
    }
}
