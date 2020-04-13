//
//  ChattingViewController.swift
//  iChatLab
//
//  Created by Han Luong on 3/25/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit
import ProgressHUD
import MBProgressHUD
import JSQMessagesViewController
import AVKit
import AVFoundation
import IQAudioRecorderController
import IDMPhotoBrowser
import Firebase

class ChattingViewController: JSQMessagesViewController {
    
    // MARK: - Vars
    private let dbService = DatabaseService.instance
    private let storage = Storage.storage().reference(forURL: "gs://ichatlab.appspot.com")
    
    var chatRoomId: String!
    var chatWithUser: String!
    var type: String!
    var membersIdToPush: [String]!
    
    private var loadedMessages = [Message]()
    private var messages = [Message]()
    private var members = [User]()
    
    var outgoingMessagesBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    var incomingMessaageBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = dbService.currentId()
        self.senderDisplayName = dbService.currentUser()!.firstName
        
        loadUsers { (success) in
            if success {
                self.setupUI()
                self.loadMessages()
            }
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let menuOptions = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = Camera(delegate: self)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            camera.presentPhotoCamera(target: self, canEdit: false)
        }
        let photoAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            camera.presentPhotoLibrary(target: self, canEdit: false)
        }
        let videoAction = UIAlertAction(title: "Video Library", style: .default) { (action) in
            camera.presentVideoLibrary(target: self, canEdit: false)
        }
        let locationAction = UIAlertAction(title: "Location", style: .default) { (action) in
            print("Location")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Cancel")
        }
        cameraAction.setValue(UIImage(named: "camera"), forKey: "image")
        photoAction.setValue(UIImage(named: "picture"), forKey: "image")
        videoAction.setValue(UIImage(named: "video"), forKey: "image")
        locationAction.setValue(UIImage(named: "location"), forKey: "image")
        
        menuOptions.addAction(cameraAction)
        menuOptions.addAction(photoAction)
        menuOptions.addAction(videoAction)
        menuOptions.addAction(locationAction)
        menuOptions.addAction(cancelAction)
        self.present(menuOptions, animated: true, completion: nil)
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            self.updateSendButton(isEnable: true)
        } else {
            self.updateSendButton(isEnable: false)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            //            let message = Message(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text, status: .sending, type: .text)
            let message = Message(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
            message!.sendMessageTo(membersIdToPush: membersIdToPush)
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            
            // revert sending button
            self.updateSendButton(isEnable: false)
            self.finishSendingMessage(animated: true)
        } else {
            print("audio send")
        }
    }
    
    // MARK: - Implement collection view for chatting
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.row]
        if message.senderId == self.senderId {
            return outgoingMessagesBubbleImage
        } else {
            return incomingMessaageBubbleImage
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    // MARK: - timestamp for chatting
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.row % 5 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.row % 5 == 0 {
            let currentMessage = self.messages[indexPath.row]
            return JSQMessagesTimestampFormatter.shared()?.attributedTimestamp(for: currentMessage.date)
        } else {
            return nil
        }
    }
    
    // MARK: - message status
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.row == self.messages.count - 1 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.row == self.messages.count - 1 {
            return NSAttributedString(string: self.messages[indexPath.row].status.rawValue, attributes: [.foregroundColor: UIColor(red: 83/255, green: 107/255, blue: 198/255, alpha: 1)])
        } else {
            return nil
        }
    }
    
    // MARK: - Load more message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        loadOldMessages()
        self.collectionView.reloadData()
    }
    
    // MARK: - Helpers function
    
    private func loadUsers(completion: @escaping (_ success: Bool) -> Void) {
        for memberId in membersIdToPush {
            reference(.User).document(memberId).getDocument { (snapshot, error) in
                guard let snapshot = snapshot, error == nil else {
                    completion(false)
                    return
                }
                if let userDict = snapshot.data(){
                    self.members.append(User(dictionary: userDict))
                }
                if self.members.count == self.membersIdToPush.count {
                    completion(true)
                }
            }
        }
    }
    
    private func setupUI() {
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // custom send button to mic
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        
        //custom back header view
        let backHeaderView: UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
            return view
        }()
        
        let avatarButton: UIButton = {
            let button = UIButton(frame: CGRect(x: 0, y: 5, width: 35, height: 35))
            button.setImage(Common.imageFromdata(imageData: dbService.currentUser()!.avatar), for: .normal)
            button.layer.cornerRadius = button.frame.size.width/2
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(avatartButtonTapped), for: .touchUpInside)
            return button
        }()
        
        let titleLabel: UILabel = {
            let title = UILabel(frame: CGRect(x: 40, y: 5, width: 150, height: 20))
            if type == kPRIVATE {
                title.text = members[0].fullName
                title.font = UIFont(name: title.font.familyName, size: 15)
                title.textColor = #colorLiteral(red: 0.3254901961, green: 0.4196078431, blue: 0.7764705882, alpha: 1)
            } else {
                // TODO:
                // - for group
            }
            return title
        }()
        
        let subTitleLabel: UILabel = {
            let subTitle = UILabel(frame: CGRect(x: 40, y: 22, width: 150, height: 15))
            if type == kPRIVATE {
                subTitle.text = members[0].email
                subTitle.font = UIFont(name: subTitle.font.familyName, size: 12)
                subTitle.textColor = #colorLiteral(red: 0.3254901961, green: 0.4196078431, blue: 0.7764705882, alpha: 1)
            } else {
                // TODO:
                // - for group
            }
            return subTitle
        }()
        
        backHeaderView.addSubview(avatarButton)
        backHeaderView.addSubview(titleLabel)
        backHeaderView.addSubview(subTitleLabel)
        
        // custom back button
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "Back"), style: .plain, target: self, action: #selector(backBarButtonPressed(_:))), UIBarButtonItem(customView: backHeaderView)]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "info"), style: .plain, target: self, action: #selector(infoButtonPressed))
        
    }
    
    private func updateSendButton(isEnable: Bool) {
        if isEnable {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(#imageLiteral(resourceName: "send"), for: .normal)
        } else {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(#imageLiteral(resourceName: "mic"), for: .normal)
        }
    }
    
    @objc func infoButtonPressed() {
        print("infoButtonPressed() ......")
    }
    
    @objc func avatartButtonTapped() {
        if type == kPRIVATE {
            let profileVC = Storyboard.profileView
            profileVC.user = members[0]
            self.navigationController?.pushViewController(profileVC, animated: true)
        } else {
            // TODO:
            // - for group here
        }
    }
    
    @objc func backBarButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func loadMessages() {
        // TODO:
        // - load last default messages
        reference(.Message).document(dbService.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: kMESSAGE_NUM_DEFAULT_LOAD_ON_SCREEN).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                return
            }
            for document in snapshot.documents {
                let messageDict = document.data()
                if let message = Message(messageDict) {
                    message.downloadJSQPhotoMediaItem { (success) in
                        if success {
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                    self.messages.append(message)
                }
            }
            DispatchQueue.main.async {
                self.messages = self.messages.sorted {$0 < $1}
                self.collectionView.reloadData()
                
                // TODO:
                // - load old messages in backgroud
                if let oldestMessageLoaded = self.messages.first {
                    
                    reference(.Message).document(self.dbService.currentId()).collection(self.chatRoomId).whereField(kDATE, isLessThan: Date.dateFormatter().string(from: oldestMessageLoaded.date)).order(by: kDATE, descending: true).getDocuments { (snapshot, error) in
                        guard let snapshot = snapshot, error == nil else {
                            return
                        }
                        for document in snapshot.documents {
                            let messageDict = document.data()
                            self.loadedMessages.append(Message(messageDict))
                        }
                        self.loadedMessages = self.loadedMessages.sorted {$0 < $1}
                        self.checkShowEarlierMessagesHeader()
                    }
                }
                // Listen new chatting message
                self.listenNewChatMessage()
            }
        }
    }
    
    func checkShowEarlierMessagesHeader() {
        if self.loadedMessages.count > 0 {
            self.showLoadEarlierMessagesHeader = true
        } else {
            self.showLoadEarlierMessagesHeader = false
        }
    }
    
    func loadOldMessages() {
        var count = 0
        while self.loadedMessages.count > 0 &&  count < kMESSAGE_NUM_DEFAULT_LOAD_ON_SCREEN {
            let message = self.loadedMessages.popLast()!
            message.downloadJSQPhotoMediaItem { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
            self.messages.insert(message, at: 0)
            count += 1
        }
        checkShowEarlierMessagesHeader()
    }
    
    func listenNewChatMessage() {
        // TODO:
        // - listen new chat messages
        let query: Query
        if let latestMessage = self.messages.last {
            query = reference(.Message).document(dbService.currentId()).collection(chatRoomId).whereField(kDATE, isGreaterThan: Date.dateFormatter().string(from: latestMessage.date))
        } else {
            query = reference(.Message).document(dbService.currentId()).collection(chatRoomId)
        }
        query.addSnapshotListener { (snapshots, error) in
            guard let snapshots = snapshots, error == nil else {
                fatalError("ERROR! to listen chatting message: \(error!.localizedDescription)")
            }
            for diff in snapshots.documentChanges {
                if diff.type == .added {
                    let messageDict = diff.document.data()
                    if let message = Message(messageDict) {
                        message.downloadJSQPhotoMediaItem { (success) in
                            if success {
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                }
                            }
                        }
                        self.messages.append(message)
                    }
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func uploadPhotoImageToFirestore(_ image: UIImage, completion: @escaping (_ imageURL: String?) -> Void) {
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD.mode = .determinateHorizontalBar
        
        let dateString = Date.dateFormatter().string(from: Date())
        let imageFileName = "PictureMessages/" + dbService.currentId() + "/" + chatRoomId + "/" + dateString + ".jpg"
        let storageRef = storage.child(imageFileName)
        let meta = StorageMetadata()
        meta.contentType = "image/jpg"
        
        var task: StorageUploadTask!
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            task = storageRef.putData(imageData, metadata: meta, completion: { (metadata, error) in
                task.removeAllObservers()
                progressHUD.hide(animated: true)
                
                if let error = error {
                    print("ERROR! uploading image: \(error.localizedDescription)")
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    guard let url = url, error == nil else {
                        print("ERROR! downloading image url \(error!.localizedDescription)")
                        completion(nil)
                        return
                    }
                    completion(url.absoluteString)
                }
            })
            
            task.observe(.progress) { (snapshot) in
                progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!)/Float((snapshot.progress?.totalUnitCount)!)
            }
        }
    }
    
    
}

extension ChattingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // - Dismiss picker controller
        // - Create JSQMessage for media image
        picker.dismiss(animated: true, completion: nil)
        
        if let originalImage = info[.originalImage] as? UIImage {
            // upload photo
            let resizedImage = originalImage.resizeImage(newWidth: 200)
            self.uploadPhotoImageToFirestore(resizedImage) { (imageURL) in
                if let message = Message(id: UUID().uuidString, chatRoomId: self.chatRoomId, senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date(), imageURL: imageURL!,  type: .photo) {
                    message.sendMessageTo(membersIdToPush: self.membersIdToPush)
                }
            }
        }
    }
}

extension JSQMessagesInputToolbar {
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if self.window?.safeAreaLayoutGuide != nil {
                self.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: (self.window?.safeAreaLayoutGuide.bottomAnchor)!, multiplier: 1.0).isActive = true
            }
        }
    }
}
