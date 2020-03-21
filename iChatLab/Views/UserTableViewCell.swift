//
//  UserTableViewCell.swift
//  iChatLab
//
//  Created by Han Luong on 3/17/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate {
    func didTapAvatarImage(at indexPath: IndexPath)
}

class UserTableViewCell: UITableViewCell {

    // MARK: - Vars
    var indexPath: IndexPath!
    var delegate: UserTableViewCellDelegate?
    
    // MARK: - IDOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupUI() {
        avatarImageView.styleImageView()
        
        let tapOnAvatarImage = UITapGestureRecognizer(target: self, action: #selector(didTapOnImage))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapOnAvatarImage)
    }
    
    func configureUserCell(with user: User, indexPath: IndexPath) {
        self.indexPath = indexPath
        Common.imageFromdata(imageData: user.avatar, withBlock: { (image) in
            if let image = image {
                self.avatarImageView.image = image
            }
        })
        
        self.userNameLabel.text = user.fullName
    }
    
    @objc func didTapOnImage() {
        print("user tapped at [\(self.indexPath.row),\(self.indexPath.section)]")
        delegate?.didTapAvatarImage(at: self.indexPath)
    }
}
