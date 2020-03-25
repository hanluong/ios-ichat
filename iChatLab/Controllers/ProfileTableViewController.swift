//
//  ProfileTableViewController.swift
//  iChatLab
//
//  Created by Han Luong on 3/23/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    // MARK: - Vars
    private let dbService = DatabaseService.instance
    var user: User!
    
    // MARK: - IBOutlets
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configCellsInfo()
    }
    
    // MARK: - IBActions
    @IBAction func callButtonPressed(_ sender: Any) {
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
    }
    
    @IBAction func blockUserButtonPressed(_ sender: Any) {
        // - Get current blocked Ids
        let selectedUserBlockedId = user.objectId
        
        // - Check current blocked Ids and current user objectId
        var currentUsersBlockedId = dbService.currentUser()!.blockedUsers
        if !currentUsersBlockedId.contains(selectedUserBlockedId) {
            currentUsersBlockedId.append(selectedUserBlockedId)
        }
        else {
            currentUsersBlockedId.remove(at: currentUsersBlockedId.firstIndex(of: selectedUserBlockedId)!)
        }
        
        // - Save updated user in firestore
        let blockedData = [
            kBLOCKED_USER_ID: currentUsersBlockedId
        ]
        dbService.updateCurrentUserInFirestore(withValue: blockedData) { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // - Update block button
            self.updateBlockUserButton()
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    
    // MARK: - Helpers function
    private func setupUI() {
        self.title = "Profile"
        self.navigationItem.largeTitleDisplayMode = .never
        self.tableView.tableFooterView = nil
        self.tableView.tableHeaderView = nil
        
        avatarImageView.styleImageView()
    }
    
    private func configCellsInfo() {
        userNameLabel.text = user.fullName
        phoneLabel.text = user.phoneNumber
        Common.imageFromdata(imageData: user.avatar) { (image) in
            self.avatarImageView.image = image
        }
        updateBlockUserButton()
    }
 
    private func updateBlockUserButton() {
        if user.objectId == dbService.currentId() {
            callButton.isHidden = true
            messageButton.isHidden = true
            blockButton.isHidden = true
        } else {
            callButton.isHidden = false
            messageButton.isHidden = false
            blockButton.isHidden = false
        }
        
        if dbService.currentUser()!.blockedUsers.contains(user.objectId) {
            blockButton.setTitle("Unblock User", for: .normal)
        } else {
            blockButton.setTitle("Block User", for: .normal)
        }
    }
}
