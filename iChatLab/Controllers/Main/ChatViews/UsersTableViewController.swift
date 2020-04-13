//
//  UsersTableViewController.swift
//  iChatLab
//
//  Created by Han Luong on 3/17/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class UsersTableViewController: UITableViewController {
    // MARK: - Vars
    private let dbService = DatabaseService.instance
    
    var allUsers = [User]()
    var filteredUsers = [User]()
    var allUsersGrouped = [String: [User]]()
    var sectionTitleList = [String]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - IBOutlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        self.setupUI()
        
        self.loadUsers()
    }
    
    // MARK: - Helpers function
    private func setupUI() {
        filterSegmentedControl.styleSegmentedControl()
    }
    
    private func resetUsersList() {
        self.allUsers = []
        self.sectionTitleList = []
        self.allUsersGrouped = [:]
    }
    
    private func splitUsersInfoInSection() {
        for currentUser in self.allUsers {
            let firstCharString = String(currentUser.firstName.first!)
            if !self.sectionTitleList.contains(firstCharString) {
                self.allUsersGrouped[firstCharString] = []
                self.sectionTitleList.append(firstCharString)
            }
            self.allUsersGrouped[firstCharString]?.append(currentUser)
        }
    }
    
    private func loadUsers(by filter: String = "All") {
        ProgressHUD.show()
        
        var query: Query!
        switch filter {
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: dbService.currentUser()!.city).order(by: kFIRST_NAME, descending: false)
        case kCOUNTRY:
            query = reference(.User).whereField(kCOUNTRY, isEqualTo: dbService.currentUser()!.country).order(by: kFIRST_NAME, descending: false)
        default:
            query = reference(.User).order(by: kFIRST_NAME, descending: false)
        }
        
        query.getDocuments { (snapshot, error) in
            self.resetUsersList()
            
            if let error = error {
                print(error.localizedDescription)
                ProgressHUD.dismiss()
                return
            }
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss()
                return
            }
            if !snapshot.isEmpty {
                self.allUsers = snapshot.documents.compactMap { document in
                    let user = User(dictionary: document.data() as [String:Any])
                    if self.dbService.currentId() != user.objectId {
                        return user
                    }
                    return nil
                }
            }
            DispatchQueue.main.async {
                self.splitUsersInfoInSection()
                self.tableView.reloadData()
                ProgressHUD.dismiss()
            }
        }
    }
    
    private func isUsingSearchController() -> Bool {
        if searchController.isActive && searchController.searchBar.text != "" {
            return true
        } else {
            return false
        }
    }
    
    // MARK: IBActions
    @IBAction func filterSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.loadUsers(by: kCITY)
        case 1:
            self.loadUsers(by: kCOUNTRY)
        case 2:
            self.loadUsers()
        default:
            return
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isUsingSearchController() ? 1 : self.sectionTitleList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isUsingSearchController() ? self.filteredUsers.count : self.allUsersGrouped[self.sectionTitleList[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.Identifier.Cell.user, for: indexPath) as? UserTableViewCell else { fatalError() }
        
        var user: User
        if isUsingSearchController() {
            user = self.filteredUsers[indexPath.row]
        } else {
            let users = self.allUsersGrouped[self.sectionTitleList[indexPath.section]]
            user = users![indexPath.row]
        }
        cell.delegate = self
        cell.configureUserCell(with: user, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isUsingSearchController() ? "" : self.sectionTitleList[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return isUsingSearchController() ? nil : self.sectionTitleList
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser: User
        if isUsingSearchController() {
            selectedUser = self.filteredUsers[indexPath.row]
        } else {
            let users = self.allUsersGrouped[self.sectionTitleList[indexPath.section]]
            selectedUser = users![indexPath.row]
        }
        
        // start create recent private chat
        startPrivateChat(currentUser: dbService.currentUser()!, with: selectedUser)
        
//        // goto Chatting View Controller
//        let chattingVC = ChattingViewController()
//        chattingVC.hidesBottomBarWhenPushed = true
//        chattingVC.chatRoomId = generateChatRoomId(currentUser: dbService.currentUser()!, with: selectedUser)
//        chattingVC.title = selectedUser.fullName
//        self.navigationController?.pushViewController(chattingVC, animated: true)
    }
    
    
}

extension UsersTableViewController: UserTableViewCellDelegate {
    func didTapAvatarImage(at indexPath: IndexPath) {
        let selectedUser: User!
        if isUsingSearchController() {
            selectedUser = self.filteredUsers[indexPath.row]
        } else {
            let selectedTitle = self.sectionTitleList[indexPath.section]
            selectedUser = self.allUsersGrouped[selectedTitle]![indexPath.row]
        }
        let vc = Storyboard.profileView
        vc.user = selectedUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension UsersTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.filteredUsers = self.allUsers.filter({ (user) -> Bool in
            return user.firstName.lowercased().contains(searchController.searchBar.text!.lowercased())
        })
        self.tableView.reloadData()
    }
}
