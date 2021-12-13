//
//  BMPApprovalCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 17/06/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class BPMApprovalCell: UITableViewCell {
    
    @IBOutlet weak var lastActivityLabel: UILabel!
    @IBOutlet weak var lastActivityLineView: UIView!
    @IBOutlet weak var lastActivityDateLabel: UILabel!
    
    @IBOutlet weak var lineImageViewVerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionLabelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var numberOfLikesAndCommentsLabel: UILabel!
    @IBOutlet weak var numberOfLikesAndCommentLabelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var cardDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var commentUserProfileImageView: UIImageView!
    @IBOutlet weak var commentUserNameLabel: UILabel!
    @IBOutlet weak var commentBodyLabel: UILabel!
    
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var cardActionView: UIView!
    @IBOutlet weak var cardCommentView: UIView!
    
    @IBOutlet weak var cardActionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardCommentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var galleryViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var spacerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var userProfileImageviewWidthConstraint: NSLayoutConstraint!
    
    var workitemId : String?


    
    override func awakeFromNib() {
        super.awakeFromNib()
        UITableViewCell.setCellBackgroundView(self)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
    
    func updateCellWithData(cellData : BPMApproval?,sentBy : UIViewController){
        

        guard let unwrappedCellData = cellData else{
            return
        }
        
        workitemId = unwrappedCellData.id
        
        let actionProp = ActionProperty()
        actionProp.workitemId = unwrappedCellData.id
        actionProp.senderViewController = sentBy
        
        
        let defaultCardActions = [CardAction.Approve,CardAction.Reject,CardAction.DelegateTask]

        if defaultCardActions.count > 3{
            var moreActions = defaultCardActions
            ActionController.instance.moreActionsArray = moreActions
        }
        
        cardActionView.createActionButtons(true , actionViewHeightConstraint: cardActionViewHeightConstraint, actionViewInitialHeight: ConstantUI.actionViewHeight, actionArray: defaultCardActions,actionProperty: actionProp, maximumNumberOfButtonsToShow: 3)
        let attributedString =  Helper.getBoldAttributtedString(unwrappedCellData.commonCardFields?.userDisplayName,text2:unwrappedCellData.commonCardFields?.lastActivityText,font: 13)
        
        setLastActivityBarElements(attributedString,dateString: unwrappedCellData.commonCardFields?.lastActivityTime?.timeAgo  , lastActivityBarEnabled: unwrappedCellData.islastActivityEnabled)
        
        setTitleLabel(true, text: unwrappedCellData.titleString)
        
        setDescriptionLabel(unwrappedCellData.isDescriptionEnabled, text: unwrappedCellData.descriptionString)
        
        setLikesAndCommentLabel(nil)
        
        galleryView.createStackOfAttachments(true,  galleryViewHeightConstraint: galleryViewHeightConstraint, attachmentArray: unwrappedCellData.attachments, numberOfElementsInEachRow: 4, maximumNumberOfElementsToShow: 4)
        
        setCommentBarElements(unwrappedCellData.comments?.last?.commentedBy?.displayName, commentText: unwrappedCellData.comments?.last?.commentText, commentUserProfileImageUrlString: unwrappedCellData.comments?.last?.commentedBy?.avatarURLString, isEnabled: true)
        
        setStatusLabel(unwrappedCellData.cardStatus)
        
        cardDateLabel.text = unwrappedCellData.createdAt?.timeAgo ?? ""
        userNameLabel.text = unwrappedCellData.createdBy?.displayName
        setAvatar(unwrappedCellData.isAvatarEnabled, avatarUrl: unwrappedCellData.createdBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail))
        
        self.layoutIfNeeded()
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
            return
        }
        titleLabel.text = unwrappedText
    }
    
    func setStatusLabel(status : CardStatus){
        statusLabel.layer.borderColor = status.labelColor.CGColor
        statusLabel.layer.borderWidth = 1
        statusLabel.layer.cornerRadius = 3
        statusLabel.clipsToBounds = true
        switch(status){
        case .Open:
            statusLabel.textColor = status.labelColor
            statusLabel.text = "\u{200c} OPEN \u{200c}"
        case .Closed:
            statusLabel.textColor = status.labelColor
            statusLabel.text = "\u{200c} CLOSED \u{200c}"
        case .Onhold:
            statusLabel.textColor = status.labelColor
            statusLabel.text = "\u{200c} ONHOLD \u{200c}"
        case .Completed:
            statusLabel.textColor = status.labelColor
            statusLabel.text = "\u{200c} COMPLETED \u{200c}"
        case .Withdrawn:
            statusLabel.textColor = status.labelColor
            statusLabel.text = "\u{200c} WITHDRAWN \u{200c}"
            
        default:
            statusLabel.textColor = status.labelColor
            statusLabel.text = "\u{200c} CLOSED \u{200c}"
        }
        
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
    
    func setAvatar(isEnabled: Bool,avatarUrl : NSURL? ){
        
        if(isEnabled){
            
            userProfileImageviewWidthConstraint.constant = ConstantUI.userProfileWidth
            spacerViewWidthConstraint.constant = ConstantUI.defaultPadding
            userImageView.hidden = false
            userImageView.setImageWithOptionalUrl(avatarUrl, placeholderImage: AssetImage.ProfileImage.image)
        }
        else{
            userProfileImageviewWidthConstraint.constant = 0
            spacerViewWidthConstraint.constant = 0
            userImageView.hidden = true
        }
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
    
    func setLikesAndCommentLabel(text : String?){
        guard let unwrappedText = text where unwrappedText.characters.count > 0 else{
            numberOfLikesAndCommentsLabel.text = ""
            numberOfLikesAndCommentLabelBottomConstraint.constant = 0
            return
        }
        numberOfLikesAndCommentsLabel.text = unwrappedText
        numberOfLikesAndCommentLabelBottomConstraint.constant = ConstantUI.defaultPadding
    }
}
