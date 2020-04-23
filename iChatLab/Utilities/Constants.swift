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
         let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainView") as! UITabBarController
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    static let welcomeView: WelcomeViewController = {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "welcomeView") as! WelcomeViewController
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    static let profileView: ProfileTableViewController = {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileTableViewController
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    static let chattingView: ChattingViewController = {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "chattingView") as! ChattingViewController
        return vc
    }()
    
    static let mapView: MapViewController = {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "mapView") as! MapViewController
        return vc
    }()
    
    static let infoView: MediasCollectionViewController = {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "infoView") as! MediasCollectionViewController
        return vc
     }()
    
    struct Identifier {
        struct Cell {
            static let user = "userCell"
            static let setting = "settingCell"
            static let recent = "recentCell"
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

// Recent
public let kRECENT_ID = "recentId"
public let kRECENT_NAME = "recentName"
public let kRECENT_AVATAR = "recentAvatar"
public let kCHATROOM_ID = "chatRoomId"
public let kMEMBERS = "members"
public let kMEMBERS_TO_PUSH = "membersToPush"
public let kWITH_USER_FULL_NAME = "withUserFullName"
public let kWITH_USER_ID = "withUserId"
public let kLAST_MESSAGE = "lastMessage"
public let kCOUNTER = "counter"
public let kDATE = "date"
public let kTYPE = "type"

// Message
public let kMESSAGE_ID = "id"
public let kMESSAGE_TEXT = "text"
public let kMESSAGE_MEDIA_URL = "mediaURL"
public let kMESSAGE_LOCATION_LATITUDE = "latitude"
public let kMESSAGE_LOCATION_LONGITUDE = "longitude"
public let kMESSAGE_TYPE = "type"
public let kMESSAGE_STATUS = "status"
public let kMESSAGE_SENDER_ID = "senderId"
public let kMESSAGE_SENDER_DISPLAY_NAME = "senderDisplayName"
public let kMESSAGE_NUM_DEFAULT_LOAD_ON_SCREEN = 10


public let kPRIVATE = "private"
public let kGROUP = "group"

public let kMAX_DURATION = 120.0
public let kMAX_AUDIO_DURATION = 120.0
public let kNO_URL = "NO_URL"


//func isPasswordValid(_ password : String) -> Bool {
//    let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
//    return passwordTest.evaluate(with: password)
//}
