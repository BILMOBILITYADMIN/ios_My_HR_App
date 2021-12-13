//
//  UserMessage01Card.swift
//  Workbox
//
//  Created by Chetan Anand on 16/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.

import UIKit

class UserMessage01Card: UITableViewCell {
    
    //Outlets for Data
    
    @IBOutlet weak var lastActivityLabel: UILabel!
    @IBOutlet weak var lastActivityLineView: UIView!
    @IBOutlet weak var lastActivityDateLabel: UILabel!
    @IBOutlet weak var lineImageViewVerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelBottomConstraint: NSLayoutConstraint!

    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionLabelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var numberOfLikesAndCommentsLabel: UILabel!
    @IBOutlet weak var numberOfLikesAndCommentLabelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var cardDateLabel: UILabel!
    @IBOutlet weak var commentUserProfileImageView: UIImageView!
    @IBOutlet weak var commentUserNameLabel: UILabel!
    @IBOutlet weak var commentBodyLabel: UILabel!
    
    @IBOutlet weak var galleryView: UIView!
    
    
    //Outlets for Rendering
    @IBOutlet weak var cardActionView: UIView!
    @IBOutlet weak var cardCommentView: UIView!
    @IBOutlet weak var cardActionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardCommentViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var galleryViewHeightConstraint: NSLayoutConstraint!
    
    
    
    var cardImageViewHeightInitialValue: CGFloat!
    var cardActionViewHeightInitialValue : CGFloat!
    var cardCommentViewHeightInitialValue : CGFloat!
    var cardGalleryViewHeightInitialValue : CGFloat!
    
    
    var numberOfLikes : Int = 0
    var numberOfComments : Int = 0
    var likedBySelf : Bool = false
    
    
    var workitemId : String?
//    let actionArrayValue = Parser.fetchActions(forType: CardType.FeedType, forSubtype: CardSubtype.UserMessageType)
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UITableViewCell.setCellBackgroundView(self)
        
        cardCommentViewHeightInitialValue = cardCommentViewHeightConstraint.constant
        
    }
    
    
    
    ///Updating Cell Data
    func updateCellWithData(cellData : GenericFeed?,sentBy : UIViewController){
        
        
        guard let unwrappedCellData = cellData else{
            return
        }
        
        
        workitemId = unwrappedCellData.id
        
        var actionProp = ActionProperty()
        actionProp.workitemId = unwrappedCellData.id
        actionProp.likedBySelf = unwrappedCellData.likedBySelf
        actionProp.senderViewController = sentBy
        
        cardActionView.createActionButtons(unwrappedCellData.actionBarEnabled, actionViewHeightConstraint: cardActionViewHeightConstraint, actionViewInitialHeight: ConstantUI.actionViewHeight, actionArray: unwrappedCellData.defaultCardActions, actionProperty: actionProp, maximumNumberOfButtonsToShow: 3)
        
        
        
        let attributedString =  Helper.getBoldAttributtedString(unwrappedCellData.commonCardFields?.userDisplayName,text2:unwrappedCellData.commonCardFields?.lastActivityText,font: 13)

        
        
        setLastActivityBarElements(attributedString,dateString: unwrappedCellData.commonCardFields?.lastActivityTime?.timeAgo  , lastActivityBarEnabled: unwrappedCellData.latestActivityBarEnabled)
        
        setTitleLabel(true, text: unwrappedCellData.titleString)
        
        setDescriptionLabel(unwrappedCellData.descriptionEnabled, text: unwrappedCellData.descriptionString)
        
        setLikesAndCommentLabel(Helper.likeCommentAttachmentString(unwrappedCellData.likeCountInt, numberOfComments: unwrappedCellData.commentsCountInt, likesEnabled: unwrappedCellData.likeCountEnabled,commentEnabled: unwrappedCellData.commentCountEnabled, numberOfAttachments: unwrappedCellData.attachments?.count, attachmentCountEnabled: true))
        
        galleryView.createStackOfAttachments(unwrappedCellData.galleryEnabled,  galleryViewHeightConstraint: galleryViewHeightConstraint, attachmentArray: unwrappedCellData.attachments, numberOfElementsInEachRow: 4, maximumNumberOfElementsToShow: 4)
        
        setCommentBarElements(unwrappedCellData.comments?.last?.commentedBy?.displayName, commentText: unwrappedCellData.comments?.last?.commentText, commentUserProfileImageUrlString: unwrappedCellData.comments?.last?.commentedBy?.avatarURLString, isEnabled: unwrappedCellData.commentBarEnabled)
        
        
        cardDateLabel.text = unwrappedCellData.createdAt?.timeAgo ?? ""
        userNameLabel.text = unwrappedCellData.createdBy?.displayName
        userImageView.setImageWithOptionalUrl(unwrappedCellData.createdBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setLastActivityBarElements(text : NSMutableAttributedString?,dateString : String?, lastActivityBarEnabled : Bool){
        lastActivityLabel.numberOfLines = 0
        if let unwrappedText = text where unwrappedText.length > 0 && lastActivityBarEnabled {
            lastActivityLabel.hidden = false
            lastActivityLineView.hidden = false
            lastActivityLineView.hidden = false
            
            lineImageViewVerticalConstraint.constant = CGFloat(2 * ConstantUI.defaultPadding)
            lastActivityLabel.attributedText = unwrappedText
            lastActivityDateLabel.text = dateString ?? ""
            
        }
        else{
            lastActivityLabel.hidden = true
            lastActivityLineView.hidden = true
            lastActivityLineView.hidden = true
            
            lineImageViewVerticalConstraint.constant = 0
            lastActivityLabel.text = ""
            lastActivityDateLabel.text = ""
        }
    }
    
    func setTitleLabel(isEnabled : Bool, text : String?){
        guard let unwrappedText = text where unwrappedText.characters.count > 0 && isEnabled else{
            titleLabel.text = ""
            titleLabelBottomConstraint.constant = 0

            return
        }
        titleLabel.text = unwrappedText
        titleLabelBottomConstraint.constant = ConstantUI.defaultPaddingByTwo

    }

    
    func setDescriptionLabel(isEnabled : Bool, text : String?){
        guard let unwrappedText = text where unwrappedText.characters.count > 0 && isEnabled else{
            descriptionLabel.text = ""
            descriptionLabelBottomConstraint.constant = 0
            return
        }
        descriptionLabel.text = unwrappedText
        descriptionLabelBottomConstraint.constant = ConstantUI.defaultPadding
    }
    
    func setLikesAndCommentLabel(text : String?){
        guard let unwrappedText = text where unwrappedText.characters.count > 0 else{
            numberOfLikesAndCommentsLabel.text = ""
            numberOfLikesAndCommentLabelBottomConstraint.constant = 0
            return
        }
        numberOfLikesAndCommentsLabel.text = unwrappedText
        numberOfLikesAndCommentLabelBottomConstraint.constant = ConstantUI.defaultPadding
    }
    
    func setCommentBarElements(commentUsernameText : String?,commentText : String?, commentUserProfileImageUrlString: String?, isEnabled : Bool){
        
        if let unwrappedcommentUsernameText = commentUsernameText where isEnabled {
            cardCommentView.hidden = false
            commentUserNameLabel.hidden = false
            commentBodyLabel.hidden = false
            commentUserProfileImageView.hidden = false
            cardCommentViewHeightConstraint.constant = ConstantUI.commentViewHeight
            commentUserNameLabel.text = unwrappedcommentUsernameText
            commentBodyLabel.text = commentText ?? ""
            commentUserProfileImageView.setImageWithOptionalUrl(commentUserProfileImageUrlString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        }
        else{
            cardCommentView.hidden = true
            commentUserNameLabel.hidden = true
            commentBodyLabel.hidden = true
            commentUserProfileImageView.hidden = true
            cardCommentViewHeightConstraint.constant = 0
        }
    }
}
