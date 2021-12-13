//
//  GroupTableViewCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 12/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    @IBOutlet weak var groupMembersLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        groupImageView.clipToCircularImageView()
        // Initialization code
    }

    func updateCellWithGroup(group:Group)
    {
        groupNameLabel.text = group.name
        
        var memberNames = [String]()
        for user in group.members! as [User] {
            memberNames.append(user.displayName!.capitalizedString)
        }
        groupMembersLabel.text = memberNames.joinWithSeparator(", ")
            
        groupImageView.image = UIImage(named: "groups_icon")
        groupImageView.layer.cornerRadius = (groupImageView?.frame.size.width)! / 2
        groupImageView.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
