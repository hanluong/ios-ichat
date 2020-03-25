//
//  User.swift
//  iChatLab
//
//  Created by Han Luong on 3/13/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation
import Firebase

struct User {
    let objectId: String
    var pushId: String?
    
    let createdAt: Date
    var updatedAt: Date
    
    var email: String
    var firstName: String
    var lastName: String
    var fullName: String
    var avatar: String
    var phoneNumber: String
    var countryCode: String
    var country: String
    var city: String
    
    var loginMethod: String
    
    var isOnline: Bool
    var contacts: [String]
    var blockedUsers: [String]
    
    init(objectId: String, pushId: String?, createdAt: Date, updatedAt: Date, email: String, firstName: String, lastName: String, avatar: String = "", phoneNumber: String, country: String, city: String, loginMethod: String) {
        self.objectId = objectId
        self.pushId = pushId
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = firstName + " " + lastName
        self.avatar = avatar
        self.phoneNumber = phoneNumber
        self.countryCode = ""
        self.country = country
        self.city = city
        
        self.loginMethod = loginMethod
        
        self.isOnline = true
        self.contacts = []
        self.blockedUsers = []
    }
    
    init(dictionary: [String:Any]) {
        self.objectId = dictionary[kOBJECT_ID] as! String
        self.pushId = dictionary[kPUSH_ID] as? String
        
        if let createdAt = dictionary[kCREATED_AT] as? String {
            if createdAt.count != 14 {
                self.createdAt = Date()
            } else {
                self.createdAt = Date.dateFormatter().date(from: createdAt)!
            }
        } else {
            self.createdAt = Date()
        }
        if let updatedAt = dictionary[kUPDATED_AT] as? String {
            if updatedAt.count != 14 {
                self.updatedAt = Date()
            } else {
                self.updatedAt = Date.dateFormatter().date(from: updatedAt)!
            }
        } else {
            self.updatedAt = Date()
        }
        if let email = dictionary[kEMAIL] as? String {
            self.email = email
        } else {
            self.email = ""
        }
        if let firstName = dictionary[kFIRST_NAME] as? String {
            self.firstName = firstName
        } else {
            self.firstName = ""
        }
        if let lastName = dictionary[kLAST_NAME] as? String {
            self.lastName = lastName
        } else {
            self.lastName = ""
        }
        fullName = firstName + " " + lastName
        if let avatar = dictionary[kAVATAR] as? String {
            self.avatar = avatar
        } else {
            self.avatar = ""
        }
        if let phoneNumber = dictionary[kPHONE] as? String {
            self.phoneNumber = phoneNumber
        } else {
            self.phoneNumber = ""
        }
        if let countryCode = dictionary[kCOUNTRY_CODE] as? String {
            self.countryCode = countryCode
        } else {
            self.countryCode = ""
        }
        if let country = dictionary[kCOUNTRY] as? String {
            self.country = country
        } else {
            self.country = ""
        }
        if let city = dictionary[kCITY] as? String {
            self.city = city
        } else {
            self.city = ""
        }
        if let loginMethod = dictionary[kLOGIN_METHOD] as? String {
            self.loginMethod = loginMethod
        } else {
            self.loginMethod = ""
        }
        if let isOnline = dictionary[kIS_ONLINE] as? Bool {
            self.isOnline = isOnline
        } else {
            self.isOnline = true
        }
        if let contacts = dictionary[kCONTACT] as? [String] {
            self.contacts = contacts
        } else {
            self.contacts = []
        }
        if let blockedUsers = dictionary[kBLOCKED_USER_ID] as? [String] {
            self.blockedUsers = blockedUsers
        } else {
            self.blockedUsers = []
        }
    }
    
    func toDictionary() -> [String:Any] {
        return [
            kOBJECT_ID: self.objectId,
            kPUSH_ID: self.pushId!,
            
            kCREATED_AT: Date.dateFormatter().string(from: self.createdAt),
            kUPDATED_AT: Date.dateFormatter().string(from: self.updatedAt),
            
            kEMAIL: self.email,
            kFIRST_NAME: self.firstName,
            kLAST_NAME: self.lastName,
            kFULL_NAME: self.fullName,
            kAVATAR: self.avatar,
            kPHONE: self.phoneNumber,
            kCOUNTRY_CODE: self.countryCode,
            kCOUNTRY: self.country,
            kCITY: self.city,
            
            kLOGIN_METHOD: self.loginMethod,
            
            kIS_ONLINE: self.isOnline,
            kCONTACT: self.contacts,
            kBLOCKED_USER_ID: self.blockedUsers
        ]
    }
}

