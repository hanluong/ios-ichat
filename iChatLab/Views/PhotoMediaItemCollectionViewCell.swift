//
//  PhotoMediaItemCollectionViewCell.swift
//  iChatLab
//
//  Created by Han Luong on 4/23/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit

class PhotoMediaItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mediaImageView: UIImageView!
    
    func configurationView(image: UIImage) {
        self.mediaImageView.image = image
    }
}
