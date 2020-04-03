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
    
    static func timeElapsed(date: Date) -> String {
        
        let seconds = NSDate().timeIntervalSince(date)
        
        var elapsed: String?
        
        
        if (seconds < 60) {
            elapsed = "Just now"
        } else if (seconds < 60 * 60) {
            let minutes = Int(seconds / 60)
            
            var minText = "min"
            if minutes > 1 {
                minText = "mins"
            }
            elapsed = "\(minutes) \(minText)"
            
        } else if (seconds < 24 * 60 * 60) {
            let hours = Int(seconds / (60 * 60))
            var hourText = "hour"
            if hours > 1 {
                hourText = "hours"
            }
            elapsed = "\(hours) \(hourText)"
        } else {
            let currentDateFormater = dateFormatter()
            currentDateFormater.dateFormat = "dd/MM/YYYY"
            
            elapsed = "\(currentDateFormater.string(from: date))"
        }
        
        return elapsed!
    }
}
