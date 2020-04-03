//
//  ChattingViewController.swift
//  iChatLab
//
//  Created by Han Luong on 3/25/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit
import ProgressHUD
import JSQMessagesViewController
import AVKit
import AVFoundation
import IQAudioRecorderController
import IDMPhotoBrowser
import Firebase

class ChattingViewController: JSQMessagesViewController {

    // MARK: - Vars
    private let dbService = DatabaseService.instance
    
    var outgoingMessagesBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    var incomingMessaageBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())

    override func viewDidLoad() {
        super.viewDidLoad()

        self.senderId = dbService.currentId()
        self.senderDisplayName = dbService.currentUser()!.firstName
        
        setupViews()
    }

    override func didPressAccessoryButton(_ sender: UIButton!) {
        let menuOptions = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("camera")
        }
        let photoAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            print("Photo Library")
        }
        let videoAction = UIAlertAction(title: "Video Library", style: .default) { (action) in
            print("Video Library")
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
            self.sendMessage(text: text, date: date, photo: nil, location: nil, video: nil, audio: nil)
            
            // revert sending button
            self.updateSendButton(isEnable: false)
            finishSendingMessage(animated: true)
        } else {
            print("audio send")
        }
    }
    
    // MARK: - Helpers function
    
    private func setupViews() {
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        // custom send button to mic
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        
        // custom back button
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "Back"), style: .plain, target: self, action: #selector(backBarButtonPressed(_:)))]
    }
    
    private func updateSendButton(isEnable: Bool) {
        if isEnable {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(#imageLiteral(resourceName: "send"), for: .normal)
        } else {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(#imageLiteral(resourceName: "mic"), for: .normal)
        }
    }
    
    @objc func backBarButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func sendMessage(text: String?, date: Date, photo: UIImage?, location: String?, video: NSURL?, audio: String?) {
        if let text = text {
            print("Sending: \(text)")
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
