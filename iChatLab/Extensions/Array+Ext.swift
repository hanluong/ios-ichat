//
//  Array+Ext.swift
//  iChatLab
//
//  Created by Han Luong on 4/3/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation
import UIKit

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
