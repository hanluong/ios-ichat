//
//  RecentService.swift
//  iChatLab
//
//  Created by Han Luong on 4/24/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation


class RecentService {
    static let instance = RecentService()
    
    func deleteRecentBy(chatRoomId: String) {
        reference(.Recent).whereField(kCHATROOM_ID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                print("ERROR! get recent by chatRoomId \(chatRoomId): \(error!.localizedDescription)")
                return
            }
            
            for document in snapshot.documents {
                let documentDict = document.data()
                let recentId = documentDict[kRECENT_ID] as! String
                self.deleteRecentBy(id: recentId)
            }
        }
    }
    
    func setLastRecentMessage(_ message: Message) {
        reference(.Recent).whereField(kCHATROOM_ID, isEqualTo: message.chatRoomId).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else { return }
            for document in snapshot.documents {
                let documentDict = document.data()
                let recentId = documentDict[kRECENT_ID] as! String
                let recentCounter = documentDict[kCOUNTER] as! Int
                let updateData: [String:Any] = [
                    kLAST_MESSAGE: message.text!,
                    kCOUNTER: recentCounter + 1,
                    kDATE: Date.dateFormatter().string(from: Date()),
                ]
                self.updateRecentBy(id: recentId, data: updateData)
            }
        }
    }
    
    func updateLastRecentMessage(_ message: Message) {
        reference(.Recent).whereField(kCHATROOM_ID, isEqualTo: message.chatRoomId).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else { return }
            for document in snapshot.documents {
                let documentDict = document.data()
                let recentId = documentDict[kRECENT_ID] as! String
                var recentCounter = documentDict[kCOUNTER] as! Int
                if recentCounter > 0 {
                    recentCounter -= 1
                }
                
                let updateData: [String:Any] = [
                    kLAST_MESSAGE: message.text!,
                    kCOUNTER: recentCounter,
                    kDATE: Date.dateFormatter().string(from: Date()),
                ]
                self.updateRecentBy(id: recentId, data: updateData)
            }
        }
    }
    
    func resetRecentCounterBy(userId: String) {
        let updateData: [String:Any] = [
            kCOUNTER: 0,
            kDATE: Date.dateFormatter().string(from: Date()),
        ]
        reference(.Recent).whereField(kUSER_ID, isEqualTo: userId).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else { return }
            for document in snapshot.documents {
                let documentDict = document.data()
                let recentId = documentDict[kRECENT_ID] as! String
                self.updateRecentBy(id: recentId, data: updateData)
            }
        }
    }
    
    private func updateRecentBy(id: String, data: [String:Any]) {
        reference(.Recent).document(id).updateData(data) { (error) in
            if let error = error {
                print("ERROR! update recent chat: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteRecentBy(id: String) {
        reference(.Recent).document(id).delete { (error) in
            if let error = error {
                print("ERROR! delete recent id \(id): \(error.localizedDescription)")
            }
        }
    }
}
