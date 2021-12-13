//
//  ListView01Card.swift
//  Workbox
//
//  Created by Chetan Anand on 18/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class ListView01Card: UITableViewCell {
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var cardActionView: UIView!
    
   
    @IBOutlet var cardActionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var statusLabel: UILabel!
    
    @IBOutlet var cardView: UIView!
    
//    let actionPlaceholderButtons = [ActionButton(),ActionButton(),ActionButton(),ActionButton()]
//    let actionArray = Parser.fetchActions(CardSubtype.NewsFeedType)
    var actionArray = [CardAction]()
    var cardActionViewHeightInitialValue : CGFloat!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UITableViewCell.setCellBackgroundView(self)
        cardActionViewHeightInitialValue = cardActionHeightConstraint.constant
        self.contentView.backgroundColor = UIColor.tableViewBackGroundColor()
        
        self.cardView.backgroundColor = UIColor.cellBackGroundColor()
        cardView.layer.shadowColor = UIColor.lightGrayColor().CGColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
        cardView.layer.shadowOpacity = 0.4
        cardView.layer.shadowRadius = 2
        self.cardView.layer.cornerRadius = 4.0

//        UITableViewCell.setActionButtons(cardActionView,actionButtons: actionPlaceholderButtons ,actionArray: actionArray)
    }
    

    func updateCellWithData(cellData : Workitem,sentBy : UIViewController){
        
        let workitemDict = Parser.dictionaryFromData(cellData.workitemData)
        
        let cardType =  CardType(value: cellData.cardType)
        let cardSubType =  CardSubtype(value: cellData.cardSubtype)

        let listData = ListView(JSON: workitemDict)
        
        
        
        actionArray = listData.defaultCardActions
        
        let actionProp = ActionProperty()
        actionProp.workitemId = listData.id
        actionProp.likedBySelf = listData.likedBySelf
        actionProp.senderViewController = sentBy
        
        switch(cardType){
        case .TaskType:
            switch cardSubType {
            case .ManualTaskType:
                guard let currentUserId = UserDefaults.loggedInUser()?.id else{
                    print("invaild email id")
                    return
                }
                
                if currentUserId == listData.createdBy?.id{
                    //ASSIGNEE LOGIC
                    //            unwrappedCellData.defaultManualCardActionsStringArray = ["CLOSE_TASK","WITHDRAW_TASK"]
                    //
                    //            unwrappedCellData.defaultCardActions = unwrappedCellData.defaultManualCardActionsStringArray.flatMap{ CardAction(value: $0 as? String) }
                    listData.defaultCardActions = listData.cardStatus.enabledActionsForAssigner
                    if listData.defaultCardActions.count > 3{
                        var moreActions = listData.defaultCardActions
                        //                moreActions.removeRange(Range.init(0..<2))
                        ActionController.instance.moreActionsArray = moreActions
                    }
                }
                else{//ASSIGNER LOGIC
                    //            unwrappedCellData.defaultManualCardActionsStringArray = ["COMPLETE_TASK","HOLD_TASK","DELEGATE_TASK"]
                    //
                    //            unwrappedCellData.defaultCardActions = unwrappedCellData.defaultManualCardActionsStringArray.flatMap{ CardAction(value: $0 as? String) }
                    if  let assignedToUsersIdArray = listData.assignedTo?.map({$0.id}){
                        
                        if assignedToUsersIdArray.contains({$0 == currentUserId}) {
                            let currentUser = listData.assignedTo?.filter({$0.id == currentUserId})
                            if currentUser != nil{
                                listData.cardStatus = currentUser![0].manutalTaskStatus ?? CardStatus.Unknown
                                listData.defaultCardActions = listData.cardStatus.enabledActionsForAssignee
                                if listData.defaultCardActions.count > 3{
                                    var moreActions = listData.cardStatus.enabledActionsForAssignee
                                    //                            moreActions.removeRange(Range.init(0..<2))
                                    ActionController.instance.moreActionsArray = moreActions
                                }
                            }
                            
                        }
                        else{// WATCHER LOGIC
                            //                    unwrappedCellData.cardStatus = CardStatus.Unknown
                            listData.defaultCardActions = listData.cardStatus.enabledActionsForWatcher
                            if listData.defaultCardActions.count > 3{
                                var moreActions = listData.defaultCardActions
                                //                        moreActions.removeRange(Range.init(0..<2))
                                ActionController.instance.moreActionsArray = moreActions
                            }
                        }
                    }
                    else{// WATCHER LOGIC
                        //                unwrappedCellData.cardStatus = CardStatus.Unknown
                        listData.defaultCardActions = listData.cardStatus.enabledActionsForWatcher
                        if listData.defaultCardActions.count > 3{
                            var moreActions = listData.defaultCardActions
                            //                    moreActions.removeRange(Range.init(0..<2))
                            ActionController.instance.moreActionsArray = moreActions
                        }
                    }
                    
                }
                
                cardActionView.createActionButtons(listData.actionBarEnabled, actionViewHeightConstraint: cardActionHeightConstraint, actionViewInitialHeight: ConstantUI.actionViewHeight, actionArray: listData.defaultCardActions,actionProperty: actionProp, maximumNumberOfButtonsToShow: 3)
               
            case .BPMTask:
                
                listData.defaultCardActions = [CardAction.Approve,CardAction.Reject,CardAction.Comment]
                
                cardActionView.createActionButtons(listData.actionBarEnabled, actionViewHeightConstraint: cardActionHeightConstraint, actionViewInitialHeight: cardActionViewHeightInitialValue, actionArray: listData.defaultCardActions,actionProperty: actionProp, maximumNumberOfButtonsToShow: 3)
                
            default:
                print("did not match any type")
            }
            
          
           
   
                
        default:   cardActionView.createActionButtons(listData.actionBarEnabled, actionViewHeightConstraint: cardActionHeightConstraint, actionViewInitialHeight: cardActionViewHeightInitialValue, actionArray: nil,actionProperty: actionProp, maximumNumberOfButtonsToShow: nil)
            
            
        }
        if listData.cardSubtype.rawValue == "updateRequisition"{
        titleLabel.text = "System"
        //userNameLabel.text = listData.createdBy?.displayName ?? ""
        userNameLabel.text = "Assign position number for a new Non-Budgeted requisition"
        let object = listData.contentString
        
        bodyLabel.text = object!["positionName"] as? String
        statusLabel.text = listData.cardStatus.labelText
        statusLabel.textColor = listData.cardStatus.labelColor
        statusLabel.layer.borderColor = listData.cardStatus.labelColor.CGColor
        statusLabel.layer.borderWidth = 1.0
        statusLabel.layer.cornerRadius = 5.0
        }
        
        else if listData.cardSubtype.rawValue == "requisition"{
            let object = listData.contentString
            let pos = object!["positionName"] as? String

            bodyLabel.text =  pos
            let creat = listData.contentString!["createdBy"] as? NSDictionary
            let name = creat!["displayName"] as? String
            titleLabel.text = name
            userNameLabel.text = "Created a new position requisition for " + pos!
            statusLabel.text = listData.assignedTo?.first?.manutalTaskStatus.labelText
            statusLabel.textColor = listData.assignedTo?.first?.manutalTaskStatus.labelColor
            statusLabel.layer.borderColor = listData.assignedTo?.first?.manutalTaskStatus.labelColor.CGColor
            statusLabel.layer.borderWidth = 1.0
             statusLabel.layer.cornerRadius = 5.0
        }
        else if listData.cardSubtype.rawValue == "jobApplicationException"{
        }
        else if listData.cardSubtype.rawValue == "offerRollout"{
        }
        
        userProfileImageView.setImageWithOptionalUrl(listData.updatedBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
    }

}
