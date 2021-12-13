//
//  GenericFeedDetail.swift
//  Workbox
//
//  Created by Chetan Anand on 28/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class GenericFeedDetail: UITableViewCell {

    @IBOutlet weak var userProfileImage : UIImageView!
    @IBOutlet weak var userNameLabel : UILabel!
    @IBOutlet weak var creationDateLabel : UILabel!
    @IBOutlet weak var contentLabel : UILabel!
    @IBOutlet weak var numberOfLikesAndCommentLabel : UILabel!
    
//    let actionArray = Parser.fetchActions(forType: CardType.FeedType  ,forSubtype: CardSubtype.UserMessageType, )
    
    @IBOutlet weak var cardActionView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//       actionArray.removeObject(CardAction.Comment)

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    ///Updating Cell Data
    func updateCellWithData(cellData : GenericFeed?,sentBy : UIViewController){
        
        guard let unwrappedCellData = cellData else{
            return
        }
        let actionProp = ActionProperty()
        actionProp.workitemId = unwrappedCellData.id
        actionProp.likedBySelf = unwrappedCellData.likedBySelf
        actionProp.senderViewController = sentBy
        


        userProfileImage.setImageWithOptionalUrl(unwrappedCellData.createdBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)

        userNameLabel.text = unwrappedCellData.createdBy?.displayName
        contentLabel.text = unwrappedCellData.contentString ?? ""
        creationDateLabel.text = unwrappedCellData.createdAt?.timeAgo
        
        setNumberOfLikesAndComment(unwrappedCellData.likeCountInt, numberOfComments: unwrappedCellData.commentsCountInt, likesEnabled: true, commentEnabled: true)
        
    }
    
    
    func setNumberOfLikesAndComment(numberOfLikes: Int?, numberOfComments: Int?, likesEnabled: Bool, commentEnabled: Bool){
        numberOfLikesAndCommentLabel.text = Helper.likeCommentAttachmentString(numberOfLikes, numberOfComments: numberOfComments, likesEnabled: likesEnabled, commentEnabled: commentEnabled, numberOfAttachments: nil, attachmentCountEnabled: false)
    }

}
