//
//  PMSApprovalCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 14/07/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class PMSApprovalCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var actionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var actionLineView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
     var actionProperty = ActionProperty()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UITableViewCell.setCellBackgroundView(self)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCellWithData(cellData : PMSAppraisalTemplate?,sentBy : UIViewController){
        
        guard let unwrappedCellData = cellData else{
            return
        }
 
        userameLabel.text = unwrappedCellData.createdBy?.displayName
        dateLabel.text = Helper.stringForDate(unwrappedCellData.createdAt, format: "dd MM yyyy")
        titleLabel.text = unwrappedCellData.titleString
        descriptionLabel.text = unwrappedCellData.descriptionString
        let actionProp = ActionProperty()
        actionProp.workitemId = unwrappedCellData.id
        actionProp.senderViewController = sentBy
        setStatusLabel(unwrappedCellData.cardStatus)
        let defaultCardActions = [CardAction.Approve,CardAction.Reject]
        
        if defaultCardActions.count > 3{
            var moreActions = defaultCardActions
            ActionController.instance.moreActionsArray = moreActions
        }
        
        let currentUser = UserDefaults.loggedInUser()
        let assignedArray = unwrappedCellData.assignedTo
      
        if let users =  assignedArray?.filter({$0.id == currentUser?.id}){
           
            if users.count > 0 && (users.first?.manutalTaskStatus != .Approved && users.first?.manutalTaskStatus != .Rejected) {
            
                //                self.setActionBarEnable(true,status: unwrappedCellData.cardStatus)
                unwrappedCellData.actionBarEnabled = true
            }
            else{
                //                    self.setActionBarEnable(false,status: unwrappedCellData.cardStatus)
                unwrappedCellData.actionBarEnabled = false
                if let status = users.first?.manutalTaskStatus as CardStatus? {
                    setStatusLabel(status)
                }
            }
          
        }
   
        userImageView.setImageWithOptionalUrl(unwrappedCellData.createdBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        actionView.layer.borderColor = UIColor.lightGrayColor().CGColor
        actionView.layer.borderWidth = 1.0
        actionView.layer.cornerRadius = 20.0
        actionView.createActionButtons(unwrappedCellData.actionBarEnabled , actionViewHeightConstraint: actionViewHeightConstraint, actionViewInitialHeight: ConstantUI.actionViewHeight, actionArray: defaultCardActions,actionProperty: actionProp, maximumNumberOfButtonsToShow: 3)

        
        
    }
    
    func setStatusLabel(status : CardStatus){
        statusLabel.layer.cornerRadius = 3
        statusLabel.clipsToBounds = true
        statusLabel.layer.borderWidth = 1
        statusLabel.textColor = status.labelColor
        statusLabel.layer.borderColor = status.labelColor.CGColor
        
        statusLabel.text = " " + status.labelText + " \u{200c}"
        
    }
    
    
}
