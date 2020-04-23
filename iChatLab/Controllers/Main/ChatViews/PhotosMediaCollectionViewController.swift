//
//  PhotosMediaCollectionViewController.swift
//  iChatLab
//
//  Created by Han Luong on 4/23/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class PhotosMediaCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var chatRoomId: String!
    private let dbService = DatabaseService.instance
    private var listImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadImages()
        
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.Identifier.Cell.photoMedia, for: indexPath) as? PhotoMediaItemCollectionViewCell else { return UICollectionViewCell() }
        let image = self.listImages[indexPath.item]
        cell.configurationView(image: image)
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let skPhoto = SKPhoto.photoWithImage(self.listImages[indexPath.item])
        let browser = SKPhotoBrowser(photos: [skPhoto])
        self.present(browser, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 30) / 2, height: collectionView.frame.height / 3)
    }
    
    // MARK: - Helper functions
    private func loadImages() {
        reference(.Message).document(dbService.currentUserId()).collection(self.chatRoomId).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                print("ERROR! failed to load messages in chatRoomId: \(self.chatRoomId!)")
                return
            }
            for document in snapshot.documents {
                let documentDict = document.data()
                if documentDict[kTYPE] as! String == MessageType.photo.rawValue {
                    let fileName = ((documentDict[kMESSAGE_MEDIA_URL] as! String).components(separatedBy: "%").last!).components(separatedBy: "?").first!
                    if Common.doesFileExistsInCurrentDocument(fileName: fileName) {
                        let filePath = Common.getCurrentDocumentURL().appendingPathComponent(fileName, isDirectory: false)
                        if let image = UIImage(contentsOfFile: filePath.path) {
                            self.listImages.append(image)
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }

}
