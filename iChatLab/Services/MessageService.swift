//
//  MessageService.swift
//  iChatLab
//
//  Created by Han Luong on 4/19/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation

class MessageService {
    static let instance = MessageService()
    
    func update(message: Message, completion: @escaping (_ finished: Bool) -> Void) {
        let updatedData: [String:Any] = [
            kMESSAGE_STATUS: message.status.rawValue
        ]
        reference(.Message).document(message.senderId).collection(message.chatRoomId).document(message.id).updateData(updatedData) { (error) in
            if let error = error {
                print("ERROR! updateMessageStatus(membersIdToPush:): \(error.localizedDescription)")
                completion(false)
            }
            completion(true)
        }
    }
}
