//
//  LeaveDetail.swift
//  Workbox
//
//  Created by Chetan Anand on 25/04/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class LeaveDetail: UITableViewCell {
    
    @IBOutlet weak var ccLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var numberOfDaysLeaveLabel: UILabel!
    
    
    @IBOutlet weak var leaveTypeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    
    @IBOutlet weak var fromSessionLabel: UILabel!
    @IBOutlet weak var toSessionLabel: UILabel!
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var leaveBalanceLabel: UILabel!
    @IBOutlet weak var dataView: UIView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ccView: UIView!
    
    @IBOutlet weak var dataViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ccViewHeightConstraint: NSLayoutConstraint!
    
    var leaveApprovalData : LeaveApproval?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCellWithData(cellData : LeaveApproval?,sentBy : UIViewController){
        
        guard let unwrappedCellData = cellData else{
            return
        }
        
                    userNameLabel.text = unwrappedCellData.leaveSubmittedBy?.displayName
        
//                   userImageView.setAvatar(unwrappedCellData.isAvatarEnabled, avatarUrl: unwrappedCellData.leaveSubmittedBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail))
        
           userImageView.setImageWithOptionalUrl(unwrappedCellData.leaveSubmittedBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        
                    leaveTypeLabel.text = unwrappedCellData.leaveName
                    numberOfDaysLeaveLabel.text = unwrappedCellData.leaveDuration
        
        fromDateLabel.text = Helper.stringForDateWithYearCorrectionIncludingDayOfWeek(unwrappedCellData.leaveFromDate)
        toDateLabel.text = Helper.stringForDateWithYearCorrectionIncludingDayOfWeek(unwrappedCellData.leaveToDate)
        
        setFromTime(unwrappedCellData.isFromTimeEnabled, leaveFromSession: unwrappedCellData.leaveFromSession)
        setToTime(unwrappedCellData.isToTimeEnabled, leaveToSession: unwrappedCellData.leaveToSession)
        
//        cardActionView.createActionButtons(true, actionViewHeightConstraint: actionViewHeightConstraint, actionViewInitialHeight: ConstantUI.actionViewHeight, actionArray: unwrappedCellData.defaultCardActions, actionProperty: ActionProperty(), maximumNumberOfButtonsToShow: nil)
        descriptionLabel.text = unwrappedCellData.descriptionString ?? ""
        
        var viewArray = [UIView]()
        if let unwrappedLeaveBalances = unwrappedCellData.leaveBalances{
            for i in 0..<unwrappedLeaveBalances.count{
                let myView = LeaveData.loadFromNib()
                myView.headerLabel.text = unwrappedLeaveBalances[i].name
                myView.dataLabel.text = " \(unwrappedLeaveBalances[i].availedLeave ?? 0)/\(unwrappedLeaveBalances[i].availableLeave ?? 0)"
                viewArray.append(myView)
            }
        }
        dataView.createStackOfViews(true, viewHeightConstraint: dataViewHeightConstraint, viewArray: viewArray, numberOfElementsInEachRow: 4, fixedHeightOfEachView: 50 ,maximumNumberOfElementsToShow: nil, padding: 8.0)
        var userArrayInString = [String]()
        
//        var ccViewArray = [UIView]()
        if let unwrappedLeaveCopyTo = unwrappedCellData.leaveCopyTo{
            for i in 0..<unwrappedLeaveCopyTo.count{
                userArrayInString.append(unwrappedLeaveCopyTo[i].displayName ?? "")
            }
            let ccLabelString = userArrayInString.joinWithSeparator(", ")
            ccLabel.text = ccLabelString
            
        }
//       let formattedViewArray = ccView.createStackOfViews(true, viewHeightConstraint: ccViewHeightConstraint, viewArray: ccViewArray, numberOfElementsInEachRow: 2, fixedHeightOfEachView: 24 ,maximumNumberOfElementsToShow: nil, padding: 8.0)
    }
    
    
    func setFromTime(isFromTimeEnabled : Bool, leaveFromSession: Int? ){
        if isFromTimeEnabled{
            fromSessionLabel.text = "Session " + String(leaveFromSession ?? 1)
        }
        else{
            fromSessionLabel.text = ""
        }
    }
    
    func setToTime(isToTimeEnabled : Bool, leaveToSession : Int?){
        if isToTimeEnabled{
            toSessionLabel.text = "Session " + String(leaveToSession ?? 2)
        }
        else{
            toSessionLabel.text = ""
        }
    }
    
//    func setLikesAndCommentAttachmentLabel(text : String?){
//        guard let unwrappedText = text where unwrappedText.characters.count > 0 else{
//            attachmentCountLabel.text = ""
//            //            numberOfLikesAndCommentLabelBottomConstraint.constant = 0
//            return
//        }
//        attachmentCountLabel.text = unwrappedText
//        //        numberOfLikesAndCommentLabelBottomConstraint.constant = ConstantUI.defaultPadding
//    }
    
}
