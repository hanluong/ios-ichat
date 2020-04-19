//
//  RecentsViewController.swift
//  iChatLab
//
//  Created by Han Luong on 3/19/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RecentsViewController: UIViewController {

    // MARK: - Variables
    private let dbService = DatabaseService.instance
    private var recentChats = [Recent]()
    private var filteredRecentChats = [Recent]()
    private var recentListener: ListenerRegistration!
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // setup table header view
        setupTableHeaderView()
        self.tableView.tableFooterView = UIView()
        
        loadAllRecentsChat()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recentListener.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add search controller
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = true

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    private func isUsingSearchController() -> Bool {
        if searchController.isActive,
            let searchText = searchController.searchBar.text,
            searchText.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            return true
        } else {
            return false
        }
    }
    
    private func loadAllRecentsChat() {
        recentListener = reference(.Recent).whereField(kUSER_ID, isEqualTo: dbService.currentUserId()).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else { return }
            self.recentChats = []
            self.filteredRecentChats = []
            if !snapshot.isEmpty {
                let sortedRecents = snapshot.documents.sorted { ($0.data()[kDATE] as! String) < ($1.data()[kDATE] as! String)}
                for sortedRecent in sortedRecents {
                    let recentDict = sortedRecent.data()
                    if (recentDict[kLAST_MESSAGE] as! String).trimmingCharacters(in: .whitespacesAndNewlines) != "" &&
                        recentDict[kCHATROOM_ID] != nil && recentDict[kRECENT_ID] != nil {
                        self.recentChats.append(Recent(dictionary: recentDict))
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    private func setupTableHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
        headerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 1, width: tableView.frame.width, height: 1))
        lineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        let createNewGroupButton = UIButton(frame: CGRect(x: headerView.frame.width - 150, y: 0, width: 100, height: 40))
        createNewGroupButton.setTitle("New Group", for: .normal)
        createNewGroupButton.setTitleColor(#colorLiteral(red: 0.3254901961, green: 0.4196078431, blue: 0.7764705882, alpha: 1), for: .normal)
        createNewGroupButton.addTarget(self, action: #selector(createNewGroupBtnPressed), for: .touchUpInside)
        
        headerView.addSubview(createNewGroupButton)
        headerView.addSubview(lineView)
        self.tableView.tableHeaderView = headerView
    }
    
    @objc func createNewGroupBtnPressed() {
        print("createNewGroupBtnPressed() pressed")
    }
}

// MARK: - Extension UITableViewDelegate, UITableViewDataSource

extension RecentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let selectedRecent: Recent!
        if isUsingSearchController() {
            selectedRecent = self.filteredRecentChats[indexPath.row]
        } else {
            selectedRecent = self.recentChats[indexPath.row]
        }
        
        // mute action
        let muteAction = UIContextualAction(style: .normal, title: "Mute") { (_, _, completion) in
            print("TODO: mute action will does here")
        }
        muteAction.backgroundColor = #colorLiteral(red: 0.3254901961, green: 0.4196078431, blue: 0.7764705882, alpha: 1)
        
        // delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in
            deleteRecentById(selectedRecent.id) { (success) in
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
    
        let swipeActions = UISwipeActionsConfiguration(actions: [muteAction, deleteAction])
        swipeActions.performsFirstActionWithFullSwipe = false
        return swipeActions
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isUsingSearchController() ? self.filteredRecentChats.count : self.recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.Identifier.Cell.recent, for: indexPath) as? RecentTableViewCell else { fatalError("ERROR! not found cell with identifier \(Storyboard.Identifier.Cell.recent)")}
        
        let recent: Recent!
        if isUsingSearchController() {
            recent = self.filteredRecentChats[indexPath.row]
        } else {
            recent = self.recentChats[indexPath.row]
        }
        
        cell.configureRecentCell(recent, at: indexPath)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // recreate recent chat for who had deleted
        let selectedRecent: Recent
        if isUsingSearchController() {
            selectedRecent = filteredRecentChats[indexPath.row]
        } else {
            selectedRecent = recentChats[indexPath.row]
        }
        recreateRecentChat(selectedRecent)
        
        // goto Chatting View Controller
        let chattingVC = ChattingViewController()
        chattingVC.hidesBottomBarWhenPushed = true
        chattingVC.chatRoomId = selectedRecent.chatRoomId
        chattingVC.membersIdToPush = selectedRecent.membersId
        chattingVC.type = selectedRecent.type
        navigationController?.pushViewController(chattingVC, animated: true)
    }
}

// MARK: - Extension RecentTableViewCellDelegate
extension RecentsViewController: RecentTableViewCellDelegate {
    func didTapOnAvatarImage(at indexPath: IndexPath) {
        // get user from selected recent image
        var selectedRecent: Recent!
        if isUsingSearchController() {
            selectedRecent = self.filteredRecentChats[indexPath.row]
        } else {
            selectedRecent = self.recentChats[indexPath.row]
        }
        
        if selectedRecent.type == kPRIVATE {
            let index = selectedRecent.membersId.firstIndex(of: dbService.currentUserId())
            selectedRecent.membersId.remove(at: index!)
        } else {
            // group
            print("TODO: for group image tapped")
        }
        
        reference(.User).document(selectedRecent.membersId[0]).getDocument { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                print("ERROR! not found userId \(selectedRecent.userId as String)")
                return
            }
            if let userDict = snapshot.data() {
                let selectedUser = User(dictionary: userDict)
                let vc = Storyboard.profileView
                vc.user = selectedUser
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

// MARK: - Extension UISearchResultsUpdating
extension RecentsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.filteredRecentChats = self.recentChats.filter({ (recent) -> Bool in
            return recent.name.lowercased().contains(searchController.searchBar.text!.lowercased())
        })
        self.tableView.reloadData()
    }
}
