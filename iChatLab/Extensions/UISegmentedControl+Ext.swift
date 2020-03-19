//
//  UISegmentedControl+Ext.swift
//  iChatLab
//
//  Created by Han Luong on 3/19/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit

extension UISegmentedControl {

    func styleSegmentedControl() {
        self.selectedSegmentTintColor = #colorLiteral(red: 0.3254901961, green: 0.4196078431, blue: 0.7764705882, alpha: 1)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 83/255, green: 107/255, blue: 198/255, alpha: 1)], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        self.layer.borderWidth = 1
        self.layer.borderColor = #colorLiteral(red: 0.3254901961, green: 0.4196078431, blue: 0.7764705882, alpha: 1)
    }
}
