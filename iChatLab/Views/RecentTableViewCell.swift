//
//  RecentTableViewCell.swift
//  iChatLab
//
//  Created by Han Luong on 3/28/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit

protocol RecentTableViewCellDelegate {
    func didTapOnAvatarImage(at indexPath: IndexPath)
}

class RecentTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    @IBOutlet weak var backgroundCounter: UIView!
    
    // MARK: - Vars
    var delegate: RecentTableViewCellDelegate?
    var indexPath: IndexPath!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layoutUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func layoutUI() {
        self.avatarImageView.styleImageView()
        self.backgroundCounter.layer.cornerRadius = self.backgroundCounter.frame.size.width/2
        self.avatarImageView.isUserInteractionEnabled = true
    }
    
    func configureRecentCell(_ recent: Recent, at indexPath: IndexPath) {
        Common.imageFromdata(imageData: recent.avatar, withBlock: { (image) in
            if let image = image {
                self.avatarImageView.image = image
                
                // Add tapGestureRecognizer for image
                self.indexPath = indexPath
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didImageTap))
                self.avatarImageView.addGestureRecognizer(tapGesture)
            }
        })
        self.fullNameLabel.text = recent.name
        self.dateLabel.text = Date.timeElapsed(date: Date.dateFormatter().date(from: recent.date)!)
        self.lastMessageLabel.text = recent.lastMessage
        if recent.counter > 0 {
            self.counterLabel.text = "\(recent.counter!)"
            self.backgroundCounter.isHidden = false
            self.counterLabel.isHidden = false
        } else {
            self.counterLabel.isHidden = true
            self.backgroundCounter.isHidden = true
        }
    }
    
    @objc func didImageTap() {
        self.delegate?.didTapOnAvatarImage(at: self.indexPath)
    }

}
