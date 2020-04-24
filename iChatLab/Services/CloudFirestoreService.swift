//
//  CloudFirestoreService.swift
//  iChatLab
//
//  Created by Han Luong on 4/24/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation
import Firebase

enum CloudFirestoreCollection: String {
    case User
    case Typing
    case Recent
    case Message
    case Group
    case Call
}

func reference(_ collectionReference: CloudFirestoreCollection) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
