//
//  Constants.swift
//  iChatLab
//
//  Created by Han Luong on 3/12/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation
import UIKit

public let userDefaults = UserDefaults.standard

// Storyboard
struct Storyboard {

    static let mainView: UIViewController = {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Storyboard.ID.mainView) as! UITabBarController
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    static let welcomeView: UIViewController = {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Storyboard.ID.welcomeView)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    
    struct ID {
        static let mainView = "mainView"
        static let welcomeView = "welcomeView"
    }
    
    struct Identifier {
        struct Cell {
            static let user = "userCell"
            static let setting = "settingCell"
        }
        struct Segue {
            static let goTiFinishedRegisterVC = "goToFinishedRegisterViewController"
            static let goToMainApp = "gotoMainApp"
        }
    }
}

public let kCURRENT_USER = "currentUser"
public let kUSER_ID = "userId"

// Users Registration
public let kOBJECT_ID = "objectId"
public let kPUSH_ID = "pushId"

public let kCREATED_AT = "createdAt"
public let kUPDATED_AT = "updatedAt"

public let kEMAIL = "email"
public let kFIRST_NAME = "firstname"
public let kLAST_NAME = "lastname"
public let kFULL_NAME = "fullname"
public let kAVATAR = "avatar"
public let kPHONE = "phone"
public let kCOUNTRY_CODE = "countryCode"
public let kCOUNTRY = "country"
public let kCITY = "city"

public let kLOGIN_METHOD = "loginMethod"

public let kIS_ONLINE = "isOnline"
public let kCONTACT = "contact"
public let kBLOCKED_USER_ID = "blockedUserId"


//func isPasswordValid(_ password : String) -> Bool {
//    let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
//    return passwordTest.evaluate(with: password)
//}
