//
//  GroupCreateCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 12/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class GroupCreateCell: UITableViewCell {

    @IBOutlet weak var userEmailIdLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.clipToCircularImageView()
        // Initialization code
    }

    func updateCell(filteredUser:User) {
        
        userEmailIdLabel.text = filteredUser.email
        userImageView.setImageWithOptionalUrl(filteredUser.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        userNameLabel.text = filteredUser.displayName
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
