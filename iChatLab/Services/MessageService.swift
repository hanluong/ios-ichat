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
}
