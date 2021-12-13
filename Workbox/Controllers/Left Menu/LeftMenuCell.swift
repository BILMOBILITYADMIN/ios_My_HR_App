//
//  LeftMenuCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 14/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Kingfisher

class LeftMenuCell: UITableViewCell {

    @IBOutlet var leftMenuTitle: UILabel!
    @IBOutlet var leftMenuIconView: UIImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateLeftMenuCell(iconName iconName: String?, labelName: String) {
        leftMenuTitle.text = labelName
        if let iconName = iconName {
//            leftMenuIconView.kf_setImageWithURL(Helper.attachmentURL(String(ImageSize.Thumbnail), imageName: iconName), placeholderImage:AssetImage.PlaceholderIcon.image)
            
            leftMenuIconView.setImageWithOptionalUrl(Helper.nsurlFromStringWithImageSize(iconName, imageSize: ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.PlaceholderIcon.image)
            leftMenuIconView.image = UIImage(named: iconName)

        }
    }
}
