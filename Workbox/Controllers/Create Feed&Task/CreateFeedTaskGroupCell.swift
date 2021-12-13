//
//  CreateFeedTaskGroupCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 05/07/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class CreateFeedTaskGroupCell: UITableViewCell {
    
    @IBOutlet weak var groupMembersLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     checkBoxButton.userInteractionEnabled = false
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(group:Group,selectedItems:NSMutableArray){
        
        
        
        var isSelected = false
        let selectedId = group.groupId
        
        for object in selectedItems {
            if object is Group {
                let group = object as! Group
                if group.groupId == selectedId {
                    isSelected = true
                    break
                }
            }
        }
        
        if isSelected == true
        {
            checkBoxButton.setImage(AssetImage.check.image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
            checkBoxButton.imageView?.tintColor = UIColor.navBarColor()
          
        }
        else {
            checkBoxButton.setImage(AssetImage.uncheck.image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
            checkBoxButton.imageView?.tintColor = UIColor.navBarColor()
        }
        
        groupNameLabel.text = group.name
        var memberNames = [String]()
        for user in group.members! as [User] {
            memberNames.append(user.displayName!.capitalizedString)
        }
        
        groupMembersLabel.text = memberNames.joinWithSeparator(", ")
        
        groupImageView.setImageWithOptionalUrl(group.imageName?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.GroupIcon.image)
        groupImageView.clipToCircularImageView()
    }
    

}
