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
    private let messageService = MessageService.instance
    /* Note:
     * Reference at https://gitlab.mobisapps.com/knevedrov/chatIt/blob/develop/SwiftExample/SwiftExample/ChatViewController.swift
     */
    
    let id: String
    let chatRoomId: String
    let type: MessageType
    var status: MessageStatus
    var mediaURL: String = kNO_URL
    var latitude: Double = 0
    var longitude: Double = 0
    var photoMediaItem: JSQPhotoMediaItem?
    var videoMediaItem: JSQVideoMediaItem?
    var audioMediaItem: JSQAudioMediaItem?
    var locationMediaItem: JSQLocationMediaItem?
    
    // MARK: - create message to store on firebase
    init!(chatRoomId: String, senderId: String, senderDisplayName: String, date: Date, text: String) {
        self.id = UUID().uuidString
        self.chatRoomId = chatRoomId
        self.status = .sending
        self.type = .text
        super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
    }
    
    init!(chatRoomId: String, senderId: String, senderDisplayName: String, date: Date, mediaURL: String, type: MessageType) {
        self.id = UUID().uuidString
        self.chatRoomId = chatRoomId
        self.status = .sending
        self.mediaURL = mediaURL
        self.type = type
        
        switch type {
        case .photo:
            self.photoMediaItem = JSQPhotoMediaItem(maskAsOutgoing: DatabaseService.instance.currentUserId() == senderId)
            super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: self.photoMediaItem)
        case .video:
            self.videoMediaItem = JSQVideoMediaItem(maskAsOutgoing: DatabaseService.instance.currentUserId() == senderId)
            super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: self.videoMediaItem)
        case .audio:
            self.audioMediaItem = JSQAudioMediaItem(maskAsOutgoing: DatabaseService.instance.currentUserId() == senderId)
            super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: self.audioMediaItem)
        default:
            super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: "Unknown MessageType to init")
        }
    }
    
    init!(chatRoomId: String, senderId: String, senderDisplayName: String, date: Date, locationMediaItem: JSQLocationMediaItem) {
        self.id = UUID().uuidString
        self.chatRoomId = chatRoomId
        self.status = .sending
        self.type = .location
        self.locationMediaItem = locationMediaItem
        self.latitude = locationMediaItem.coordinate.latitude
        self.longitude = locationMediaItem.coordinate.longitude
        super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: self.locationMediaItem)
    }
    
    // MARK: - create message after got from firebase
    init!(_ dict: [String:Any]) {
        guard let id = dict[kMESSAGE_ID] as? String,
            let chatRoomId = dict[kCHATROOM_ID] as? String,
            let senderId = dict[kMESSAGE_SENDER_ID] as? String,
            let senderDisplayName = dict[kMESSAGE_SENDER_DISPLAY_NAME] as? String,
            let text = dict[kMESSAGE_TEXT] as? String,
            let imageURL = dict[kMESSAGE_MEDIA_URL] as? String,
            let latitude = dict[kMESSAGE_LOCATION_LATITUDE] as? Double,
            let longitude = dict[kMESSAGE_LOCATION_LONGITUDE] as? Double,
            let statusValue = dict[kMESSAGE_STATUS] as? String,
            let typeValue = dict[kMESSAGE_TYPE] as? String,
            let dateStr = dict[kDATE] as? String else {
                fatalError("ERROR! init JSQMessage from dictionary")
        }
        self.id = id
        self.chatRoomId = chatRoomId
        self.status = MessageStatus(rawValue: statusValue)!
        self.type = MessageType(rawValue: typeValue)!
        self.mediaURL = imageURL
        
        switch MessageType(rawValue: typeValue)! {
        case .text:
            super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: Date.dateFormatter().date(from: dateStr), text: text)
        case .photo:
            self.photoMediaItem = JSQPhotoMediaItem(maskAsOutgoing: DatabaseService.instance.currentUserId() == senderId)
            super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: Date.dateFormatter().date(from: dateStr), media: self.photoMediaItem)
        case .video:
            self.videoMediaItem = JSQVideoMediaItem(maskAsOutgoing: DatabaseService.instance.currentUserId() == senderId)
            super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: Date.dateFormatter().date(from: dateStr), media: self.videoMediaItem)
        case .audio:
            self.audioMediaItem = JSQAudioMediaItem(data: nil)
            super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: Date.dateFormatter().date(from: dateStr), media: self.audioMediaItem)
        case .location:
            self.latitude = latitude
            self.longitude = longitude
            self.locationMediaItem = JSQLocationMediaItem(maskAsOutgoing: DatabaseService.instance.currentUserId() == senderId)
            super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: Date.dateFormatter().date(from: dateStr), media: self.locationMediaItem)
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
    
    func loadJSQMediaItem(membersId: [String], completion: @escaping (_ success: Bool) -> Void) {
        if self.type == .photo || self.type == .video || self.type == .audio {
            let downloadedFileName = (self.mediaURL.components(separatedBy: "%").last!).components(separatedBy: "?").first!
            var localMediaURL = Common.getCurrentDocumentURL()
            localMediaURL = localMediaURL.appendingPathComponent(downloadedFileName, isDirectory: false)
            if !Common.doesFileExistsInCurrentDocument(fileName: downloadedFileName) {
                Storage.storage().reference(forURL: mediaURL).getData(maxSize: INT64_MAX) { (data, error) in
                    guard let data = data, error == nil else {
                        print("ERROR! downloading image from url \(self.mediaURL), error: \(error!.localizedDescription)")
                        completion(false)
                        return
                    }
                    try! data.write(to: localMediaURL, options: .atomic)
                    self.setValueForMediaItem(localMediaURL) { success in
                        if success {
                            self.updateMessageStatus { (finished) in
                                completion(finished)
                            }
                        }
                    }
                }
            } else {
                setValueForMediaItem(localMediaURL) { success in
                    if success {
                        self.updateMessageStatus { (finished) in
                            completion(finished)
                        }
                    }
                }
            }
        } else if self.type == .location {
            self.locationMediaItem!.setLocation(CLLocation(latitude: self.latitude, longitude: self.longitude)) {
                self.updateMessageStatus { (finished) in
                    completion(finished)
                }
            }
        }
        else {
            self.updateMessageStatus { (finished) in
                completion(finished)
            }
        }
    }
    
    private func setValueForMediaItem(_ fileURL: URL, completion: @escaping (_ success: Bool) -> Void) {
        switch self.type {
        case .photo:
            self.photoMediaItem?.image = UIImage(contentsOfFile: fileURL.path)
        case .video:
            self.videoMediaItem?.fileURL = fileURL
            self.videoMediaItem?.isReadyToPlay = true
            self.videoMediaItem?.addThumbnail()
        case .audio:
            let audioData = try? Data(contentsOf: fileURL)
            self.audioMediaItem?.audioData = audioData
            self.audioMediaItem?.appliesMediaViewMaskAsOutgoing = DatabaseService.instance.currentUserId() == senderId
        default:
            print("Unknown Message Type to setValueForMediaItem()")
        }
        
        completion(true)
    }
    
    private func toDict() -> [String:Any] {
        return [
            kMESSAGE_ID: self.id,
            kCHATROOM_ID: self.chatRoomId,
            kMESSAGE_SENDER_ID: self.senderId ?? "",
            kMESSAGE_SENDER_DISPLAY_NAME: self.senderDisplayName ?? "",
            kMESSAGE_TEXT:  self.text ?? "[\(self.type.rawValue)]",
            kMESSAGE_MEDIA_URL: self.mediaURL,
            kMESSAGE_LOCATION_LATITUDE: self.latitude,
            kMESSAGE_LOCATION_LONGITUDE: self.longitude,
            kMESSAGE_STATUS: self.status.rawValue,
            kMESSAGE_TYPE: self.type.rawValue,
            kDATE: Date.dateFormatter().string(from: self.date)
        ]
    }
    
    func sendMessageTo(membersIdToPush: [String]) {
        for memberId in membersIdToPush {
            reference(.Message).document(memberId).collection(chatRoomId).document(id).setData(self.toDict()) { error in
                if let error = error {
                    fatalError("ERROR! sendMessageTo(membersIdToPush:): \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateMessageStatus(completion: @escaping (_ success: Bool) -> Void) {
        if self.senderId == DatabaseService.instance.currentUserId() {
            // Outgoing message
            self.status = .sent
        } else {
            // Incoming message
            self.status = .delivered
        }
        messageService.update(message: self) { (finished) in
            completion(finished)
        }
    }
}
