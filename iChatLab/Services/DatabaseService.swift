//
//  DatabaseService.swift
//  iChatLab
//
//  Created by Han Luong on 3/13/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation
import Firebase

enum FCollectionReference: String {
    case User
    case Typing
    case Recent
    case Message
    case Group
    case Call
}

func reference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}

class DatabaseService {
    static let instance = DatabaseService()
    
    
    func currentUserId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    func currentUser() -> User? {
        if Auth.auth().currentUser != nil {
            if let userInfoDict = userDefaults.object(forKey: kCURRENT_USER) {
                return User(dictionary: userInfoDict as! [String:Any])
            }
        }
        return nil
    }
    
    func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if let error = error {
                completion(error)
                return
            }
            if let authDataResult = authDataResult {
                self.fetchCurrentUserFromFirestore(userId: authDataResult.user.uid) { error in
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    // Notification user did login
                    NotificationCenter.default.post(name: .userDidLoginNotif, object: nil, userInfo: [kUSER_ID: self.currentUserId()])
                }
            }
            completion(error)
        }
    }
    
    func logoutCurrentUser(completion: @escaping (_ success: Bool) -> Void) {
        userDefaults.removeObject(forKey: kCURRENT_USER)
        userDefaults.synchronize()
        
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch let error {
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func fetchCurrentUserFromFirestore(userId: String, completion: @escaping (_ error: Error?) -> Void) {
        reference(.User).document(currentUserId()).getDocument { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(error)
                return
            }
            
            if let snapshot = snapshot, snapshot.exists {
                let userInfoDict = snapshot.data() ?? [:]
                userDefaults.setValue(userInfoDict, forKey: kCURRENT_USER)
                userDefaults.synchronize()
            }
            completion(nil)
        }
    }
    
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            if let error = error {
                completion(error)
                return
            }
            
            if let authDataResult = authDataResult {
                // TODO:
                // - Create user
                // - Save user in local
                // - Save user in Firestore
                
                let user = User(objectId: authDataResult.user.uid, pushId: "", createdAt: Date(), updatedAt: Date(), email: authDataResult.user.email!, firstName: "", lastName: "", avatar: "", phoneNumber: "", country: "", city: "", loginMethod: kEMAIL)
                self.saveUserInLocally(user)
                self.saveUserInFirestore(user)
                
                // Notification user did login
                NotificationCenter.default.post(name: .userDidLoginNotif, object: nil, userInfo: [kUSER_ID: self.currentUserId()])
            }
            
            completion(error)
        }
    }
    
    func updateCurrentUserInFirestore(withValue: [String:Any], completion: @escaping (_ error: Error?) -> Void) {
        var currentUserInfoDict = userDefaults.value(forKey: kCURRENT_USER) as! [String:Any]
        withValue.forEach { (key, value) in
            currentUserInfoDict.updateValue(value, forKey: key)
        }
        currentUserInfoDict.updateValue(Date.dateFormatter().string(from: Date()), forKey: kUPDATED_AT)
        reference(.User).document(currentUserInfoDict[kOBJECT_ID] as! String).updateData(currentUserInfoDict) { (error) in
            if let error = error {
                completion(error)
                return
            }
        }
        userDefaults.setValue(currentUserInfoDict, forKey: kCURRENT_USER)
        userDefaults.synchronize()
        completion(nil)
    }
    
    private func saveUserInLocally(_ user: User) {
        userDefaults.set(user.toDictionary(), forKey: kCURRENT_USER)
        userDefaults.synchronize()
    }
    
    private func saveUserInFirestore(_ user: User) {
        reference(.User).document(user.id).setData(user.toDictionary()) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
