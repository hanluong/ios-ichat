//
//  StorageService.swift
//  iChatLab
//
//  Created by Han Luong on 4/18/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import Foundation
import MBProgressHUD
import Firebase

class StorageService {
    
    static let instance = StorageService()
    private let storageRef = Storage.storage().reference(forURL: "gs://ichatlab.appspot.com")
    
    func uploadPhotoImageToFirestore(_ image: UIImage, senderId: String, chatRoomId: String, view: UIView, completion: @escaping (_ imageLink: String?) -> Void) {
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            let dateString = Date.dateFormatter().string(from: Date())
            let childPath = "PictureMessages/" + senderId + "/" + chatRoomId + "/" + dateString + ".jpg"
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            uploadFile(uploadData: imageData, childPath: childPath, metadata: metadata, view: view) { (imageLink) in
                completion(imageLink)
            }
        } else {
            completion(nil)
        }
    }
    
    func uploadVideoToFirestore(_ videoData: NSData, senderId: String, chatRoomId: String, view: UIView, completion: @escaping (_ videoLink: String?) -> Void) {
        let dateString = Date.dateFormatter().string(from: Date())
        let childPath = "VideoMessages/" + senderId + "/" + chatRoomId + "/" + dateString + ".mov"
        let metadata = StorageMetadata()
        metadata.contentType = "video/mov"
        
        uploadFile(uploadData: videoData as Data, childPath: childPath, metadata: metadata, view: view) { (videoLink) in
            completion(videoLink)
        }
    }
    
    func uploadAudioToFirestore(_ audioData: NSData, senderId: String, chatRoomId: String, view: UIView, completion: @escaping (_ audioLink: String?) -> Void) {
        let dateString = Date.dateFormatter().string(from: Date())
        let childPath = "AudioMessages/" + senderId + "/" + chatRoomId + "/" + dateString + ".m4a"
        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"
        uploadFile(uploadData: audioData as Data, childPath: childPath, metadata: metadata, view: view) { (audioLink) in
            completion(audioLink)
        }
    }
    
    private func uploadFile(uploadData: Data, childPath: String, metadata: StorageMetadata, view: UIView, completion: @escaping (_ downloadedLink: String?) -> Void) {
        let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        progressHUD.mode = .determinateHorizontalBar
        var task: StorageUploadTask!
        
        task = storageRef.child(childPath).putData(uploadData, metadata: metadata) { (metadata, error) in
            task.removeAllObservers()
            progressHUD.hide(animated: true)
            if let error = error {
                print("ERROR! failed to upload. Error \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            self.storageRef.child(childPath).downloadURL { (url, error) in
                guard let url = url, error == nil else {
                    print("ERROR! failed to download. Error \(error!.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url.absoluteString)
            }
        }
        task.observe(.progress) { (snapshot) in
            progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
        }
    }
}
