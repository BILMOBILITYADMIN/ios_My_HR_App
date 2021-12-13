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
    @IBOutlet weak var notificationTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(notificationDict : Notification,notification : NSMutableAttributedString, time: String) {
        notificationLabel.attributedText = notification
        notificationTime.text = time
        notificationTime.textColor = UIColor.lightGrayColor()
        profileImageView.layer.cornerRadius = 24.5
        profileImageView.clipsToBounds = true
        profileImageView.image = AssetImage.placeholderProfileIcon.image
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let imageUrl = notificationDict.sender?.avatarURLString{
            //profileImageView.kf_setImageWithURL(imageUrl)
            let urlString = ConstantServer.imageRelativeUrl + imageUrl
            let avatarThumbnailImageUrl = NSURL(string: urlString)
            profileImageView.setImageWithOptionalUrl(avatarThumbnailImageUrl, placeholderImage:  AssetImage.placeholderProfileIcon.image)
            profileImageView.clipsToBounds = true
        }

//        let imageURL = notificationDict.sender?.avatarURLString ?? ""
//        profileImageView.setImageWithOptionalUrl(imageURL.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        
    }
}
