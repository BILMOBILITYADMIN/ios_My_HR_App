//
//  ShareCardCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 07/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class ShareCardCell: UITableViewCell {
    

    @IBOutlet weak var imageIconImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        UITableViewCell.setCellBackgroundView(self)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateCardCell(workItemDetail : AnyObject?){
        
//        containerView.
//        var image : UIImage
//        let myInsets : UIEdgeInsets = UIEdgeInsetsMake(16,16 ,16,16 )
//        switch index {
//        case (count - 1):
//            image = AssetImage.Slice3.image
        
            
//        default:
//            image = AssetImage.ShareCellBackground.image
//        }
//        image = image.resizableImageWithCapInsets(myInsets)
//        containerView.backgroundColor = UIColor(patternImage: image)
        
        switch(workItemDetail){
        case is GenericFeed:
            
            let cardDetail = workItemDetail as! GenericFeed
            textView.text = cardDetail.descriptionString
            titleLabel.text = cardDetail.titleString
//            if let imageForCard = cardDetail.createdBy?.avatarURL{
            imageIconImageView.setImageWithOptionalUrl(cardDetail.createdBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.InsertPhoto.image)
            //            }
//            else {
//                imageIconImageView.image = AssetImage.InsertPhoto.image
//            }
            
        case is NewsFeed:
            
            let cardDetail = workItemDetail as! NewsFeed
            textView.text = cardDetail.descriptionString
            titleLabel.text = cardDetail.titleString
//            if let imageForCard = cardDetail.createdBy?.avatarURL{
                imageIconImageView.setImageWithOptionalUrl(cardDetail.createdBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage:  AssetImage.InsertPhoto.image)
//            }
//            else {
//                imageIconImageView.image = AssetImage.InsertPhoto.image
//            }
            
        case is NewJoinee:
            
            let cardDetail = workItemDetail as! NewJoinee
            textView.text = cardDetail.descriptionString
            titleLabel.text = cardDetail.titleString
//            if let imageForCard = cardDetail.createdBy?.avatarURL{
                imageIconImageView.setImageWithOptionalUrl(cardDetail.createdBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage:  AssetImage.InsertPhoto.image)
//            }
//            else {
//                imageIconImageView.image = AssetImage.InsertPhoto.image
//            }
            
        case is GenericFeed:
            
            let cardDetail = workItemDetail as! GenericFeed
            textView.text = cardDetail.descriptionString
            titleLabel.text = cardDetail.titleString
//            if let imageForCard = cardDetail.createdBy?.avatarURL{
                imageIconImageView.setImageWithOptionalUrl(cardDetail.createdBy?.avatarURLString?.toNSURL(.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
//            }
            //            else {
            //                imageIconImageView.image = AssetImage.InsertPhoto.image
            //            }
            
            
        default:
            print("")
        }
    }
}
