//
//  Message.swift
//  iChatLab
//
//  Created by Han Luong on 4/4/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import Firebase

enum MessageType: String {
    case text
    case photo
    case video
    case audio
    case location
}

enum MessageStatus: String {
    case sending
    case sent
    case delivered
}

class Message: JSQMessage, Comparable {
    let id: String
    let chatRoomId: String
    let type: MessageType
    var status: MessageStatus
    var imageURL: String = kNO_IMAGE
    var mediaItem: JSQPhotoMediaItem?
    
    // MARK: - create message to store on firebase
    init!(id: String, chatRoomId: String, senderId: String, senderDisplayName: String, date: Date, text: String) {
        self.id = id
        self.chatRoomId = chatRoomId
        self.status = .sending
        self.type = .text
        super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
    }
    
    init!(id: String, chatRoomId: String, senderId: String, senderDisplayName: String, date: Date, imageURL: String, type: MessageType) {
        self.id = id
        self.chatRoomId = chatRoomId
        self.status = .sending
        self.imageURL = imageURL
        self.type = type
        
        // for PhotoMediaItem
        self.mediaItem = JSQPhotoMediaItem(maskAsOutgoing: DatabaseService.instance.currentId() == senderId)
        super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: self.mediaItem)
    }
    
    // MARK: - create message after got from firebase
    init!(_ dict: [String:Any]) {
        guard let id = dict[kMESSAGE_ID] as? String,
            let chatRoomId = dict[kCHATROOM_ID] as? String,
            let senderId = dict[kMESSAGE_SENDER_ID] as? String,
            let senderDisplayName = dict[kMESSAGE_SENDER_DISPLAY_NAME] as? String,
            let text = dict[kMESSAGE_TEXT] as? String,
            let imageURL = dict[kMESSAGE_IMAGE_URL] as? String,
            let statusValue = dict[kMESSAGE_STATUS] as? String,
            let typeValue = dict[kMESSAGE_TYPE] as? String,
            let dateStr = dict[kDATE] as? String else {
                fatalError("ERROR! init JSQMessage from dictionary")
        }
        self.id = id
        self.chatRoomId = chatRoomId
        self.status = MessageStatus(rawValue: statusValue)!
        self.type = MessageType(rawValue: typeValue)!
        self.imageURL = imageURL
        
        switch MessageType(rawValue: typeValue)! {
        case .text:
            super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: Date.dateFormatter().date(from: dateStr), text: text)
        case .photo:
            self.mediaItem = JSQPhotoMediaItem(maskAsOutgoing: DatabaseService.instance.currentId() == senderId)
            super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: Date.dateFormatter().date(from: dateStr), media: self.mediaItem)
        default:
            super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: Date.dateFormatter().date(from: dateStr), text: text)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func <(lhs: Message, rhs: Message) -> Bool {
        return Date.dateFormatter().string(from: lhs.date) < Date.dateFormatter().string(from: rhs.date)
    }
    
    static func >(lhs: Message, rhs: Message) -> Bool {
        return Date.dateFormatter().string(from: lhs.date) > Date.dateFormatter().string(from: rhs.date)
    }
    
    func downloadJSQPhotoMediaItem(completion: @escaping (_ success: Bool) -> Void) {
        if self.type == .photo {
            Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX) { (data, error) in
                guard let data = data, error == nil else {
                    print("ERROR! downloading image from url \(self.imageURL), error: \(error!.localizedDescription)")
                    completion(false)
                    return
                }
                if let image = UIImage(data: data) {
                    self.mediaItem?.image = image
                }
                completion(true)
            }
        } else {
            completion(false)
        }
    }
    
    private func toDict() -> [String:Any] {
        return [
            kMESSAGE_ID: self.id,
            kCHATROOM_ID: self.chatRoomId,
            kMESSAGE_SENDER_ID: self.senderId ?? "",
            kMESSAGE_SENDER_DISPLAY_NAME: self.senderDisplayName ?? "",
            kMESSAGE_TEXT:  self.text ?? "",
            kMESSAGE_IMAGE_URL: self.imageURL,
            kMESSAGE_STATUS: self.status.rawValue,
            kMESSAGE_TYPE: self.type.rawValue,
            kDATE: Date.dateFormatter().string(from: self.date)
        ]
    }
    
    func sendMessageTo(membersIdToPush: [String]) {
        for memberId in membersIdToPush {
            reference(.Message).document(memberId).collection(chatRoomId).document().setData(self.toDict()) { error in
                if let error = error {
                    fatalError("ERROR! sendMessageTo(membersIdToPush:): \(error.localizedDescription)")
                }
            }
        }
    }
    
}




//struct Message {
//    let id: String
//    let chatRoomId: String
//    let senderId: String
//    let senderDisplayName: String
//    let text: String
//    let date: String
//    let type: MessageType
//    var status: MessageStatus
//
//    init(dictionary: [String:Any]) {
//        guard let id = dictionary[kMESSAGE_ID] as? String,
//            let chatRoomId = dictionary[kCHATROOM_ID] as? String,
//            let senderId = dictionary[kMESSAGE_SENDER_ID] as? String,
//            let senderDisplayName = dictionary[kMESSAGE_SENDER_DISPLAY_NAME] as? String,
//            let text = dictionary[kMESSAGE_TEXT] as? String,
//            let date = dictionary[kDATE] as? String else {
//                fatalError("ERROR! Init message Id")
//        }
//        if let type = dictionary[kMESSAGE_TYPE] as? String {
//            self.type = MessageType(rawValue: type)!
//        } else {
//            self.type = .text
//        }
//        if let status = dictionary[kMESSAGE_STATUS] as? String {
//            self.status = MessageStatus(rawValue: status)!
//        } else {
//            self.status = .deliveried
//        }
//        self.id = id
//        self.chatRoomId = chatRoomId
//        self.senderId = senderId
//        self.senderDisplayName = senderDisplayName
//        self.text = text
//        self.date = date
//    }
//
//    func toDict() -> [String:Any] {
//        return [
//            kMESSAGE_ID: self.id,
//            kCHATROOM_ID: self.chatRoomId,
//            kMESSAGE_SENDER_ID: self.senderId,
//            kMESSAGE_SENDER_DISPLAY_NAME: self.senderDisplayName,
//            kMESSAGE_TEXT: self.text,
//            kMESSAGE_TYPE: self.type.rawValue,
//            kMESSAGE_STATUS: self.status.rawValue,
//            kDATE: self.date
//        ]
//    }
//}
//
//func sendMessage(_ message: Message, membersIdToPush: [String]) {
//
//    switch message.type {
//    case .text:
//        print("send text message")
//    case .photo:
//        print("send photo message")
//    case .audio:
//        print("send audio message")
//    case .video:
//        print("send video message")
//    case .location:
//        print("send location message")
//    }
//    for memberId in membersIdToPush {
//        reference(.Message).document(memberId).collection(message.chatRoomId).document().setData(message.toDict()) { (error) in
//            if let error = error {
//                print("ERROR! sending message: \(error.localizedDescription)")
//            }
//        }
//    }
//}
