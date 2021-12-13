//
//  GenericTaskDetail.swift
//  Workbox
//
//  Created by Chetan Anand on 18/04/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class GenericTaskDetail: UITableViewCell {
    
    //Outlets for Data
    
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
    @IBOutlet weak var commentUserProfileImageView: UIImageView!
    @IBOutlet weak var commentUserNameLabel: UILabel!
    @IBOutlet weak var commentBodyLabel: UILabel!
    
    @IBOutlet weak var galleryView: UIView!
    
    
    @IBOutlet weak var statusLabel: UILabel!
    
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
//    let actionArray = Parser.fetchActions(forType: CardType.TaskType, forSubtype: CardSubtype.ManualTaskType)
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        UITableViewCell.setCellBackgroundView(self)
        
//        cardCommentViewHeightInitialValue = cardCommentViewHeightConstraint.constant
    }
    
    
    
    ///Updating Cell Data
    func updateCellWithData(cellData : GenericTask?,sentBy : UIViewController){
        
        
        guard let unwrappedCellData = cellData else{
            return
        }
        
        
        workitemId = unwrappedCellData.id
        
        var actionProp = ActionProperty()
        actionProp.workitemId = unwrappedCellData.id
        actionProp.likedBySelf = unwrappedCellData.likedBySelf
        actionProp.senderViewController = sentBy
        
        guard let currentUserId = UserDefaults.loggedInUser()?.id else{
            print("invaild email id")
            return
        }
        
        if currentUserId == unwrappedCellData.createdBy?.id{
            //ASSIGNEE LOGIC
            //            unwrappedCellData.defaultManualCardActionsStringArray = ["CLOSE_TASK","WITHDRAW_TASK"]
            //
            //            unwrappedCellData.defaultCardActions = unwrappedCellData.defaultManualCardActionsStringArray.flatMap{ CardAction(value: $0 as? String) }
            unwrappedCellData.defaultCardActions = unwrappedCellData.cardStatus.enabledActionsForAssigner
            if unwrappedCellData.defaultCardActions.count > 3{
                let moreActions = unwrappedCellData.defaultCardActions
                //                moreActions.removeRange(Range.init(0..<2))
                ActionController.instance.moreActionsArray = moreActions
            }
        }
        else{//ASSIGNER LOGIC
            //            unwrappedCellData.defaultManualCardActionsStringArray = ["COMPLETE_TASK","HOLD_TASK","DELEGATE_TASK"]
            //
            //            unwrappedCellData.defaultCardActions = unwrappedCellData.defaultManualCardActionsStringArray.flatMap{ CardAction(value: $0 as? String) }
            if  let assignedToUsersIdArray = unwrappedCellData.assignedTo?.map({$0.id}){
                
                if assignedToUsersIdArray.contains({$0 == currentUserId}) {
                    let currentUser = unwrappedCellData.assignedTo?.filter({$0.id == currentUserId})
                    if currentUser != nil{
                        unwrappedCellData.cardStatus = currentUser![0].manutalTaskStatus ?? CardStatus.Unknown
                        unwrappedCellData.defaultCardActions = unwrappedCellData.cardStatus.enabledActionsForAssignee
                        if unwrappedCellData.defaultCardActions.count > 3{
                            let moreActions = unwrappedCellData.cardStatus.enabledActionsForAssignee
                            //                            moreActions.removeRange(Range.init(0..<2))
                            ActionController.instance.moreActionsArray = moreActions
                        }
                    }
                    
                }
                else{// WATCHER LOGIC
                    //                    unwrappedCellData.cardStatus = CardStatus.Unknown
                    unwrappedCellData.defaultCardActions = unwrappedCellData.cardStatus.enabledActionsForWatcher
                    if unwrappedCellData.defaultCardActions.count > 3{
                        let moreActions = unwrappedCellData.defaultCardActions
                        //                        moreActions.removeRange(Range.init(0..<2))
                        ActionController.instance.moreActionsArray = moreActions
                    }
                }
            }
            else{// WATCHER LOGIC
                //                unwrappedCellData.cardStatus = CardStatus.Unknown
                unwrappedCellData.defaultCardActions = unwrappedCellData.cardStatus.enabledActionsForWatcher
                if unwrappedCellData.defaultCardActions.count > 3{
                    var moreActions = unwrappedCellData.defaultCardActions
                    //                    moreActions.removeRange(Range.init(0..<2))
                    ActionController.instance.moreActionsArray = moreActions
                }
            }
            
        }
        
        cardActionView.createActionButtons(true, actionViewHeightConstraint: cardActionViewHeightConstraint, actionViewInitialHeight: ConstantUI.actionViewHeight, actionArray: unwrappedCellData.defaultCardActions,actionProperty: actionProp, maximumNumberOfButtonsToShow: 3)
        
//        setLastActivityBarElements(unwrappedCellData.commonCardFields.lastActivityText,dateString: unwrappedCellData.commonCardFields.lastActivityTime?.timeAgo  , lastActivityBarEnabled: unwrappedCellData.latestActivityBarEnabled)
        
        setTitleLabel(true, text: unwrappedCellData.titleString)
        
        setDescriptionLabel(true, text: unwrappedCellData.descriptionString)
        
        setLikesAndCommentLabel(Helper.likeCommentAttachmentString(unwrappedCellData.likeCountInt, numberOfComments: unwrappedCellData.commentsCountInt, likesEnabled: true,commentEnabled: true, numberOfAttachments: nil, attachmentCountEnabled: false))
        
        galleryView.createStackOfAttachments(true,  galleryViewHeightConstraint: galleryViewHeightConstraint, attachmentArray: unwrappedCellData.attachments, numberOfElementsInEachRow: 4, maximumNumberOfElementsToShow: 4)
        
//        setCommentBarElements(unwrappedCellData.comments?.first?.commentedBy?.displayName, commentText: unwrappedCellData.comments?.first?.commentText, commentUserProfileImageUrlString: unwrappedCellData.comments?.first?.commentedBy?.avatarURLString, isEnabled: unwrappedCellData.commentBarEnabled)
        
        setStatusLabel(unwrappedCellData.cardStatus)
        
        cardDateLabel.text = unwrappedCellData.createdAt?.timeAgo ?? ""
        userNameLabel.text = unwrappedCellData.createdBy?.displayName
        userImageView.setImageWithOptionalUrl(unwrappedCellData.createdBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setLastActivityBarElements(text : String?,dateString : String?, lastActivityBarEnabled : Bool){
        lastActivityLabel.numberOfLines = 0
        if let unwrappedText = text where unwrappedText.characters.count > 0 && lastActivityBarEnabled {
            lastActivityLabel.hidden = false
            lastActivityLineView.hidden = false
            lastActivityLineView.hidden = false
            
            lineImageViewVerticalConstraint.constant = CGFloat(2 * ConstantUI.defaultPadding)
            lastActivityLabel.text = unwrappedText
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
//        case .Delegated:
//            statusLabel.textColor = status.labelColor
//            statusLabel.text = "\u{200c} DELEGATED \u{200c}"
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
