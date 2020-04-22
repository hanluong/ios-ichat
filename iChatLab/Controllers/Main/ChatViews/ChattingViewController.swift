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
import SKPhotoBrowser
import Firebase

class ChattingViewController: JSQMessagesViewController, CLLocationManagerDelegate {
    
    // MARK: - Vars
    private var locationManager: CLLocationManager!
    private let dbService = DatabaseService.instance
    private let storageService = StorageService.instance
    
    var chatRoomId: String!
    var type: String!
    var membersIdToPush: [String]!
    
    private var loadedMessages = [Message]()
    private var messages = [Message]()
    private var members = [User]()
    
    private var newChatListener: ListenerRegistration?
    private var typingListener: ListenerRegistration?
    
    var numTyping = 0
    
    var outgoingMessagesBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    var incomingMessaageBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add view tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.senderId = dbService.currentUserId()
        self.senderDisplayName = dbService.currentUser()!.firstName
        
        loadUsers { (success) in
            if success {
                self.setupUI()
                self.loadMessages()
            }
        }
        createTypingObserver()
    }
    
    // MARK: - Implement chatting
    
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
            if self.haveAccessLocation() {
                let locationMediaItem = JSQLocationMediaItem(location: self.locationManager.location!)
                guard let message = Message(chatRoomId: self.chatRoomId, senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date(), locationMediaItem: locationMediaItem!) else { return }
                message.sendMessageTo(membersIdToPush: self.membersIdToPush)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
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
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        startTypingCounter()
        return true
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            let message = Message(chatRoomId: chatRoomId, senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
            message!.sendMessageTo(membersIdToPush: membersIdToPush)
            self.updateSendButton(isEnable: false)
        } else {
            let audioVC = IQAudioRecorderViewController()
            audioVC.delegate = self
            audioVC.title = "Recoder"
            audioVC.maximumRecordDuration = kMAX_AUDIO_DURATION
            audioVC.allowCropping = true
            self.presentBlurredAudioRecorderViewControllerAnimated(audioVC)
        }
    }
    
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
    
    // config timestamp for chatting
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
    
    // config message status for chatting
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.row == self.messages.count - 1 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        // show message status for Outgoing message
        if indexPath.row == self.messages.count - 1 && self.messages[indexPath.row].senderId == self.senderId {
            return NSAttributedString(string: self.messages[indexPath.row].status.rawValue, attributes: [.foregroundColor: UIColor(red: 83/255, green: 107/255, blue: 198/255, alpha: 1)])
        } else {
            return nil
        }
    }
    
    // Load more message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        loadOldMessages()
        self.collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = self.messages[indexPath.row]
        switch message.type {
        case .photo:
            let skPhoto = SKPhoto.photoWithImage(message.photoMediaItem!.image)
            let browser = SKPhotoBrowser(photos: [skPhoto])
            self.present(browser, animated: true, completion: nil)
        case .video:
            let player = AVPlayer(url: message.videoMediaItem!.fileURL as URL)
            let moviePlayer = AVPlayerViewController()
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            moviePlayer.player = player
            self.present(moviePlayer, animated: true) {
                moviePlayer.player!.play()
            }
        case .location:
            let mapVC = Storyboard.mapView
            mapVC.location = message.locationMediaItem?.location
            self.navigationController?.pushViewController(mapVC, animated: true)
        default:
            print("WARRING! - didTapMessageBubbleAt - Unknown Message Type was tapped")
        }
    }
    
    // MARK: - Helpers function
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    private func haveAccessLocation() -> Bool {
        if locationManager != nil {
            return true
        } else {
            ProgressHUD.showError("ERROR! not accessed to your location")
            return false
        }
    }
    
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
                title.text = members[0].id != senderId ? members[0].fullName : members[1].fullName
                title.font = UIFont(name: title.font.familyName, size: 15)
                title.textColor = #colorLiteral(red: 0.3254901961, green: 0.4196078431, blue: 0.7764705882, alpha: 1)
            } else {
                // TODO: for group
            }
            return title
        }()
        
        let subTitleLabel: UILabel = {
            let subTitle = UILabel(frame: CGRect(x: 40, y: 22, width: 150, height: 15))
            if type == kPRIVATE {
                subTitle.text = members[0].id != senderId ? members[0].email : members[1].email
                subTitle.font = UIFont(name: subTitle.font.familyName, size: 12)
                subTitle.textColor = #colorLiteral(red: 0.3254901961, green: 0.4196078431, blue: 0.7764705882, alpha: 1)
            } else {
                // TODO: for group
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
        // TODO: set infoButtonPressed
        print("infoButtonPressed() ......")
    }
    
    @objc func avatartButtonTapped() {
        if type == kPRIVATE {
            let profileVC = Storyboard.profileView
            profileVC.user = members[0]
            self.navigationController?.pushViewController(profileVC, animated: true)
        } else {
            // TODO: for group here
        }
    }
    
    @objc func backBarButtonPressed(_ sender: Any) {
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func removeListeners() {
        if let newChatListener = newChatListener {
            newChatListener.remove()
        }
    }
    
    private func loadMessages() {
        // load last default messages
        reference(.Message).document(senderId).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: kMESSAGE_NUM_DEFAULT_LOAD_ON_SCREEN).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                return
            }
            for document in snapshot.documents {
                let messageDict = document.data()
                if let message = Message(messageDict) {
                    message.loadJSQMediaItem(membersId: self.membersIdToPush) { (success) in
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
                
                // load old messages in backgroud
                if let oldestMessageLoaded = self.messages.first {
                    
                    reference(.Message).document(self.senderId).collection(self.chatRoomId).whereField(kDATE, isLessThan: Date.dateFormatter().string(from: oldestMessageLoaded.date)).order(by: kDATE, descending: true).getDocuments { (snapshot, error) in
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
                self.scrollToBottom(animated: true) // scroll to bottom at the first time load messages
                
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
            message.loadJSQMediaItem(membersId: self.membersIdToPush) { (success) in
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
        // listen new chat messages
        let query: Query
        if let latestMessage = self.messages.last {
            query = reference(.Message).document(senderId).collection(chatRoomId).whereField(kDATE, isGreaterThan: Date.dateFormatter().string(from: latestMessage.date))
        } else {
            query = reference(.Message).document(senderId).collection(chatRoomId)
        }
        newChatListener = query.addSnapshotListener { (snapshots, error) in
            guard let snapshots = snapshots, error == nil else {
                fatalError("ERROR! to listen chatting message: \(error!.localizedDescription)")
            }
            for diff in snapshots.documentChanges {
                let messageDict = diff.document.data()
                if let message = Message(messageDict) {
                    if diff.type == .added {
                        message.loadJSQMediaItem(membersId: self.membersIdToPush) { (success) in
                            if success {
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                }
                            }
                        }
                        self.messages.append(message)
                        JSQSystemSoundPlayer.jsq_playMessageSentSound()
                        self.finishSendingMessage(animated: true)
                    }
                    else {
                        // for update message status
                        self.messages.forEach { tmpMessage in
                            if tmpMessage.id == message.id {
                                tmpMessage.status = message.status
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    // Typing helpers
    func createTypingObserver() {
        typingListener = reference(.Typing).document(self.chatRoomId).addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                print("ERROR! failed to listen typing indicator")
                return
            }
            
            if snapshot.exists {
                for data in snapshot.data()! {
                    if data.key != self.dbService.currentUserId() {
                        // show typing idicator
                        let isTyping = data.value as! Bool
                        self.showTypingIndicator = isTyping
                        self.scrollToBottom(animated: isTyping)
                    }
                }
            } else {
                reference(.Typing).document(self.chatRoomId).setData([self.dbService.currentUserId(): false])
            }
        }
    }
    
    func startTypingCounter() {
        numTyping += 1
        saveTypingForCurrentUserToFirestore(value: true)
        
        // remove typing indicator when stop after 2s
        self.perform(#selector(self.stopTypingCounter), with: nil, afterDelay: 2.0)
    }
    
    @objc func stopTypingCounter() {
        numTyping -= 1
        if numTyping == 0 {
            saveTypingForCurrentUserToFirestore(value: false)
        }
    }
    
    func saveTypingForCurrentUserToFirestore(value: Bool) {
        reference(.Typing).document(self.chatRoomId).updateData([self.dbService.currentUserId(): value])
    }
    
    
}

// MARK: - Implement UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ChattingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Dismiss picker controller
        // Create JSQMessage for media image
        picker.dismiss(animated: true, completion: nil)
        
        if let originalImage = info[.originalImage] as? UIImage {
            // upload photo
            guard let resizedImage = originalImage.scaledToSafeUploadSize else { return }
            storageService.uploadPhotoImageToFirestore(resizedImage, senderId: senderId, chatRoomId: chatRoomId, view: self.view) { (imageUrl) in
                guard let imageUrl = imageUrl else { return }
                if let message = Message(chatRoomId: self.chatRoomId, senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date(), mediaURL: imageUrl,  type: .photo) {
                    message.sendMessageTo(membersIdToPush: self.membersIdToPush)
                }
            }
        } else if let video = info[.mediaURL] as? NSURL {
            // upload video
            guard let videoData = NSData(contentsOfFile: video.path!) else { return }
            storageService.uploadVideoToFirestore(videoData, senderId: senderId, chatRoomId: chatRoomId, view: self.view) { (videoUrl) in
                guard let videoUrl = videoUrl else { return }
                if let message = Message(chatRoomId: self.chatRoomId, senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date(), mediaURL: videoUrl, type: .video) {
                    message.sendMessageTo(membersIdToPush: self.membersIdToPush)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Implement IQAudioRecorderViewControllerDelegate
extension ChattingViewController: IQAudioRecorderViewControllerDelegate {
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        controller.dismiss(animated: true, completion: nil)
        guard let audioData = NSData(contentsOfFile: filePath) else { return }
        storageService.uploadAudioToFirestore(audioData, senderId: senderId, chatRoomId: chatRoomId, view: self.view) { (audioUrl) in
            guard let audioUrl = audioUrl else { return }
            if let message = Message(chatRoomId: self.chatRoomId, senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date(), mediaURL: audioUrl, type: .audio) {
                message.sendMessageTo(membersIdToPush: self.membersIdToPush)
            }
        }
    }
    
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
