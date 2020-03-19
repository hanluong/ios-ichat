//
//  UserTableViewCell.swift
//  iChatLab
//
//  Created by Han Luong on 3/17/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

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

        // Configure the view for the selected state
    }
    
    private func setupUI() {
        avatarImageView.styleImageView()
    }
    
    func configureUserCell(with user: User) {
        Common.imageFromdata(imageData: user.avatar, withBlock: { (image) in
            if let image = image {
                self.avatarImageView.image = image
            }
        })
        self.userNameLabel.text = user.fullName
    }

}
