//
//  PersonalInfoCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 11/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class PersonalInfoCell : UITableViewCell {
    
    @IBOutlet var cellImageView: UIImageView!
        @IBOutlet var userProfileIcon: UIImageView!
    @IBOutlet var userProfileData: UILabel!
    @IBOutlet var userProfileType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCellData(profileData : String? , profileType : String) {
            userProfileData.text = profileData ?? "No Entry"
        userProfileData.backgroundColor = UIColor.tableViewCellBackGroundColor()
        userProfileType.backgroundColor = UIColor.tableViewCellBackGroundColor()
        userProfileType.text = profileType.uppercaseString
    }
    
    func createCellImageView(index: NSInteger, count : NSInteger) {
        var image : UIImage
        let myInsets : UIEdgeInsets = UIEdgeInsetsMake(16,16 ,16,16 )
        switch index {
        case (count - 1):
            image = AssetImage.Slice3.image
            
            
        default:
            image = AssetImage.Slice2.image
        }
        image = image.resizableImageWithCapInsets(myInsets)
        cellImageView.image = image
    }
}
