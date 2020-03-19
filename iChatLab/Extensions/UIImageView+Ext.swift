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
