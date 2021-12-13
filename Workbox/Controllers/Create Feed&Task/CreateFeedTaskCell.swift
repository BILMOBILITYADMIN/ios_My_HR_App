//
//  CreateFeedTaskCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 05/07/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class CreateFeedTaskCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCell(indexPath:NSIndexPath,filteredUserNames:[User],selectedItems:NSArray) {
        
        var isSelected = false
        let selectedId = filteredUserNames[indexPath.row].id!
        for object in selectedItems {
            if object is User {
                let user = object as! User
                if user.id == selectedId {
                    isSelected = true
                    break
                }
            }
        }
        userNameLabel.text = filteredUserNames[indexPath.row].displayName
        userImageView.setImageWithOptionalUrl(filteredUserNames[indexPath.row].avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        userImageView.clipToCircularImageView()
        
    }
}
