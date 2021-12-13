//
//  TSApprovalCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 16/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
//
//protocol GetRejectButtonTagDelegate{
//    func getRejectButtonTag(index: Int)
//}

protocol GetActionsButtonTagDelegate{
    func getRejectButtonTag(index: Int)
    func getApproveButtonTag(index: Int)
}

class TSApprovalCell: UITableViewCell {
    
    @IBOutlet weak var approveButton: ActionButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var submittedHours: UILabel!
    @IBOutlet weak var leave: UILabel!
    @IBOutlet weak var leaveHeaderLabel: UILabel!
    
    @IBOutlet weak var rejectButton: ActionButton!
    @IBOutlet weak var nonProjectAllocation: UILabel!
    @IBOutlet weak var npaHeaderLabel: UILabel!
    @IBOutlet weak var projectHours: UILabel!
    @IBOutlet weak var projectHeaderLabel: UILabel!
    @IBOutlet weak var allocatedHours: UILabel!
    @IBOutlet weak var timesheetTask: UILabel!
    @IBOutlet weak var period: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var timeDetailView: UIView!
    @IBOutlet weak var timeDetailViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cardActionView: UIView!
    @IBOutlet weak var cardActionViewHeightConstraint: NSLayoutConstraint!
    
    
    //    var delegate = GetRejectButtonTagDelegate?()
    
    //    var delegate = GetActionsButtonTagDelegate?()
    var actionProperty = ActionProperty()
    
//    let actionArray = Parser.fetchActions(CardSubtype.UserMessageType)
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        UITableViewCell.setCellBackgroundView(self)
        
        
        //        updateProfileImageView()
        //       updateCellImageView()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    


    
    //    //Function to add background image
    //    func updateCellImageView() {
    //        var imageName = AssetImage.RoundedCornerShadow.image
    //        let myInsets : UIEdgeInsets = UIEdgeInsetsMake(16,16 ,16,16 )
    //        imageName = imageName.resizableImageWithCapInsets(myInsets)
    //        backgroundImageView.image = imageName
    //    }
    
    //    @IBAction func approveButtonPressed(sender: AnyObject) {
    //        print("Approved Pressed")
    ////        delegate?.getApproveButtonTag(sender.tag)
    //         ActionController.instance.approve(actionProperty?.workitemId, sentBy: actionProperty?.senderViewController)
    //    }
    
    //Function to add background image
    //    func updateCellImageView() {
    //        var imageName = AssetImage.RoundedCornerShadow.image
    //        let myInsets : UIEdgeInsets = UIEdgeInsetsMake(16,16 ,16,16 )
    //        imageName = imageName.resizableImageWithCapInsets(myInsets)
    //        backgroundImageView.image = imageName
    //    }
    //
    //Function to update the cell and assign reject button tag
    //    func updateApprovalCell(data : Approval, index: Int) {
    ///Updating Cell Data
    func updateCellWithData(cellData : Approval?,sentBy : UIViewController){
        
        
        guard let unwrappedCellData = cellData else{
            return
        }
        actionProperty.workitemId = unwrappedCellData.id
        actionProperty.senderViewController = sentBy
        actionProperty.createdAt = String(NSDate())
        
        let currentUser = UserDefaults.loggedInUser()
        let assignedArray = unwrappedCellData.assignedTo
        if let users =  assignedArray?.filter({$0.id == currentUser?.id}){
            if users.count > 0 && unwrappedCellData.cardStatus == .Open{
                //                self.setActionBarEnable(true,status: unwrappedCellData.cardStatus)
                unwrappedCellData.actionBarEnabled = true
            }
            else{
                //                    self.setActionBarEnable(false,status: unwrappedCellData.cardStatus)
                unwrappedCellData.actionBarEnabled = false
                
            }
        }
        
        cardActionView.createActionButtons(unwrappedCellData.actionBarEnabled, actionViewHeightConstraint: cardActionViewHeightConstraint, actionViewInitialHeight: ConstantUI.actionViewHeight, actionArray: unwrappedCellData.defaultCardActions, actionProperty: actionProperty, maximumNumberOfButtonsToShow: 3)

        setStatusLabel(unwrappedCellData.cardStatus)
        
//        setLeaveHoursEnabled(Parser.isElementEnabled(forType: CardType.TimesheetType, forSubtype: CardSubtype.Approve, optionalFieldString: "leaveHours"))
        setNpaHoursEnabled(Parser.isElementEnabled(forType: CardType.TimesheetType, forSubtype: CardSubtype.Approve, optionalFieldString: "npaHours"))
        setProjectHoursEnabled(Parser.isElementEnabled(forType: CardType.TimesheetType, forSubtype: CardSubtype.Approve, optionalFieldString: "projectHours"))
        
        
        allocatedHours.text = Helper.timeInHMformatForMinutes(Int(unwrappedCellData.allocatedHours * 60))
        submittedHours.text = Helper.timeInHMformatForMinutes(Int(unwrappedCellData.submittedHours * 60))
        projectHours.text = Helper.timeInHMformatForMinutes(Int(unwrappedCellData.projectHours * 60))
        nonProjectAllocation.text = Helper.timeInHMformatForMinutes(Int(unwrappedCellData.nonProjectHours * 60))
//        leave.text = Helper.timeInHMformatForMinutes(Int(unwrappedCellData.leaveHours! * 60))
        
        period.text = "\(Helper.stringForDateWithYearCorrection(unwrappedCellData.weekStartDate) ?? "") - \(Helper.stringForDateWithYearCorrection(unwrappedCellData.weekEndDate) ?? "")"
        timesheetTask.text = unwrappedCellData.projectName
        
        profileImageView.setImageWithOptionalUrl(unwrappedCellData.submittedBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        
        username.text = unwrappedCellData.submittedBy?.displayName
        
        setApproveRejectButtonLabel(unwrappedCellData.cardStatus)

//        Helper.createStackOfViews(true, superView: timeDetailView, superViewHeightConstraint: timeDetailViewHeightConstraint,viewInitialHeight: 50, subViewArray: [timeView], numberOfElementsInEachRow: 4, maximumNumberOfElementsToShow: nil)

        

    }
    
    
    //Function to update profile Image View
    func updateProfileImageView() {
        profileImageView.layer.cornerRadius = 10
        profileImageView.clipsToBounds = true
    }
    
    func setStatusLabel(status : CardStatus){
        statusLabel.layer.cornerRadius = 3
        statusLabel.clipsToBounds = true
        statusLabel.layer.borderWidth = 1
        statusLabel.textColor = status.labelColor
        statusLabel.layer.borderColor = status.labelColor.CGColor

        statusLabel.text = " " + status.labelText + " \u{200c}"
                
    }
    
    
    func setActionBarEnable(isEnable:Bool,status : CardStatus){
        if isEnable{
//            print("action bar is enabled")
            approveButton.setTitle("APPROVE", forState: UIControlState.Normal)
            rejectButton.setTitle("REJECT", forState: UIControlState.Normal)
            approveButton.setTitleColor(ConstantColor.CWBlue, forState: .Normal)
            rejectButton.setTitleColor(UIColor.redColor(), forState: .Normal)
            
            approveButton.enabled = true
            rejectButton.enabled = true
        }
        else{
            if status == CardStatus.Approved{
                approveButton.setTitle("APPROVED", forState: UIControlState.Normal)
                approveButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
                
                rejectButton.setTitle("", forState: UIControlState.Normal)
                approveButton.enabled = false
                rejectButton.enabled = false
            }
            else if(status == CardStatus.Rejected) {
                approveButton.setTitle("REJECTED", forState: UIControlState.Normal)
                approveButton.setTitleColor(UIColor.redColor(), forState: .Normal)
                
                rejectButton.setTitle("", forState: UIControlState.Normal)
                approveButton.enabled = false
                rejectButton.enabled = false
            }
            else{
            approveButton.setTitle("SUBMITTED", forState: UIControlState.Normal)
            approveButton.setTitleColor(UIColor(red: 255/255.0, green: 211/255.0, blue: 92/255.0, alpha: 1.0), forState: .Normal)
            rejectButton.setTitle("", forState: UIControlState.Normal)
                approveButton.enabled = false
                rejectButton.enabled = false
            }
        }
        
    }
    
    func setApproveRejectButtonLabel(status : CardStatus){
        if status == CardStatus.Approved{
            approveButton.setTitle("APPROVED", forState: UIControlState.Normal)
            approveButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
            
            rejectButton.setTitle("", forState: UIControlState.Normal)
            approveButton.enabled = false
            rejectButton.enabled = false
        }
        else if(status == CardStatus.Rejected) {
            approveButton.setTitle("REJECTED", forState: UIControlState.Normal)
            approveButton.setTitleColor(UIColor.redColor(), forState: .Normal)
            
            rejectButton.setTitle("", forState: UIControlState.Normal)
            approveButton.enabled = false
            rejectButton.enabled = false
        }
        else {
            approveButton.setTitle("APPROVE", forState: UIControlState.Normal)
            rejectButton.setTitle("REJECT", forState: UIControlState.Normal)
            approveButton.setTitleColor(ConstantColor.CWBlue, forState: .Normal)
            rejectButton.setTitleColor(UIColor.redColor(), forState: .Normal)
            
            approveButton.enabled = true
            rejectButton.enabled = true
        }
    }
    
//    func setLeaveHoursEnabled(isEnabled : Bool)  {
//        leave.hidden = !isEnabled
//        leaveHeaderLabel.hidden = !isEnabled
//    }
    
    func setNpaHoursEnabled(isEnabled : Bool)  {
        npaHeaderLabel.hidden = !isEnabled
        nonProjectAllocation.hidden = !isEnabled
        
    }
    func setProjectHoursEnabled(isEnabled : Bool)  {
        projectHours.hidden = !isEnabled
        projectHeaderLabel.hidden = !isEnabled
    }
    
    
    
    func getTime(time:String?)-> String{
        
        if let hours = time as String!{
            if let timeInFloat = Float(hours){
                let  h = Int(timeInFloat / 60)
                let m = Int(timeInFloat % 60)
                if m == 5{
                    return String(h) + ":0" + String(m)
                }
                else{
                    return  (String(h) + ":" + String(m))
                }
            }
        }
        return ""
    }
}
