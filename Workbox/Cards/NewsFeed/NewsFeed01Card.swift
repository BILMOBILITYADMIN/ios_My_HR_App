//
//  NewsFeed01Card.swift
//  Workbox
//
//  Created by Chetan Anand on 08/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Kingfisher

class NewsFeed01Card: UITableViewCell {
    
    //Outlets for Data
    @IBOutlet weak var latestActivityLabel: UILabel!
    @IBOutlet weak var lastActivityDateLabel: UILabel!
    @IBOutlet weak var lastActivityLineView: UIView!
    @IBOutlet weak var lastActivityLineViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var numberOfLikesAndCommentsLabel: UILabel!
    @IBOutlet weak var mediaImageview: UIImageView!
    @IBOutlet weak var mediaLabel: UILabel!
    @IBOutlet weak var mediaDateLabel: UILabel!
    @IBOutlet weak var commentUserProfileImageView: UIImageView!
    @IBOutlet weak var commentUserNameLabel: UILabel!
    @IBOutlet weak var commentBodyLabel: UILabel!

    
    //Outlets for Rendering
    @IBOutlet weak var latestActivityLineView: UIView!
    @IBOutlet weak var cardImageView: UIView!
    @IBOutlet weak var cardActionView: UIView!
    @IBOutlet weak var cardCommentView: UIView!
    @IBOutlet weak var cardImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardActionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardCommentViewHeightConstraint: NSLayoutConstraint!
    

    
    
    var cardImageViewHeightInitialValue: CGFloat!
    var cardActionViewHeightInitialValue : CGFloat!
    var cardCommentViewHeightInitialValue : CGFloat!
    
    var numberOfLikes : Int = 0
    var numberOfComments : Int = 0
    var likedBySelf : Bool = false
    
    var workitemId : String?
//    let actionArrayValue = Parser.fetchActions(forType: CardType.FeedType, forSubtype: CardSubtype.NewsFeedType)


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UITableViewCell.setCellBackgroundView(self)
        

        cardImageViewHeightInitialValue = cardImageViewHeightConstraint.constant
        cardActionViewHeightInitialValue = cardActionViewHeightConstraint.constant
        cardCommentViewHeightInitialValue = cardCommentViewHeightConstraint.constant
        

    }
    


    ///Updating Cell Data
    func updateCellWithData(cellData : NewsFeed?,sentBy : UIViewController){

        
        guard let unwrappedCellData = cellData else{
            return
        }
        
        workitemId = unwrappedCellData.id
//        updateActionButtons(actionArray, workitemId: workitemId!, senderViewController: sentBy, likedBySelfValue: unwrappedCellData.likedBySelf)
        
        
        var actionProp = ActionProperty()
        actionProp.workitemId = unwrappedCellData.id
        actionProp.likedBySelf = unwrappedCellData.likedBySelf
        actionProp.senderViewController = sentBy
        
        cardActionView.createActionButtons(unwrappedCellData.actionBarEnabled, actionViewHeightConstraint: cardActionViewHeightConstraint, actionViewInitialHeight: cardActionViewHeightInitialValue, actionArray: unwrappedCellData.defaultCardActions,actionProperty: actionProp, maximumNumberOfButtonsToShow: 3)
        
        
        let attributedString =  Helper.getBoldAttributtedString(unwrappedCellData.commonCardFields?.userDisplayName,text2:unwrappedCellData.commonCardFields?.lastActivityText,font: 13)

        
        setLastActivityBarElements(attributedString,dateString: unwrappedCellData.commonCardFields?.lastActivityTime?.timeAgo  , lastActivityBarEnabled: unwrappedCellData.latestActivityBarEnabled)
        
        mediaLabel.text = unwrappedCellData.titleString
        
        setDescription(unwrappedCellData.descriptionString, descriptonEnabled: true)
        
        setCommentBarElements(unwrappedCellData.comments?.last?.commentedBy?.displayName, commentText: unwrappedCellData.comments?.last?.commentText, commentUserProfileImageUrl: unwrappedCellData.comments?.last?.commentedBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), commentBarEnabled: unwrappedCellData.commentBarEnabled)
        
        
        mediaDateLabel.text = unwrappedCellData.createdAt?.timeAgo ?? nil
        mediaImageview.setImageWithOptionalUrlWithoutPlaceholder(unwrappedCellData.createdBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail))
        
        numberOfLikesAndCommentsLabel.text = Helper.likeCommentAttachmentString(unwrappedCellData.likeCountInt, numberOfComments: unwrappedCellData.commentsCountInt, likesEnabled: unwrappedCellData.likeCountEnabled,commentEnabled: unwrappedCellData.commentCountEnabled, numberOfAttachments: nil, attachmentCountEnabled: false)
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
  
    
    func setLastActivityBarElements(text : NSMutableAttributedString?,dateString : String?, lastActivityBarEnabled : Bool){
        latestActivityLabel.numberOfLines = 0
        if let unwrappedText = text where unwrappedText.length > 0 && lastActivityBarEnabled {
            latestActivityLabel.hidden = false
            lastActivityDateLabel.hidden = false
            lastActivityLineView.hidden = false
            lastActivityLineViewHeightConstraint.constant = CGFloat(2 * ConstantUI.defaultPadding)
            latestActivityLabel.attributedText = unwrappedText
            lastActivityDateLabel.text = dateString ?? ""
            
        }
        else{
            latestActivityLabel.hidden = true
            lastActivityDateLabel.hidden = true
            lastActivityLineView.hidden = true

            lastActivityLineViewHeightConstraint.constant = CGFloat(ConstantUI.defaultPadding)
            latestActivityLabel.text = ""
            lastActivityDateLabel.text = ""
            
            
        }
    }
    
    func setDescription(descriptionText : String?, descriptonEnabled : Bool){
//        descriptionLabel.numberOfLines = 0
        if let unwrappedText = descriptionText where unwrappedText.characters.count > 0 && descriptonEnabled {
//            print(descriptionText)
            
            descriptionLabel.text = unwrappedText
            
        }
        else{
            
            descriptionLabel.text = nil
        }
    }
    
    
    func setCommentBarElements(commentUsernameText : String?,commentText : String?, commentUserProfileImageUrl: NSURL?, commentBarEnabled : Bool){
        
        if let unwrappedcommentUsernameText = commentUsernameText where commentBarEnabled {
            cardCommentView.hidden = false
            cardCommentViewHeightConstraint.constant = cardCommentViewHeightInitialValue
            commentUserNameLabel.text = unwrappedcommentUsernameText
            commentBodyLabel.text = commentText ?? ""
            commentUserProfileImageView.setImageWithOptionalUrl(commentUserProfileImageUrl, placeholderImage: AssetImage.ProfileImage.image)
        }
        else{
            cardCommentView.hidden = true
            cardCommentViewHeightConstraint.constant = 0
        }
    }
    
    func setActionBarEnabled(isEnabled : Bool){
        if isEnabled {
            cardActionView.hidden = false
            cardActionViewHeightConstraint.constant = cardActionViewHeightInitialValue
        }
        else{
            cardActionView.hidden = true
            cardActionViewHeightConstraint.constant = 0
        }
    }
    
//    func tapGesture(gesture: UIGestureRecognizer) {
//        
//        if let imageView = gesture.view as? UIImageView {
//            print("tapped")
//            guard let image = imageView.image else{
//                return
//            }
//            ImageViewer.sharedInstance.showSingleImageViewer(image,imageToShow: Photo(image: image), viewToOriginate: imageView)
//            
//        }
//    }
}
