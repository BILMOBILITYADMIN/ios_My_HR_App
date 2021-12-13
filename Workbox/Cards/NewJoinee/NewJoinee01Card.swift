//
//  NewJoinee01Card.swift
//  Workbox
//
//  Created by Chetan Anand on 08/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Kingfisher


class NewJoinee01Card: UITableViewCell {
    
    @IBOutlet weak var newJoineeImage: UIImageView!
    @IBOutlet weak var newJoineeNameLabel: UILabel!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    
    @IBOutlet weak var cardActionView: UIView!
    var numberOfLikes : Int = 0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        UITableViewCell.setCellBackgroundView(self)
        
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func likeButtonTapped(sender: AnyObject) {
        print(#function)
    }
    
 
    
    func updateCellWithData(cellData : NewJoinee?,sentBy : UIViewController){
        //Feeding Data to outlets
        guard let unwrappedCellData = cellData else{
            return
        }
        
        
        
        newJoineeNameLabel.text = unwrappedCellData.titleString
        
        
        newJoineeImage.setImageWithOptionalUrl(unwrappedCellData.createdBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.placeholderProfileIcon.image)
        
        numberOfLikesLabel.text = nil
        
        
    }
}


