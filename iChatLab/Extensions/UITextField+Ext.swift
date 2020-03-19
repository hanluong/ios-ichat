//
//  UITextField+Ext.swift
//  iChatLab
//
//  Created by Han Luong on 3/19/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit

extension UITextField {

    func styleTextField() {
        // create bottom line
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.height - 8, width: self.frame.width, height: 1)
        bottomLine.backgroundColor = #colorLiteral(red: 0.3266413212, green: 0.4215201139, blue: 0.7752227187, alpha: 1)
        
        // add bottom line
        self.layer.addSublayer(bottomLine)
        
        // remove border textfield
        self.borderStyle = .none
        
        // style color
        self.textColor = #colorLiteral(red: 0.3266413212, green: 0.4215201139, blue: 0.7752227187, alpha: 1)
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [.foregroundColor: UIColor(red: 83/255, green: 107/255, blue: 198/255, alpha: 0.3)])
    }

}
