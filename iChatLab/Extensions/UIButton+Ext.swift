//
//  UIButton+Extension.swift
//  iChatLab
//
//  Created by Han Luong on 3/19/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit

extension UIButton {
    
    func styleFilledButton() {
        // filled rounded corner style
        self.backgroundColor = #colorLiteral(red: 0.3266413212, green: 0.4215201139, blue: 0.7752227187, alpha: 1)
        self.layer.cornerRadius = 5.0
        self.tintColor = UIColor.white
    }
    
    func styleHollowButton() {
        // Hollow rounded corner style
        self.layer.borderWidth = 1
        self.layer.borderColor = #colorLiteral(red: 0.3266413212, green: 0.4215201139, blue: 0.7752227187, alpha: 1)
        self.layer.cornerRadius = 5.0
        self.tintColor = #colorLiteral(red: 0.3266413212, green: 0.4215201139, blue: 0.7752227187, alpha: 1)
        
    }

}
