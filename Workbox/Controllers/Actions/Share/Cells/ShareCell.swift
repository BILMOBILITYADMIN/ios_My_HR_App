//
//  ShareCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 04/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class ShareCell: UITableViewCell {

    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var imageIconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
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
        
//        if isSelected == true
//        {
//            checkBoxButton.setImage(UIImage(named:"Checked_checkBox"), forState: UIControlState.Normal)
//        }
//        else { checkBoxButton.setImage(UIImage(named:"Unchecked_checkBox"), forState: UIControlState.Normal)
//        }
         nameLabel.text = filteredUserNames[indexPath.row].displayName
        imageIconImageView.setImageWithOptionalUrl(filteredUserNames[indexPath.row].avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        imageIconImageView.clipToCircularImageView()
        
    }
    
    func updateCell(indexPath:NSIndexPath,filteredGroupNames:[Group],selectedItems:NSArray){
        var isSelected = false
        let selectedId = filteredGroupNames[indexPath.row].groupId!
        for object in selectedItems {
            if object is Group {
                let group = object as! Group
                if group.groupId == selectedId {
                    isSelected = true
                    break
                }
            }
        }
        

//        if isSelected == true  {
//            checkBoxButton.setImage(UIImage(named:"Checked_checkBox"), forState: UIControlState.Normal)
//        }
//        else{
//            checkBoxButton.setImage(UIImage(named:"Unchecked_checkBox"), forState: UIControlState.Normal)
//        }
        
        nameLabel.text = filteredGroupNames[indexPath.row].name
    }

}
