//
//  LeaveApproval01Card.swift
//  Workbox
//
//  Created by Chetan Anand on 30/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class LeaveApproval01Card: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var leaveTypeLabel: UILabel!
    @IBOutlet weak var numberOfDaysLeaveLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startSessionLabel: UILabel!
    @IBOutlet weak var endSessionLabel: UILabel!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var attachmentCountLabel: UILabel!
    @IBOutlet weak var cardActionView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var dateView: UIView!
    
    @IBOutlet weak var dataGridViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userProfileImageWConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var spacerViewWidthConstraint: NSLayoutConstraint!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UITableViewCell.setCellBackgroundView(self)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func approveButtonTapped(sender: AnyObject) {
    }
    @IBAction func rejectButtonTapped(sender: AnyObject) {
    }

    
    ///Updating Cell Data
    func updateCellWithData(cellData : LeaveApproval?,sentBy : UIViewController){
        
        guard let unwrappedCellData = cellData else{
            return
        }
        
        userNameLabel.text = unwrappedCellData.leaveSubmittedBy?.displayName
        
        setAvatar(unwrappedCellData.isAvatarEnabled, avatarUrl: unwrappedCellData.leaveSubmittedBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail))
        
        leaveTypeLabel.text = unwrappedCellData.leaveName
        numberOfDaysLeaveLabel.text = unwrappedCellData.leaveDuration
        
        startDateLabel.text = Helper.stringForDateWithYearCorrectionIncludingDayOfWeek(unwrappedCellData.leaveFromDate)
        endDateLabel.text = Helper.stringForDateWithYearCorrectionIncludingDayOfWeek(unwrappedCellData.leaveToDate)
        
        setFromTime(unwrappedCellData.isFromTimeEnabled, leaveFromSession: unwrappedCellData.leaveFromSession)
        setToTime(unwrappedCellData.isToTimeEnabled, leaveToSession: unwrappedCellData.leaveToSession)
        
        cardActionView.createActionButtons(unwrappedCellData.actionBarEnabled, actionViewHeightConstraint: actionViewHeightConstraint, actionViewInitialHeight: ConstantUI.actionViewHeight, actionArray: unwrappedCellData.defaultCardActions, actionProperty: ActionProperty(), maximumNumberOfButtonsToShow: 3)
        
        var viewArray = [UIView]()
        if let unwrappedLeaveBalances = unwrappedCellData.leaveBalances{
            for i in 0..<unwrappedLeaveBalances.count{
                let myView = LeaveData.loadFromNib()
                myView.headerLabel.text = unwrappedLeaveBalances[i].name
                myView.dataLabel.text = " \(unwrappedLeaveBalances[i].availedLeave ?? 0)/\(unwrappedLeaveBalances[i].availableLeave ?? 0)"
                viewArray.append(myView)
            }
        }
        
        dataView.createStackOfViews(true, viewHeightConstraint: dataGridViewHeightConstraint, viewArray: viewArray, numberOfElementsInEachRow: 4, fixedHeightOfEachView: nil ,maximumNumberOfElementsToShow: nil, padding: 8.0)
        
        setLikesAndCommentAttachmentLabel(Helper.likeCommentAttachmentString(unwrappedCellData.likeCount, numberOfComments: nil, likesEnabled: true, commentEnabled: false, numberOfAttachments: unwrappedCellData.leaveAttachments?.count, attachmentCountEnabled: true))
        
 
    }
    
    
    
    
    func setFromTime(isFromTimeEnabled : Bool, leaveFromSession: Int? ){
        if isFromTimeEnabled{
            startSessionLabel.text = "Session " + String(leaveFromSession ?? 1)
        }
        else{
            startSessionLabel.text = ""
        }
    }
    
    func setToTime(isToTimeEnabled : Bool, leaveToSession : Int?){
        if isToTimeEnabled{
            endSessionLabel.text = "Session " + String(leaveToSession ?? 2)
        }
        else{
            endSessionLabel.text = ""
        }
    }
    
    func setLikesAndCommentAttachmentLabel(text : String?){
        guard let unwrappedText = text where unwrappedText.characters.count > 0 else{
            attachmentCountLabel.text = ""
//            numberOfLikesAndCommentLabelBottomConstraint.constant = 0
            return
        }
        attachmentCountLabel.text = unwrappedText
//        numberOfLikesAndCommentLabelBottomConstraint.constant = ConstantUI.defaultPadding
    }
    
    func setAvatar(isEnabled: Bool,avatarUrl : NSURL? ){
        
        if(isEnabled){
            //Commented as user avatar is mandatory field in Leave approval card

//            userProfileImageWidthConstraint.constant = ConstantUI.userProfileWidth
//            spacerViewWidthConstraint.constant = ConstantUI.defaultPadding
            userImageView.hidden = false
            userImageView.setImageWithOptionalUrl(avatarUrl, placeholderImage: AssetImage.ProfileImage.image)
        }
        else{
//            userProfileImageWidthConstraint.constant = 0
//            spacerViewWidthConstraint.constant = 0
            userImageView.hidden = true
        }
    }
    
    
}
