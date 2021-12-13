//
//  UserMessageDetail.swift
//  Workbox
//
//  Created by Chetan Anand on 17/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class UserMessageDetail: UITableViewCell {

    @IBOutlet weak var userProfileImage : UIImageView!
    @IBOutlet weak var userNameLabel : UILabel!
    @IBOutlet weak var creationDateLabel : UILabel!
    @IBOutlet weak var contentLabel : UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberOfLikesAndCommentLabel : UILabel!
    @IBOutlet weak var cardActionView: UIView!

    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var galleryViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cardActionViewHeightConstraint: NSLayoutConstraint!

//    let actionArray = Parser.fetchActions(forType: CardType.FeedType  ,forSubtype: CardSubtype.UserMessageType, forCardStatus: CardStatus.)
    

//    let actionPlaceholderButtons = [ActionButton(),ActionButton(),ActionButton(),ActionButton()]
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        UITableViewCell.setActionButtons(cardActionView,actionButtons: actionPlaceholderButtons ,actionArray: actionArray)
//        actionArray.removeObject(CardAction.Comment)

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
//        updateActionButtons(actionArray, workitemId: unwrappedCellData.id!, senderViewController: UIViewController(), likedBySelfValue: unwrappedCellData.likedBySelf)
        
        var actionProp = ActionProperty()
        actionProp.workitemId = unwrappedCellData.id
        actionProp.likedBySelf = unwrappedCellData.likedBySelf
        actionProp.senderViewController = sentBy
        
        cardActionView.createActionButtons(true, actionViewHeightConstraint: cardActionViewHeightConstraint, actionViewInitialHeight: ConstantUI.actionViewHeight, actionArray: unwrappedCellData.defaultCardActions, actionProperty: actionProp, maximumNumberOfButtonsToShow: nil)
        
        galleryView.createStackOfAttachments(true,  galleryViewHeightConstraint: galleryViewHeightConstraint, attachmentArray: unwrappedCellData.attachments, numberOfElementsInEachRow: 2, maximumNumberOfElementsToShow: nil)
        
        userProfileImage.setImageWithOptionalUrl(unwrappedCellData.createdBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        
        userNameLabel.text = unwrappedCellData.createdBy?.displayName
        
        setDescription(unwrappedCellData.descriptionString, descriptonEnabled: true)
        setTitle(unwrappedCellData.titleString, titleEnabled: true)
        
//        contentLabel.text = 
        
        creationDateLabel.text = unwrappedCellData.createdAt?.timeAgo
        
        numberOfLikesAndCommentLabel.text = Helper.likeCommentAttachmentString(unwrappedCellData.likeCountInt, numberOfComments: unwrappedCellData.commentsCountInt, likesEnabled: true,commentEnabled: true, numberOfAttachments: nil, attachmentCountEnabled: false)

    }
    
    func setTitle(titleText : String?, titleEnabled : Bool){
        titleLabel.numberOfLines = 0
        if let unwrappedText = titleText where unwrappedText.characters.count > 0 && titleEnabled {
            
            titleLabel.text = unwrappedText
            
        }
        else{
            
            titleLabel.text = ""
        }
    }
    
    func setDescription(descriptionText : String?, descriptonEnabled : Bool){
        contentLabel.numberOfLines = 0
        if let unwrappedText = descriptionText where unwrappedText.characters.count > 0 && descriptonEnabled {
//            print(descriptionText)
            
            contentLabel.text = unwrappedText
            
        }
        else{
            
            contentLabel.text = ""
        }
    }

    
}
