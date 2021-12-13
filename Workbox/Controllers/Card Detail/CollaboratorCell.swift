//
//  CollaboratorCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 04/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class CollaboratorCell: UITableViewCell {

    @IBOutlet weak var collaboratorProfileImage: ActionImageView!
    @IBOutlet weak var collaboratorNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        collaboratorProfileImage.addImageAction(GestureType.LongPress)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateCell(user:User){
        collaboratorProfileImage.user = user
        collaboratorProfileImage.addImageAction(GestureType.LongPress)
        collaboratorProfileImage.setImageWithOptionalUrl(user.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        collaboratorProfileImage.clipToCircularImageView()
        collaboratorNameLabel.text = user.displayName
    }
}
