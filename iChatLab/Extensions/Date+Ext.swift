//
//  Date+Ext.swift
//  iChatLab
//
//  Created by Han Luong on 3/13/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation

private let gDATE_FORMAT = "yyyyMMddHHmmss"

extension Date {
    
    static func dateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        dateFormatter.dateFormat = gDATE_FORMAT
        return dateFormatter
    }
}
