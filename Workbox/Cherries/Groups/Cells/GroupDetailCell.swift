//
//  GroupDetailsTableViewCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 12/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class GroupDetailCell: UITableViewCell {
    
    @IBOutlet weak var userRoleLabel: UILabel!
    @IBOutlet weak var groupMemberImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        groupMemberImageView.clipToCircularImageView()
        // Initialization code
    }
    
    func updateCell(indexPath:NSIndexPath, group:Group) {
        
        userNameLabel.text = group.members?[indexPath.row].displayName?.capitalizedString
        userRoleLabel.text = group.members?[indexPath.row].designation?.capitalizedString
        groupMemberImageView.setImageWithOptionalUrl(group.members![indexPath.row].avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        groupMemberImageView.layer.cornerRadius = groupMemberImageView.frame.size.height/2
        groupMemberImageView?.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
