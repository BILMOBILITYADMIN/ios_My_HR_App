//
//  NewsFeedDetail.swift
//  Workbox
//
//  Created by Chetan Anand on 28/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class NewsFeedDetail: UITableViewCell {
    
    @IBOutlet weak var titleImage : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var subtitleLabel : UILabel!
    @IBOutlet weak var contentLabel : UILabel!
    @IBOutlet weak var likeAndCommentLabel : UILabel!
    @IBOutlet weak var cardActionView: UIView!

//    let actionArray = Parser.fetchActions(forType: CardType.FeedType  ,forSubtype: CardSubtype.NewsFeedType, forCardStatus: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        actionArray.removeObject(CardAction.Comment)

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    ///Updating Cell Data
    func updateCellWithData(cellData : NewsFeed?,sentBy : UIViewController){
        
        guard let unwrappedCellData = cellData else{
            return
        }

        var actionProp = ActionProperty()
        actionProp.workitemId = unwrappedCellData.id
        actionProp.likedBySelf = unwrappedCellData.likedBySelf
        actionProp.senderViewController = sentBy
        
        titleLabel.text = unwrappedCellData.titleString
        contentLabel.text = unwrappedCellData.descriptionString
        titleImage.setImageWithOptionalUrlWithoutPlaceholder(unwrappedCellData.createdBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail))
        subtitleLabel.text = unwrappedCellData.createdAt?.timeAgo
        
        likeAndCommentLabel.text = Helper.likeCommentAttachmentString(unwrappedCellData.likeCountInt, numberOfComments: unwrappedCellData.comments?.count , likesEnabled: unwrappedCellData.likeCountEnabled, commentEnabled: unwrappedCellData.commentCountEnabled, numberOfAttachments: nil, attachmentCountEnabled: false)
        
    }

}
