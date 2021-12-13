//
//  NotificationCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 23/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(text1: String) {
        notificationLabel.text = text1
        profileImageView.layer.cornerRadius = 24.5
        profileImageView.clipsToBounds = true
        profileImageView.image = AssetImage.ProfileImage.image
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
    }
}
