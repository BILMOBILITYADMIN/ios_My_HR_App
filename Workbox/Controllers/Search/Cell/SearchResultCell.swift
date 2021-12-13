//
//  SearchResultCell.swift
//  Workbox
//
//  Created by Chetan Anand on 06/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Kingfisher

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var profileImageView: ActionImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
               // Initialization code
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        profileImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutIfNeeded() {

    }
    
    func updateCellData(user : User){
        profileImageView.user = user
        profileImageView.addImageAction(GestureType.LongPress)
        if let imageUrl = user.avatarURLString{
            //profileImageView.kf_setImageWithURL(imageUrl)
            let urlString = ConstantServer.imageRelativeUrl + imageUrl
            let avatarThumbnailImageUrl = NSURL(string: urlString)
            profileImageView.setImageWithOptionalUrl(avatarThumbnailImageUrl, placeholderImage:  AssetImage.placeholderProfileIcon.image)
            
            profileImageView.clipsToBounds = true
        }
        
        
        if let nameString = user.displayName{
            nameLabel.text = nameString
        
        }
        
    }
}
