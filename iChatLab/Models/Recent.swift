//
//  Recent.swift
//  iChatLab
//
//  Created by Han Luong on 3/24/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit
import Firebase

struct Recent: Decodable {
    let id: String!
    let name: String!
    let avatar: String!
    let userId: String!
    let chatRoomId: String!
    var membersId = [String]()
    let lastMessage: String!
    let type: String!
    let date: String!
    let counter: Int!
    
    init(dictionary: [String:Any]) {
        guard let id = dictionary[kRECENT_ID] as? String else { fatalError("ERROR! Init id for Recent object") }
        self.id = id
        
        guard let name = dictionary[kRECENT_NAME] as? String else { fatalError("ERROR! Init name for Recent object") }
        self.name = name
        
        if let avatar = dictionary[kRECENT_AVATAR] as? String {
            self.avatar = avatar
        } else {
            self.avatar = ""
        }
        
        guard let userId = dictionary[kUSER_ID] as? String else { fatalError("ERROR! Init userId for Recent object") }
        self.userId = userId
        
        guard let chatRoomId = dictionary[kCHATROOM_ID] as? String else { fatalError("ERROR! Init chatRoomId for Recent object")}
        self.chatRoomId = chatRoomId
        
        guard let members = dictionary[kMEMBERS] as? [String], members.count > 0 else { fatalError("ERROR! Init members for Recent object") }
        self.membersId = members
        
        if let lastMessage = dictionary[kLAST_MESSAGE] as? String {
            self.lastMessage = lastMessage
        } else {
            self.lastMessage = ""
        }
        
        guard let type = dictionary[kTYPE] as? String else { fatalError("ERROR! init type for Recent object") }
        self.type = type
        
        guard let date = dictionary[kDATE] as? String else { fatalError("ERROR! Init date for Recent object") }
        self.date = date
        
        if let counter = dictionary[kCOUNTER] as? Int {
            self.counter = counter
        } else {
            self.counter = 0
        }
    }
}


// generate chatRoomId between current user and selected user
func generateChatRoomId(currentUser: User, with selectedUser: User) -> String {
    let currentUserId = currentUser.id
    let selectedUserId = selectedUser.id
    let chatRoomId: String!
    if currentUserId.compare(selectedUserId).rawValue < 0 {
        chatRoomId = currentUserId + selectedUserId
    } else {
        chatRoomId = selectedUserId + currentUserId
    }
    
    return chatRoomId
}

func startPrivateChat(currentUser: User, with selectedUser: User) {
    let currentUserId = currentUser.id
    let selectedUserId = selectedUser.id
    let membersId: [String] = [currentUserId, selectedUserId]
    let chatRoomId = generateChatRoomId(currentUser: currentUser, with: selectedUser)
    
    // Check current recent for everyone in membersId
    reference(.Recent).whereField(kCHATROOM_ID, isEqualTo: chatRoomId as String).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot, error == nil else {
            fatalError("ERROR! getting Recent documents: \(error!.localizedDescription)")
        }
        var tempMemberIds = membersId
        for document in snapshot.documents {
            let recent = Recent(dictionary: document.data())
            if tempMemberIds.contains(recent.userId) {
                tempMemberIds.remove(at: tempMemberIds.firstIndex(of: recent.userId)!)
            }
        }
        // Create new recent
        for userId in tempMemberIds {
            if userId == currentUserId {
                createRecentChat(chatRoomId: chatRoomId, name: selectedUser.fullName, avatar: selectedUser.avatar, type: kPRIVATE, userId: currentUserId, membersId: membersId)
            } else {
                createRecentChat(chatRoomId: chatRoomId, name: currentUser.fullName, avatar: currentUser.avatar, type: kPRIVATE, userId: selectedUserId, membersId: membersId)
            }
        }
    }
}

func recreateRecentChat(_ recent: Recent) {
    // TODO:
    // - get all recents following by input recent chatRoomId
    // - create listUserIds from query recents result
    // - compare input recent membersId with listUserIds -> not contained ? create : next
    
    reference(.Recent).whereField(kCHATROOM_ID, isEqualTo: recent.chatRoomId as String).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot, error == nil else {
            fatalError("ERROR! recreate Recent Chat: \(error!.localizedDescription)")
        }
        
        var listUserIds = [String]()
        for document in snapshot.documents {
            let recent = Recent(dictionary: document.data())
            listUserIds.append(recent.userId)
        }
        let createUsersId = recent.membersId.difference(from: listUserIds)
        if createUsersId.count > 0 {
            if recent.type == kPRIVATE {
                let currentUser = DatabaseService.instance.currentUser()!
                
                createRecentChat(chatRoomId: recent.chatRoomId, name: currentUser.fullName, avatar: currentUser.avatar, type: kPRIVATE, userId: createUsersId[0], membersId: recent.membersId)
            } else {
                print("Recreate recent for group")
            }
        }
        
    }
}

func createRecentChat(chatRoomId: String, name: String, avatar: String, type: String, userId: String, membersId: [String]) {
    let date = Date.dateFormatter().string(from: Date())
    let refRecent = reference(.Recent).document()
    
    let recentData: [String:Any] = [
        kRECENT_ID: refRecent.documentID,
        kRECENT_NAME: name,
        kRECENT_AVATAR: avatar,
        kCHATROOM_ID: chatRoomId,
        kUSER_ID: userId,
        kMEMBERS: membersId,
        kLAST_MESSAGE: "",
        kCOUNTER: 0,
        kDATE: date,
        kTYPE: type
    ]
    refRecent.setData(recentData)
}

func deleteRecentById(_ id: String, completion: @escaping (_ success: Bool) -> Void) {
    reference(.Recent).document(id).delete { (error) in
        if let error = error {
            print("ERROR! delete recent with Id \(id): \(error.localizedDescription)")
            completion(false)
        } else {
            completion(true)
        }
    }
}

