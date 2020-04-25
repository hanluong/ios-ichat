//
//  MessageService.swift
//  iChatLab
//
//  Created by Han Luong on 4/19/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class MessageService {
    static let instance = MessageService()
    private let recentService = RecentService.instance
    
    func send(message: Message, to membersIdToPush: [String]) {
        for memberId in membersIdToPush {
            reference(.Message).document(memberId).collection(message.chatRoomId).document(message.id).setData(message.toDict()) { error in
                if let error = error {
                    fatalError("ERROR! sendMessageTo(membersIdToPush:): \(error.localizedDescription)")
                }
            }
        }
        
        // Update last message in Recent database
        recentService.setLastRecentMessage(message)
        
        // TODO: push notification to users
    }
    
    func delete(message: Message, to membersIdToPush: [String], completion: @escaping (_ finished: Bool) -> Void) {
        var counter = 0
        for memeberId in membersIdToPush {
            counter += 1
            reference(.Message).document(memeberId).collection(message.chatRoomId).document(message.id).delete { (error) in
                if let error = error {
                    print("ERROR! Delete message: \(error.localizedDescription)")
                    completion(false)
                    return
                }
            }
            if counter == membersIdToPush.count {
                completion(true)
            }
        }
    }
    
    /*
     * Update ONLY for outgoing message
     */
    func update(message: Message, data: [String:Any], completion: @escaping (_ finished: Bool) -> Void) {
        reference(.Message).document(message.senderId).collection(message.chatRoomId).document(message.id).updateData(data) { (error) in
            if let error = error {
                print("ERROR! updateMessageStatus(membersIdToPush:): \(error.localizedDescription)")
                completion(false)
            }
            completion(true)
        }
    }
    
    func loadJSQMediaItemOf(message: Message, membersId: [String], completion: @escaping (_ success: Bool) -> Void) {
        let type = message.type
        if type == .photo || type == .video || type == .audio {
            let downloadedFileName = (message.mediaURL.components(separatedBy: "%").last!).components(separatedBy: "?").first!
            var localMediaURL = Common.getCurrentDocumentURL()
            localMediaURL = localMediaURL.appendingPathComponent(downloadedFileName, isDirectory: false)
            if !Common.doesFileExistsInCurrentDocument(fileName: downloadedFileName) {
                Storage.storage().reference(forURL: message.mediaURL).getData(maxSize: INT64_MAX) { (data, error) in
                    guard let data = data, error == nil else {
                        print("ERROR! downloading image from url \(message.mediaURL), error: \(error!.localizedDescription)")
                        completion(false)
                        return
                    }
                    try! data.write(to: localMediaURL, options: .atomic)
                    self.setValueForMediaItem(localMediaURL, message: message) { success in
                        if success {
                            self.updateMessageStatus(message) { (finished) in
                                completion(finished)
                            }
                        }
                    }
                }
            } else {
                setValueForMediaItem(localMediaURL, message: message) { success in
                    if success {
                        self.updateMessageStatus(message) { (finished) in
                            completion(finished)
                        }
                    }
                }
            }
        } else if type == .location {
            message.locationMediaItem!.setLocation(CLLocation(latitude: message.latitude, longitude: message.longitude)) {
                self.updateMessageStatus(message) { (finished) in
                    completion(finished)
                }
            }
        }
        else {
            self.updateMessageStatus(message) { (finished) in
                completion(finished)
            }
        }
    }
    
    private func setValueForMediaItem(_ fileURL: URL, message: Message, completion: @escaping (_ success: Bool) -> Void) {
        switch message.type {
        case .photo:
            message.photoMediaItem?.image = UIImage(contentsOfFile: fileURL.path)
        case .video:
            message.videoMediaItem?.fileURL = fileURL
            message.videoMediaItem?.isReadyToPlay = true
            message.videoMediaItem?.addThumbnail()
        case .audio:
            let audioData = try? Data(contentsOf: fileURL)
            message.audioMediaItem?.audioData = audioData
        default:
            print("Unknown Message Type to setValueForMediaItem()")
        }
        
        completion(true)
    }
    
    private func updateMessageStatus(_ message: Message, completion: @escaping (_ success: Bool) -> Void) {
        if message.senderId == DatabaseService.instance.currentUserId() && message.status != .read {
            // Outgoing message
            message.status = .sent
        } else {
            // Incoming message
            message.status = .read
        }
        let updatedData: [String:Any] = [
            kMESSAGE_STATUS: message.status.rawValue
        ]
        
        update(message: message, data: updatedData) { (finished) in
            completion(finished)
        }
    }
}
