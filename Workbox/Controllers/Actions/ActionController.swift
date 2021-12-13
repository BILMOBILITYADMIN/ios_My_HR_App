//
//  ActionController.swift
//  Workbox
//
//  Created by Chetan Anand on 12/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import MessageUI
import ReachabilitySwift
import BSImagePicker
import Photos
import BRYXBanner


public enum CardAction: String{
    case Like = "LIKE"
    case Attach = "ADD_ATTACHMENT"
    case Comment = "COMMENT"
    case More = "MORE"
//  case VisitWebsite = "VISIT_WEBSITE"
    case Share = "VISIT_WEBSITE"
    //TIMESHEET
    case Approve = "APPROVE"
    case Reject = "REJECT"
    //TASKS
    case CompleteTask = "COMPLETE_TASK"
    case CloseTask = "CLOSE_TASK" // Key maybe incorrect(Backend not sending it)
    case HoldTask = "HOLD_TASK" // Key maybe incorrect(Backend not sending it)
    case WithdrawTask = "WITHDRAW_TASK" // Key maybe incorrect(Backend not sending it)
    case DelegateTask = "DELEGATE_TASK" // Key maybe incorrect(Backend not sending it)
    case ReopenTask = "REOPEN_TASK"
    case Create = "create"
//  case Share = "SHARE"
    
    case UnknownAction
    
    
    init(value : String?){
        self =  CardAction(rawValue: value ?? "") ?? .UnknownAction
    }
    
    var displayString: String {
        switch self {
        case .CompleteTask:
            return "Complete"
        case .CloseTask:
            return "Close"
        case .HoldTask:
            return "Hold"
        case .WithdrawTask:
            return "Withdraw"
        case .DelegateTask:
            return "Delegate"
        case .ReopenTask:
            return "Reopen"
            
        default:
            return String(self)
        }
    }
    
    func displayStringBasedOn(actionProperty : ActionProperty) -> String{
        switch self {
        case .Like:
            return actionProperty.likedBySelf ? "Unlike":"Like"
        case .CompleteTask:
            return "Complete"
        default:
            return String(self)
        }
    }
    
    func displayColor(forActionProperty : ActionProperty) -> UIColor {
        switch self {
        case .Like:
            return forActionProperty.likedBySelf ? ConstantColor.CWBlue : ConstantColor.CWButtonGray
        case .Approve:
            return ConstantColor.CWButtonGray
        case .Reject:
            return ConstantColor.CWButtonGray
        default:
            return ConstantColor.CWButtonGray
        }
    }
    
}

//protocol AttachControllerProtocol : NSObjectProtocol {
//    func attachmentDone(attachments : [UIImage]) -> Void;
//    func attachmentCancelled() -> Void;
//    
//}

class ActionProperty: NSObject, NSCoding{
    var actionType : CardAction?
    var workitemId : String?
    var senderViewController : UIViewController?
    var likedBySelf : Bool = false
    var text : String?
    var attachments : [UIImage]?
    var createdAt : String?
    
    override init() {
        
    }

    required init?(coder aDecoder: NSCoder) {
        self.actionType = CardAction(value:aDecoder.decodeObjectForKey("actionType") as? String)
        self.workitemId = aDecoder.decodeObjectForKey("workitemId") as? String
//        self.senderViewController = aDecoder.decodeObjectForKey("senderViewController") as? UIViewController
        self.likedBySelf = aDecoder.decodeBoolForKey("likedBySelf")
        self.text = aDecoder.decodeObjectForKey("text") as? String
        self.createdAt = aDecoder.decodeObjectForKey("createdAt") as? String



        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(actionType?.rawValue, forKey: "actionType")
            aCoder.encodeObject(workitemId, forKey: "workitemId")
//            aCoder.encodeObject(senderViewController, forKey: "senderViewController")
        aCoder.encodeBool(likedBySelf, forKey: "likedBySelf")
            aCoder.encodeObject(text, forKey: "text")
        aCoder.encodeObject(createdAt, forKey: "createdAt")

    }
}


class ActionController:NSObject, RadialButtonDelegate, MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate{
    
    var userInActionController = User()
    //MARK: - Singleton
    static let instance = ActionController()
    var  moreActionsArray = [CardAction]()
    
    private  override init() {
    }
    
    //MARK: - Properties
    var attachViewController : AttachController?
    var attachments : [UIImage]?
//    weak var delegate: ActionProtocol?
    var cardViewController : CardViewController?
    var request: Alamofire.Request?
      var workItemData : Workitem?
    var cherryRoles = NSMutableDictionary()
    ///LIKE
    func like(actionProperty : ActionProperty) {
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("unwrapping WorkitemId failed")
            return
        }
        if let coreDataWorkitem = Parser.fetchWorkitem(forId: unwrappedWorkitemId){
            if let unwrappedWorkitemData = coreDataWorkitem.workitemData{
                
                let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedWorkitemData) as! NSDictionary
                
                let mutableDataDict =  NSMutableDictionary(dictionary: dataDictionary)
                
                
                if let likecount = mutableDataDict.valueForKeyPath("likeCount") as? Int{
                    let updatedLikeCount : Int = likecount + 1
                    mutableDataDict.setValue(updatedLikeCount, forKeyPath: "likeCount")
                }
                let updatedLikebySelf : Bool = true
                mutableDataDict.setValue(updatedLikebySelf.hashValue, forKeyPath: "likedByUser")
                Parser.workitemForDictionary(mutableDataDict)
                if let senderController =   actionProperty.senderViewController as? DetailViewController{
                    senderController.tableView.reloadData()
                }
                if let senderController =   actionProperty.senderViewController as? CardViewController{
                    senderController.tableView.reloadData()
                }
            }
        }
        
        
        print("WILL LIKE  :>>>> \(unwrappedWorkitemId)")
        self.request?.cancel()
        self.request = Alamofire.request(Router.Like(workitemId: unwrappedWorkitemId)).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    print("Error Occured: JSON Without success:\(jsonData) ")
                    return
                }
                print("DID LIKE : On workitem: \(unwrappedWorkitemId)")
                
                
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
        
        
    }
    
    ///UNLIKE
    func unlike(actionProperty : ActionProperty) {
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("unwrapping WorkitemId failed")
            return
        }
        
        if let coreDataWorkitem = Parser.fetchWorkitem(forId: unwrappedWorkitemId){
            if let unwrappedWorkitemData = coreDataWorkitem.workitemData{
                
                let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedWorkitemData) as! NSDictionary
                
                let mutableDataDict =  NSMutableDictionary(dictionary: dataDictionary)
                if let likecount = mutableDataDict.valueForKeyPath("likeCount") as? Int{
                    let updatedLikeCount : Int = likecount - 1
                    mutableDataDict.setValue(updatedLikeCount, forKeyPath: "likeCount")
                }
                let updatedLikebySelf : Bool = false
                mutableDataDict.setValue(updatedLikebySelf.hashValue, forKeyPath: "likedByUser")
                Parser.workitemForDictionary(mutableDataDict)
                if let senderController =   actionProperty.senderViewController as? DetailViewController{
                    senderController.tableView.reloadData()
                }
                if let senderController =   actionProperty.senderViewController as? CardViewController{
                    senderController.tableView.reloadData()
                }
            }
        }
        
        
        print("WILL UNLIKE  :>>>> \(unwrappedWorkitemId)")
        self.request?.cancel()
        self.request = Alamofire.request(Router.UnLike(workitemId: unwrappedWorkitemId)).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    print("Error Occured: JSON Without success:\(jsonData) ")
                    return
                }
                print("DID UNLIKE : On workitem: \(unwrappedWorkitemId)")
                
                
            case .Failure(let error):
                print("Request failed with error: \(error)")

            }
        }
        
        
    }
    
    
    
    ///COMMENT
    func comment(actionProperty : ActionProperty) {

        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("unwrapping WorkitemId failed")
            return
        }
        
        if !Helper.isConnectedToInternet(){
            actionProperty.createdAt = String(NSDate())
            Parser.SetOfflineAction(actionProperty)
            
            if let coreDataWorkitem = Parser.fetchWorkitem(forId: unwrappedWorkitemId){
                if let unwrappedWorkitemData = coreDataWorkitem.workitemData{
                    
                    let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedWorkitemData) as! NSDictionary
                    
                    let mutableDataDict =  NSMutableDictionary(dictionary: dataDictionary)
                    
                    var finalCommentDict = [NSDictionary]()
                    
                    let jsonData = mutableDataDict.valueForKeyPath("comments")
                    
                    if let unwrappedData = jsonData as? NSDictionary {
                        finalCommentDict.append(unwrappedData)
                    }
                    else if let unwrappedData = jsonData as? [NSDictionary] {
                        finalCommentDict.appendContentsOf(unwrappedData)
                    }
                    else{
                        return
                    }
                
                
                    let userDict = NSMutableDictionary()
                    userDict.setValue(UserDefaults.loggedInUser()?.displayName ?? "", forKey: "displayName")
                    userDict.setValue(UserDefaults.loggedInUser()?.avatarURLString ?? "", forKey: "avatar")
                    
                    let thisCommentDict = NSMutableDictionary()
                    thisCommentDict.setValue("[Offline] " + (actionProperty.text ?? "") , forKey: "text")
                    thisCommentDict.setValue(userDict, forKey: "commentedBy")
                    thisCommentDict.setValue(String(NSDate()), forKey: "createdAt")
                    
                    finalCommentDict.append(thisCommentDict)
                    
                    
                    mutableDataDict.setValue(finalCommentDict, forKey: "comments")
                    Parser.workitemForDictionary(mutableDataDict)

                    if let senderController =   actionProperty.senderViewController as? DetailViewController{
                        senderController.updateAndReloadTableview()
                    }
                    if let senderController =   actionProperty.senderViewController as? CardViewController{
                        senderController.tableView.reloadData()
                    }
                }
            }
        }
        else{
        
//        print("GOT COMMENT DATA:>>>> \(actionProperty) >>>>:\(actionProperty.text)")
        
        
        guard let commentText = actionProperty.text else{
            print("commentText is Nil")
            return
        }
            
            
            
            LoadingController.instance.showLoadingWithOverlayForSender(actionProperty.senderViewController ?? getTopViewController()!, cancel: true)

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {

        var attachmentDictArray =  [NSDictionary]()
        
        if let attachments = actionProperty.attachments{
            for i in 0..<attachments.count{
                if let imageDataInbase64StringFormat = Helper.base64ForImage(compressedDataForImage(attachments[i]) ?? UIImage()){
                    attachmentDictArray.append(NSDictionary(object: imageDataInbase64StringFormat, forKey: "Attachment\(i)"))
                }
            }
        }
        
        
        
        print("WILL COMMENT :>>>> \(unwrappedWorkitemId) >>>>:\(actionProperty.text)")
        
                
        
        Alamofire.request(Router.CommentOnWorkitem(id: unwrappedWorkitemId, commentText: commentText, attachments: attachmentDictArray)).responseJSON { response in
            LoadingController.instance.hideLoadingView()

            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    var message = jsonData[kServerKeyMessage]?.lowercaseString
                    
                    let banner = Banner(title: "Notification", subtitle: message, image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                    
//                    print("Error Occured: JSON Without success " + String(jsonData))
                    return
                }
                
                self.updateCoredataWorkitem(unwrappedWorkitemId, senderViewController: actionProperty.senderViewController)
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "sessionExpired"
                }
                let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:NSLocalizedString(message ?? "", comment: "") , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                if let senderController =   actionProperty.senderViewController{
                    senderController.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
        }
        
        dismissPresentedController()

    }
    
    
    
    ///APPROVE
    func approve(actionProperty : ActionProperty) {

        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("unwrapping WorkitemId failed")
            return
        }
        
        workItemData =  Parser.fetchWorkitem(forId: unwrappedWorkitemId)
        
        guard let unwrappedWorkitemData = workItemData?.workitemData else{
            return
        }
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedWorkitemData) as! NSDictionary
        
        let contentId = dataDictionary.valueForKeyPath("content.id") as? String
        
        let cardType = CardType(value: workItemData?.cardType)
        let cardSubtype = CardSubtype(value: workItemData?.cardSubtype)
        
        switch (cardType){
        case .TaskType:
            switch(cardSubtype){
            case .BPMTask : bpmApprovalServiceCall(actionProperty,actiontype: true,contentId: contentId)
            default:
                break
            }
            
        case .TimesheetType:
            switch(cardSubtype){
            case .Approve: timesheetApproveServiceCall(actionProperty)
            default:
                break
            }
        case .Performance:
            switch(cardSubtype){
            case .PMSApproval: PMSApproveServiceCall(actionProperty)
            default: break
            }
            
        case .Recruitment:
            switch(cardSubtype){
            case .requisition : PMSApproveServiceCall(actionProperty)
                
                
           case .offerRollout: PMSApproveServiceCall(actionProperty)
            default: break
            }
        default:
            break
        }
     
        
        
        
    }
    
    func bpmApprovalServiceCall(actionProperty : ActionProperty,actiontype:Bool,contentId:String?){
        
        
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("unwrapping WorkitemId failed")
            return
        }
        guard let unwrappedcontentId = contentId else{
            return
        }
        
 
        
            if !Helper.isConnectedToInternet(){
                actionProperty.createdAt = String(NSDate())
                Parser.SetOfflineAction(actionProperty)
            }
            else{
                print("WILL Approve  :>>>> \(unwrappedWorkitemId)")
                print(Router.baseURLString)
                
                Alamofire.request(Router.ApproveBMPTask(contentId: unwrappedcontentId, actionType: actiontype)).responseJSON { response in
                    switch response.result {
                    case .Success(let JSON):
                        print("Success with JSON")
                        print(JSON)

                        guard let jsonData = JSON as? NSDictionary else{
                            print("Incorrect JSON from server : \(JSON)")
                            return
                        }
                        guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                            var message = jsonData[kServerKeyMessage]?.lowercaseString
                            
                            let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                            alertController.addAction(okAction)
                            
                            if let senderController =   actionProperty.senderViewController{
                                senderController.presentViewController(alertController, animated: true, completion: nil)
                            }
                            
                            print("Error Occured: JSON Without success:\(jsonData) ")
                            return
                        }
                        print("DID Reject : On workitem: \(unwrappedWorkitemId)")
                        if actiontype{
                            let banner = Banner(title: "Notification", subtitle: "Task Approved successfully", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                            banner.dismissesOnTap = true
                            banner.show(duration: 3.0)
                        }
                        else{
                        let banner = Banner(title: "Notification", subtitle: "Task rejected successfully", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                        banner.dismissesOnTap = true
                        banner.show(duration: 3.0)
                        }
                        self.updateCoredataWorkitem(unwrappedWorkitemId, senderViewController: actionProperty.senderViewController)
                        
                         //approved in CardViewController
                        if let unwrappedCardViewController = actionProperty.senderViewController as? CardViewController{
                            unwrappedCardViewController.clearAndReloadTableviewData()
                        }

                        
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                        var message = error.localizedDescription
                        if error.code == 403 {
                            message = "Session Expired"
                            
                            let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:NSLocalizedString(message ?? "", comment: "") , preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                            alertController.addAction(okAction)
                            if let senderController = actionProperty.senderViewController{
                                senderController.presentViewController(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
    }
    
    
    func timesheetApproveServiceCall(actionProperty : ActionProperty){
        
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("unwrapping WorkitemId failed")
            return
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("timesheetApprovalAlertControllerTitle", comment: "Alert Controller Title"), message: NSLocalizedString("timesheetApprovalAlertMessage", comment: ""), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .Cancel) { (action) in
            print("Approval Cancelled")
        }
        alertController.addAction(cancelAction)
        
        let ApproveAction = UIAlertAction(title: NSLocalizedString("approveActionTitle", comment: ""), style: .Default) { (action) in
            
            if !Helper.isConnectedToInternet(){
                actionProperty.createdAt = String(NSDate())
                Parser.SetOfflineAction(actionProperty)
            }
            else{
                print("WILL Approve  :>>>> \(unwrappedWorkitemId)")
                Alamofire.request(Router.Approve(workitemId: unwrappedWorkitemId)).responseJSON { response in
                    switch response.result {
                    case .Success(let JSON):
                        print("Success with JSON")
                        
                        guard let jsonData = JSON as? NSDictionary else{
                            print("Incorrect JSON from server : \(JSON)")
                            return
                        }
                        guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                            var message = jsonData[kServerKeyMessage]?.lowercaseString
                            
                            let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                            alertController.addAction(okAction)
                            
                            if let senderController =   actionProperty.senderViewController{
                                senderController.presentViewController(alertController, animated: true, completion: nil)
                            }
                            
                            print("Error Occured: JSON Without success:\(jsonData) ")
                            return
                        }
                        print("DID APPROVE : On workitem: \(unwrappedWorkitemId)")
                        
                        self.updateCoredataWorkitem(unwrappedWorkitemId, senderViewController: actionProperty.senderViewController)
                        
                        // approved in TSApprovalDetailViewController
                        if let unwrappedCardViewController = self.cardViewController{
                            unwrappedCardViewController.clearAndReloadTableviewData()
                        }
                        //approved in TSApprovalController
                        if let unwrappedCardViewController = actionProperty.senderViewController as? TSApprovalController{
                            unwrappedCardViewController.clearAndReloadTableviewData()
                        }
                        // approved in CardViewController
                        if let unwrappedCardViewController = actionProperty.senderViewController as? CardViewController{
                            unwrappedCardViewController.clearAndReloadTableviewData()
                        }
                        
                        if let tsApprovalDetailController = actionProperty.senderViewController  as? TSApprovalDetailController{
                            if let tsApprovalController = tsApprovalDetailController.navigationController?.viewControllers[0] as? TSApprovalController{
                                tsApprovalController.clearAndReloadTableviewData()
                            }
                        }
                        
                        if let unwrapperTSApprovalDetailController = actionProperty.senderViewController as? TSApprovalDetailController{
                            unwrapperTSApprovalDetailController.navigationController?.popViewControllerAnimated(true)
                        }
                        
                        
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                        var message = error.localizedDescription
                        if error.code == 403 {
                            message = "Session Expired"
                            
                            let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:NSLocalizedString(message ?? "", comment: "") , preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                            alertController.addAction(okAction)
                            if let senderController = actionProperty.senderViewController{
                                senderController.presentViewController(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
            
            
            
        }
        alertController.addAction(ApproveAction)
        
        if let topVC = actionProperty.senderViewController{
            topVC.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    
    //PMS Approval service call 
    func PMSApproveServiceCall(actionProperty : ActionProperty){
        
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("unwrapping WorkitemId failed")
            return
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("pmsApprovalAlertControllerTitle", comment: "Alert Controller Title"), message: NSLocalizedString("timesheetApprovalAlertMessage", comment: ""), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .Cancel) { (action) in
            print("Approval Cancelled")
        }
        alertController.addAction(cancelAction)
        
        let ApproveAction = UIAlertAction(title: NSLocalizedString("approveActionTitle", comment: ""), style: .Default) { (action) in
            
            if !Helper.isConnectedToInternet(){
                actionProperty.createdAt = String(NSDate())
                Parser.SetOfflineAction(actionProperty)
            }
            else{
                print("WILL Approve  :>>>> \(unwrappedWorkitemId)")
                Alamofire.request(Router.Approve(workitemId: unwrappedWorkitemId)).responseJSON { response in
                    switch response.result {
                    case .Success(let JSON):
                        print("Success with JSON")
                        
                        guard let jsonData = JSON as? NSDictionary else{
                            print("Incorrect JSON from server : \(JSON)")
                            return
                        }
                        guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                            var message = jsonData[kServerKeyMessage]?.lowercaseString
                            
                            let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                            alertController.addAction(okAction)
                            
                            if let senderController =   actionProperty.senderViewController{
                                senderController.presentViewController(alertController, animated: true, completion: nil)
                            }
                            
                            print("Error Occured: JSON Without success:\(jsonData) ")
                            return
                        }
                        print("DID APPROVE : On workitem: \(unwrappedWorkitemId)")
                        
//                        self.updateCoredataWorkitem(unwrappedWorkitemId, senderViewController: actionProperty.senderViewController)
                        
//                        // approved in TSApprovalDetailViewController
//                        if let unwrappedCardViewController = self.cardViewController{
//                            unwrappedCardViewController.clearAndReloadTableviewData()
//                        }
//                        //approved in TSApprovalController
//                        if let unwrappedCardViewController = actionProperty.senderViewController as? TSApprovalController{
//                            unwrappedCardViewController.clearAndReloadTableviewData()
//                        }
                        
                        // approved in CardViewController
                        if let unwrappedCardViewController = actionProperty.senderViewController as? CardViewController{
                            unwrappedCardViewController.clearAndReloadTableviewData()
                        }
                        
//                        if let tsApprovalDetailController = actionProperty.senderViewController  as? TSApprovalDetailController{
//                            if let tsApprovalController = tsApprovalDetailController.navigationController?.viewControllers[0] as? TSApprovalController{
//                                tsApprovalController.clearAndReloadTableviewData()
//                            }
//                        }
//                        
//                        if let unwrapperTSApprovalDetailController = actionProperty.senderViewController as? TSApprovalDetailController{
//                            unwrapperTSApprovalDetailController.navigationController?.popViewControllerAnimated(true)
//                        }
//                        
                        
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                        var message = error.localizedDescription
                        if error.code == 403 {
                            message = "Session Expired"
                            
                            let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:NSLocalizedString(message ?? "", comment: "") , preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                            alertController.addAction(okAction)
                            if let senderController = actionProperty.senderViewController{
                                senderController.presentViewController(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
            
            
            
        }
        alertController.addAction(ApproveAction)
        
        if let topVC = actionProperty.senderViewController{
            topVC.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //    approveALL
    func approveAll(workItemIdArray : [String], sentBy : UIViewController?) {
        Alamofire.request(Router.ApproveAll(workitemIdArray: workItemIdArray)).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    var message = jsonData[kServerKeyMessage]?.lowercaseString
                    
                    let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    
                    if let senderController =   sentBy{
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                    print("Error Occured: JSON Without success:\(jsonData) ")
                    return
                }
                print("DID APPROVE : On workitem: \(workItemIdArray)")
                
                if let unwrappedCardViewController = self.cardViewController{
                    unwrappedCardViewController.clearAndReloadTableviewData()
                }
                
                if let unwrappedCardViewController = sentBy as? TSApprovalController{
                    unwrappedCardViewController.clearAndReloadTableviewData()
                }
                
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
        
    }
    
    func approveOfflineActionSilently(actionProperty : ActionProperty) {
        
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("unwrapping WorkitemId failed")
            return
        }
        Alamofire.request(Router.Approve(workitemId: unwrappedWorkitemId)).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    var message = jsonData[kServerKeyMessage]?.lowercaseString
                    
                    let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    
                    if let senderController =   actionProperty.senderViewController{
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                    print("Error Occured: JSON Without success:\(jsonData) ")
                    return
                }
                print("DID APPROVE : On workitem: \(unwrappedWorkitemId)")
                
                self.updateCoredataWorkitem(unwrappedWorkitemId, senderViewController: actionProperty.senderViewController)
                
                // approved in TSApprovalDetailViewController
                if let unwrappedCardViewController = self.cardViewController{
                    unwrappedCardViewController.clearAndReloadTableviewData()
                }
                //approved in TSApprovalController
                if let unwrappedCardViewController = actionProperty.senderViewController as? TSApprovalController{
                    unwrappedCardViewController.clearAndReloadTableviewData()
                }
                // approved in CardViewController
                if let unwrappedCardViewController = actionProperty.senderViewController as? CardViewController{
                    unwrappedCardViewController.clearAndReloadTableviewData()
                }
                
                if let tsApprovalDetailController = actionProperty.senderViewController  as? TSApprovalDetailController{
                    if let tsApprovalController = tsApprovalDetailController.navigationController?.viewControllers[0] as? TSApprovalController{
                        tsApprovalController.clearAndReloadTableviewData()
                    }
                }
                
                if let unwrapperTSApprovalDetailController = actionProperty.senderViewController as? TSApprovalDetailController{
                    unwrapperTSApprovalDetailController.navigationController?.popViewControllerAnimated(true)
                }
                
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                
                
            }
        }
    }
    
    
    
    
    
    ///REJECT
    func reject(actionProperty : ActionProperty) {
        
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("unwrapping WorkitemId failed")
            return
        }
        
        let textInputViewController = TextInputBarController()
        
        var actionProp = ActionProperty()
        actionProp.actionType = CardAction.Reject
        actionProp.workitemId = unwrappedWorkitemId
        actionProp.senderViewController = actionProperty.senderViewController
        
        
        textInputViewController.actionProperty = actionProp
        textInputViewController.modalPresentationStyle = .OverCurrentContext
        
        if let topVC = actionProperty.senderViewController{
            topVC.presentViewController(textInputViewController, animated: true, completion: nil)
        }
        
    }
    
    
    func RejectWithReason(actionProperty : ActionProperty) {
        
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("unwrapping WorkitemId failed")
            return
        }
        
        workItemData =  Parser.fetchWorkitem(forId: unwrappedWorkitemId)
        
        guard let unwrappedWorkitemData = workItemData?.workitemData else{
            return
        }
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedWorkitemData) as! NSDictionary
        
        let contentId = dataDictionary.valueForKeyPath("content.id") as? String
        
        let cardType = CardType(value: workItemData?.cardType)
        let cardSubtype = CardSubtype(value: workItemData?.cardSubtype)
        
        switch (cardType){
        case .TaskType:
            switch(cardSubtype){
            case .BPMTask : bpmApprovalServiceCall(actionProperty,actiontype: false,contentId: contentId)
            default:
                break
            }
            
        case .TimesheetType:
            switch(cardSubtype){
            case .Approve: timesheetRejectWithReasonServiceCall(actionProperty)
            default:
                break
            }
            
        case .Performance:
            switch(cardSubtype){
            case .PMSApproval: PMSRejectWithReasonServiceCall(actionProperty)
            default:
                break
            }
        default:
            break
        }
        
        
        
    }
    
    
    
    func timesheetRejectWithReasonServiceCall(actionProperty : ActionProperty){
        
        
        if let topVC = actionProperty.senderViewController{
            if let unwrappedPresentedViewController = topVC.presentedViewController as? TextInputBarController {
                unwrappedPresentedViewController.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("unwrapping WorkitemId failed")
            return
        }
        guard let reasonText  = actionProperty.text else{
            print("unwrapping WorkitemId failed")
            return
        }
        
        if !Helper.isConnectedToInternet(){
            actionProperty.createdAt = String(NSDate())
            Parser.SetOfflineAction(actionProperty)
        }
        else{
            
            
            print("WILL REJECT  :>>>> \(unwrappedWorkitemId)")
            Alamofire.request(Router.Reject(workitemId: unwrappedWorkitemId,reason: reasonText)).responseJSON { response in
                switch response.result {
                case .Success(let JSON):
                    print("Success with JSON")
                    
                    print(JSON)

                    
                    guard let jsonData = JSON as? NSDictionary else{
                        print("Incorrect JSON from server : \(JSON)")
                        return
                    }
                    guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                        var message = jsonData[kServerKeyMessage]?.lowercaseString
                        
                        let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        
                        if let senderController =   actionProperty.senderViewController{
                            senderController.presentViewController(alertController, animated: true, completion: nil)
                        }
                        print("Error Occured: JSON Without success:\(jsonData) ")
                        return
                    }
                    print("DID REJECT : On workitem: \(unwrappedWorkitemId)")
                    
                    // rejected in TSApprovalController
                    if let unwrappedCardViewController = actionProperty.senderViewController as? TSApprovalController{
                        unwrappedCardViewController.clearAndReloadTableviewData()
                    }
                    // rejected in TSApprovalDetialController
                    if let unwrappedCardViewController = self.cardViewController{
                        unwrappedCardViewController.clearAndReloadTableviewData()
                    }
                    if let tsApprovalDetailController = actionProperty.senderViewController as? TSApprovalDetailController{
                        if let tsApprovalController = tsApprovalDetailController.navigationController?.viewControllers[0] as? TSApprovalController{
                            tsApprovalController.clearAndReloadTableviewData()
                        }
                    }
                    
                    if let unwrapperTSApprovalDetailController = actionProperty.senderViewController as? TSApprovalDetailController{
                        unwrapperTSApprovalDetailController.navigationController?.popViewControllerAnimated(true)
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    var message = error.localizedDescription
                    if error.code == 403 {
                        message = "Session Expired"
                    }
                    let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:NSLocalizedString(message ?? "", comment: "") , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    if let senderController = actionProperty.senderViewController {
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                }
            }
        }

    }
    
    
    //PMS reject service call 
    func PMSRejectWithReasonServiceCall(actionProperty : ActionProperty){
        
        
        if let topVC = actionProperty.senderViewController{
            if let unwrappedPresentedViewController = topVC.presentedViewController as? TextInputBarController {
                unwrappedPresentedViewController.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("unwrapping WorkitemId failed")
            return
        }
        guard let reasonText  = actionProperty.text else{
            print("unwrapping WorkitemId failed")
            return
        }
        
        if !Helper.isConnectedToInternet(){
            actionProperty.createdAt = String(NSDate())
            Parser.SetOfflineAction(actionProperty)
        }
        else{
            
            
            print("WILL REJECT  :>>>> \(unwrappedWorkitemId)")
            Alamofire.request(Router.Reject(workitemId: unwrappedWorkitemId,reason: reasonText)).responseJSON { response in
                switch response.result {
                case .Success(let JSON):
                    print("Success with JSON")
                    print(JSON)

                    
                    
                    guard let jsonData = JSON as? NSDictionary else{
                        print("Incorrect JSON from server : \(JSON)")
                        return
                    }
                    guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                        var message = jsonData[kServerKeyMessage]?.lowercaseString
                        
                        let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        
                        if let senderController =   actionProperty.senderViewController{
                            senderController.presentViewController(alertController, animated: true, completion: nil)
                        }
                        print("Error Occured: JSON Without success:\(jsonData) ")
                        return
                    }
                    print("DID REJECT : On workitem: \(unwrappedWorkitemId)")
                    
                    // rejected in TSApprovalController
//                    if let unwrappedCardViewController = actionProperty.senderViewController as? TSApprovalController{
//                        unwrappedCardViewController.clearAndReloadTableviewData()
//                    }
                    // rejected in TSApprovalDetialController
//                    if let unwrappedCardViewController = self.cardViewController{
//                        unwrappedCardViewController.clearAndReloadTableviewData()
//                    }
                
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    var message = error.localizedDescription
                    if error.code == 403 {
                        message = "Session Expired"
                    }
                    let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:NSLocalizedString(message ?? "", comment: "") , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    if let senderController = actionProperty.senderViewController {
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                }
            }
        }
        
    }

    ///COMPLETE TASK
    func completeTask(actionProperty : ActionProperty) {
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print(#function + "unwrapping WorkitemId failed")
            return
        }
        let alertController = UIAlertController(title: NSLocalizedString("completeTaskAlertControllerTitle", comment: ""), message: NSLocalizedString("completeTaskAlertMessage", comment: ""), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .Cancel) { (action) in
            print("Cancelled")
        }
        alertController.addAction(cancelAction)
        
        let completeAction = UIAlertAction(title: NSLocalizedString("completeActionTitle", comment: ""), style: .Default) { (action) in
            
            print("Will " + #function + "\(unwrappedWorkitemId)")
            self.request?.cancel()
            LoadingController.instance.showLoadingWithOverlayForSender(self.cardViewController!, cancel: false)

            self.request = Alamofire.request(Router.CompleteTask(workitemId: unwrappedWorkitemId)).responseJSON { response in
                LoadingController.instance.hideLoadingView()

                switch response.result {
                case .Success(let JSON):
                    print("Success with JSON")
                    
                    guard let jsonData = JSON as? NSDictionary else{
                        print("Incorrect JSON from server : \(JSON)")
                        return
                    }
                    guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                        let message = jsonData[kServerKeyMessage]?.lowercaseString
                        
                        let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        
                        if let senderController =   actionProperty.senderViewController{
                            senderController.presentViewController(alertController, animated: true, completion: nil)
                        }
                        print("Error Occured: JSON Without success:\(jsonData) ")
                        return
                    }
                    let banner = Banner(title: "Notification", subtitle: "Task completed successfully", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                    
                    print("Did " + #function + "\(unwrappedWorkitemId)")
                    self.updateCoredataWorkitem(unwrappedWorkitemId, senderViewController: actionProperty.senderViewController)
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    
                }
            }
        }
        alertController.addAction(completeAction)
        if let topVC = actionProperty.senderViewController{
            topVC.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    ///CLOSE TASK
    func closeTask(actionProperty : ActionProperty) {
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print(#function + "unwrapping WorkitemId failed")
            return
        }
        let alertController = UIAlertController(title: NSLocalizedString("closeTaskAlertControllerTitle", comment: ""), message: NSLocalizedString("closeTaskAlertMessage", comment: ""), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .Cancel) { (action) in
            print("Cancelled")
        }
        alertController.addAction(cancelAction)
        
        let closeAction = UIAlertAction(title: NSLocalizedString("closeActionTitle", comment: ""), style: .Default) { (action) in
        print("Will " + #function + "\(unwrappedWorkitemId)")
        self.request?.cancel()
            LoadingController.instance.showLoadingWithOverlayForSender(self.cardViewController!, cancel: false)

        self.request = Alamofire.request(Router.CloseTask(workitemId: unwrappedWorkitemId)).responseJSON { response in
            LoadingController.instance.hideLoadingView()
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    var message = jsonData[kServerKeyMessage]?.lowercaseString
                    
                    let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    
                    if let senderController =   actionProperty.senderViewController{
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                    print("Error Occured: JSON Without success:\(jsonData) ")
                    return
                }
                let banner = Banner(title: "Notification", subtitle: "Task closed successfully", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                print("Did " + #function + "\(unwrappedWorkitemId)")
                self.updateCoredataWorkitem(unwrappedWorkitemId, senderViewController: actionProperty.senderViewController)
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                var message = error.localizedDescription
                
                let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                
                if let senderController =   actionProperty.senderViewController{
                    senderController.presentViewController(alertController, animated: true, completion: nil)
                }
                
            }
            }
        }
        alertController.addAction(closeAction)
        if let topVC = actionProperty.senderViewController{
            topVC.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    ///HOLD TASK
    func holdTask(actionProperty : ActionProperty) {
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print(#function + "unwrapping WorkitemId failed")
            return
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("holdTaskAlertControllerTitle", comment: ""), message: NSLocalizedString("holdTaskAlertMessage", comment: ""), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .Cancel) { (action) in
            print("Cancelled")
        }
        
        alertController.addAction(cancelAction)
        
        let holdAction = UIAlertAction(title: NSLocalizedString("holdActionTitle", comment: ""), style: .Default) { (action) in
            print("Will " + #function + "\(unwrappedWorkitemId)")
            self.request?.cancel()
            LoadingController.instance.showLoadingWithOverlayForSender(self.cardViewController!, cancel: false)

            self.request = Alamofire.request(Router.HoldTask(workitemId: unwrappedWorkitemId)).responseJSON { response in
                LoadingController.instance.hideLoadingView()
                switch response.result {
                case .Success(let JSON):
                    print("Success with JSON")
                    
                    guard let jsonData = JSON as? NSDictionary else{
                        print("Incorrect JSON from server : \(JSON)")
                        return
                    }
                    guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                        var message = jsonData[kServerKeyMessage]?.lowercaseString
                        
                        let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        
                        if let senderController =   actionProperty.senderViewController{
                            senderController.presentViewController(alertController, animated: true, completion: nil)
                        }
                        print("Error Occured: JSON Without success:\(jsonData) ")
                        return
                    }
                    let banner = Banner(title: "Notification", subtitle: "Task held successfully", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                    print("Did " + #function + "\(unwrappedWorkitemId)")
                    self.updateCoredataWorkitem(unwrappedWorkitemId, senderViewController: actionProperty.senderViewController)
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    
                }
            }
        }
        alertController.addAction(holdAction)
        if let topVC = actionProperty.senderViewController{
            topVC.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    ///WITHDRAW TASK
    func withdrawTask(actionProperty : ActionProperty) {
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print(#function + "unwrapping WorkitemId failed")
            return
        }
        let alertController = UIAlertController(title: NSLocalizedString("withdrawTaskAlertControllerTitle", comment: ""), message: NSLocalizedString("withdrawTaskAlertMessage", comment: ""), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .Cancel) { (action) in
            print("Cancelled")
        }
        
        alertController.addAction(cancelAction)
        
        let withdrawAction = UIAlertAction(title: NSLocalizedString("withdrawActionTitle", comment: ""), style: .Default) { (action) in
            print("Will " + #function + "\(unwrappedWorkitemId)")
            self.request?.cancel()
            LoadingController.instance.showLoadingWithOverlayForSender(self.cardViewController!, cancel: false)

            self.request = Alamofire.request(Router.WithdrawTask(workitemId: unwrappedWorkitemId)).responseJSON { response in
                LoadingController.instance.hideLoadingView()
                switch response.result {
                case .Success(let JSON):
                    print("Success with JSON")
                    
                    guard let jsonData = JSON as? NSDictionary else{
                        print("Incorrect JSON from server : \(JSON)")
                        return
                    }
                    guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                        let message = jsonData[kServerKeyMessage]?.lowercaseString
                        
                        let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        
                        if let senderController =   actionProperty.senderViewController{
                            senderController.presentViewController(alertController, animated: true, completion: nil)
                        }
                        print("Error Occured: JSON Without success:\(jsonData) ")
                        return
                    }
                    let banner = Banner(title: "Notification", subtitle: "Task withdrawn successfully", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                    print("Did " + #function + "\(unwrappedWorkitemId)")
                    
                    self.updateCoredataWorkitem(unwrappedWorkitemId, senderViewController: actionProperty.senderViewController)
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    
                }
            }
        }
        alertController.addAction(withdrawAction)
        if let topVC = actionProperty.senderViewController{
            topVC.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // ReOpen  task
    func reopenTask(actionProperty : ActionProperty) {
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print(#function + "unwrapping WorkitemId failed")
            return
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("reopenTaskAlertControllerTitle", comment: ""), message: NSLocalizedString("reopenTaskAlertMessage", comment: ""), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .Cancel) { (action) in
            print("Cancelled")
        }
        
        alertController.addAction(cancelAction)
        
        let reopenAction = UIAlertAction(title: NSLocalizedString("reopenActionTitle", comment: ""), style: .Default) { (action) in
            print("Will " + #function + "\(unwrappedWorkitemId)")
            self.request?.cancel()
            LoadingController.instance.showLoadingWithOverlayForSender(self.cardViewController!, cancel: false)

            self.request = Alamofire.request(Router.ReopenTask(workitemId: unwrappedWorkitemId)).responseJSON { response in
                LoadingController.instance.hideLoadingView()
                switch response.result {
                case .Success(let JSON):
                    print("Success with JSON")
                    
                    guard let jsonData = JSON as? NSDictionary else{
                        print("Incorrect JSON from server : \(JSON)")
                        return
                    }
                    guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                        var message = jsonData[kServerKeyMessage]?.lowercaseString
                        
                        let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        
                        if let senderController =   actionProperty.senderViewController{
                            senderController.presentViewController(alertController, animated: true, completion: nil)
                        }
                        print("Error Occured: JSON Without success:\(jsonData) ")
                        return
                    }
                    let banner = Banner(title: "Notification", subtitle: "Task reopened successfully", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                    print("Did " + #function + "\(unwrappedWorkitemId)")
                    self.updateCoredataWorkitem(unwrappedWorkitemId, senderViewController: actionProperty.senderViewController)
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    let message = error.localizedDescription
                    
                    let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title:  NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    
                    if let senderController =   actionProperty.senderViewController{
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                }
            }
        }
        alertController.addAction(reopenAction)
        if let topVC = actionProperty.senderViewController{
            topVC.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    ///DELEGATE TASK
    func delegateTask(actionProperty : ActionProperty) {
        //Sharecontroller is re-used for delegate also

        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("unwrapping WorkitemId failed")
            return
        }
        
        workItemData =  Parser.fetchWorkitem(forId: unwrappedWorkitemId)
        
        guard let unwrappedWorkitemData = workItemData?.workitemData else{
            return
        }
   
        
        let cardType = CardType(value: workItemData?.cardType)
        let cardSubtype = CardSubtype(value: workItemData?.cardSubtype)
        
        switch (cardType){
        case .TaskType:
            switch(cardSubtype){
            case .BPMTask :
                let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedWorkitemData) as! NSDictionary
                let contentId = dataDictionary.valueForKeyPath("content.id") as? String
                
                bpmDelegateServiceCall(actionProperty,contentId: contentId)
            case .ManualTaskType: presentShareViewController(actionProperty)
                
                
            default:
                break
            }
            
        default:
            break
        }
    }

    
    func bpmDelegateServiceCall(actionProperty:ActionProperty,contentId:String?){
        
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("unwrapping WorkitemId failed")
            return
        }
        guard let unwrappedcontentId = contentId else{
            return
        }
        
        print("WILL Delegate  :>>>> \(unwrappedWorkitemId)")
        print(Router.baseURLString)
        
        Alamofire.request(Router.DelegateBMPTask(contentId: unwrappedcontentId)).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    var message = jsonData[kServerKeyMessage]?.lowercaseString
                    
                    let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    
                    if let senderController =   actionProperty.senderViewController{
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                    print("Error Occured: JSON Without success:\(jsonData) ")
                    return
                }
                print("DID Delegate : On workitem: \(unwrappedWorkitemId)")
                
                let banner = Banner(title: "Notification", subtitle: "Task delegated successfully", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                
                //approved in CardViewController
                if let unwrappedCardViewController = actionProperty.senderViewController as? CardViewController{
                    unwrappedCardViewController.clearAndReloadTableviewData()
                }
                
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Session Expired"
                    
                    let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:NSLocalizedString(message ?? "", comment: "") , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    if let senderController = actionProperty.senderViewController{
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func updateCoredataWorkitem(workitemId : String, senderViewController : UIViewController?){
        print("[UPDATING COREDATA] FOR WORKITEM: \(workitemId)")

        Alamofire.request(Router.GetWorkitemDetail(id: workitemId)).responseJSON { response in
            LoadingController.instance.hideLoadingView()
            
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    print("Error Occured: JSON Without success")
                  
                    return
                }
                
                guard let jsonDataDictionary = jsonData.valueForKey("data") as? NSDictionary else{
                    print("Cannot cast JSON to Dictionary: \(JSON)")
                    return
                }
                
                Parser.workitemForDictionary(jsonDataDictionary)
                
                if let senderController =   senderViewController as? DetailViewController{
                    senderController.updateAndReloadTableview()
                }
                if let senderController =   senderViewController as? CardViewController{
                    senderController.tableView.reloadData()
                }
                if let senderController =   senderViewController as? CollaboratorController{
                    senderController.tableView.reloadData()
                }
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    
    
    func downloadAndUpdateConfiguration() {
        
        Alamofire.request(Router.GetConfiguration(email: UserDefaults.loggedInEmail()!)).responseJSON { response in
            //            EZLoadingActivity.hide()
            
            switch response.result {
                
            case .Success(let JSON):
                print(JSON)
                if let jsonDict = JSON as? NSDictionary {
                    let status = jsonDict[kServerKeyStatus]
                    
                    if status?.lowercaseString == kServerKeySuccess {
                        if let dataDict = jsonDict[kServerKeyData] as? NSDictionary {
                            
                            // Tabs
                            if let tabArray = dataDict["tabs"] as? NSArray {
                                for tabDict in tabArray as! [NSDictionary] {
                                    let _ = Parser.TabForDictionary(tabDict)
                                    //                                    print(tab?.id)
                                }
                            }
                            
                            // Side nav menu
                            if let navArray = dataDict["navigation"] as? NSArray {
                                for menuDict in navArray as! [NSDictionary] {
                                    let _ = Parser.menuForDictionary(menuDict)
                                    //                                    print(menu?.displayName)
                                    //                                    print(menu?.subMenus)
                                }
                            }
                            
                            // Card config
                            if let cardConfigDict = dataDict["cardConfig"] as? NSDictionary {
                                if let cardsArray = cardConfigDict["cards"] as? NSArray {
                                    for cardDict in cardsArray as! [NSDictionary] {
                                        let cardConfig = Parser.CardConfigForDictionary(cardDict)
                                        let cardSubType = CardSubtype(value: cardConfig?.subType)
                                    }
                                }
                                
                                if let cherryArray = cardConfigDict["types"] as? NSArray{
                                    for cherry in cherryArray{
                                        
                                        
                                        let cherryName = cherry["name"]
                                        
                                        switch cherryName! as! String{
                                            
                                            case "Champion Score Card":
                                            
                                                var rolesDict = [NSMutableDictionary]()
                                                if let userRole = cherry["roles"] as? NSArray {
                                                    print(userRole)
                                                    for item in userRole { // loop through data items
                                                        print(item)
                                                        
                                                        let role = NSMutableDictionary()
                                                        role.setValue(item["name"], forKey: "name")
                                                        role.setValue(item["roleText"], forKey: "roleText")
                                                        let roleVal = item["region"];
                                                        if !(roleVal is NSNull) {
                                                            role.setValue(item["region"], forKey: "region")
                                                        }else{
                                                            role.setValue(UserDefaults.userRegion(), forKey: "region")
                                                            
                                                        }
                                                        rolesDict.append(role)
                                                    }
                                                }
                                                
                                                self.cherryRoles.setValue(rolesDict, forKey: "Champion Score Card")
                                                
                                                
                                                break
                                                    
                                        
                                                    
                                            case "Performance Management System":
                                                
                                                 var rolesDict = [NSMutableDictionary]()
                                                if let userRole = cherry["roles"] as? NSArray {
                                                    print(userRole)
                                                    for item in userRole { // loop through data items
                                                        print(item)
                                                            
                                                        let role = NSMutableDictionary()
                                                        role.setValue(item["name"], forKey: "name")
                                                        role.setValue(item["displayName"], forKey: "displayName")
                                                        let hrFunc = item["hrFunction"]
                                                        if !(hrFunc is NSNull) {
                                                            role.setValue(item["hrFunction"], forKey: "hrFunction")
                                                        }

                                                        let roleVal = item["region"];
                                                        if !(roleVal is NSNull) {
                                                            role.setValue(item["region"], forKey: "region")
                                                        }else{
                                                            role.setValue(UserDefaults.userRegion(), forKey: "region")
                                                                
                                                        }
                                                        rolesDict.append(role)
                                                    }
                                                }
                                                 
                                                 
                                                 
                                                 self.cherryRoles.setValue(rolesDict, forKey: "Performance Management System")
                                                break
                                            
                                        case "Recruitment":
                                            var rolesDict = [NSMutableDictionary]()
                                            if let userRole = cherry["roles"] as? NSArray {
                                                print(userRole)
                                                for item in userRole { // loop through data items
                                                    print(item)
                                                    
                                                    let role = NSMutableDictionary()
                                                    role.setValue(item["name"], forKey: "name")
                                                    let hrFunc = item["hrFunction"]
                                                    if !(hrFunc is NSNull) {
                                                        role.setValue(item["hrFunction"], forKey: "hrFunction")
                                                    }
                                                    role.setValue(item["roleText"], forKey: "roleText")
                                                    let roleVal = item["region"];
                                                    if !(roleVal is NSNull) {
                                                        role.setValue(item["region"], forKey: "region")
                                                    }else{
                                                        role.setValue(UserDefaults.userRegion(), forKey: "region")
                                                        
                                                    }
                                                    rolesDict.append(role)
                                                }
                                            }
                                            
                                            self.cherryRoles.setValue(rolesDict, forKey: "Recruitment")
                                            
                                            break
                                            
                                        case "Learning Management System":
                                            break
                                        case "On Boarding":
                                            
                                            var rolesDict = [NSMutableDictionary]()
                                            if let userRole = cherry["roles"] as? NSArray {
                                                print(userRole)
                                                for item in userRole { // loop through data items
                                                    print(item)
                                                    
                                                    let role = NSMutableDictionary()
                                                    role.setValue(item["name"], forKey: "name")
                                                    role.setValue(item["displayName"], forKey: "displayName")
                                                    let hrFunc = item["hrFunction"]
                                                    if !(hrFunc is NSNull) {
                                                        role.setValue(item["hrFunction"], forKey: "hrFunction")
                                                    }
                                                    
                                                    let roleVal = item["region"];
                                                    if !(roleVal is NSNull) {
                                                        role.setValue(item["region"], forKey: "region")
                                                    }else{
                                                        role.setValue(UserDefaults.userRegion(), forKey: "region")
                                                        
                                                    }
                                                    rolesDict.append(role)
                                                }
                                            }
                                            
                                            
                                            
                                            self.cherryRoles.setValue(rolesDict, forKey: "On Boarding")
                                            break
                                            
                                        default:
                                            break
                                                        }

                                        
                                                
                                            }
                                            UserDefaults.setUserRole(self.cherryRoles)
                                            
                                        }
                                

                                
                                
                                
                            }
                            
                            //Filters
                            if let unwrappedDataDict = dataDict["filters"] as? [NSDictionary] {
                                Parser.filtersForDictionaryArray(unwrappedDataDict)
                            }
                            else{
                                print("Filters: casting to Dictionary Array failed")
                            }
                            
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            do {
                                try appDelegate.managedObjectContext.save()
                                UserDefaults.setIsConfigurationDownloaded(true)
                            } catch let error {
                                print("Coredata error: \(error)")
                            }
                            
                            //                            self.launchTabBar()
                        }
                    }
                    else if status?.lowercaseString == kServerKeyFailure {
                        var message = jsonDict[kServerKeyMessage] as? String
                        if response.response?.statusCode == ErrorCode.Forbidden.rawValue {
                            message = "Invalid credentials"
                        }
                        else if message == nil {
                            message = "An error occured"
                        }
                        #function
                        
                        let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title:  NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        
                        if let senderController =  getTopViewController(){
                            senderController.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                }
                
            case .Failure(let error):
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Seesion Expired"
                }
                #function
                let banner = Banner(title: "Notification", subtitle: "Configuration Download Failed", image: UIImage(named: "Icon"), backgroundColor: ConstantColor.CWRed)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                
            }
        }
    }
    
    
    func presentRadialMenuViewController(user:User){
        userInActionController = user
        let kRadialMenuButtonCount = 5
        if let topVC = getTopViewController(){
            topVC.view.endEditing(true)
            var buttons = [ALRadialMenuButton]()
            for _ in 0..<kRadialMenuButtonCount {
                let button = ALRadialMenuButton(frame: CGRectMake(0, 0, 60, 60))
                button.layer.cornerRadius = button.frame.size.width/2
                button.layer.borderColor = UIColor.grayColor().CGColor
                button.layer.borderWidth = 2
                button.clipsToBounds = true
                button.backgroundColor = UIColor.blackColor()
                buttons.append(button)
            }
            for i in 0..<buttons.count{
                switch i {
                case 0: buttons[i].setImage(AssetImage.call.image, forState: .Normal)
                if let userPhoneNumber = user.phoneNo{
                    buttons[i].titleLabel?.text = "\(userPhoneNumber)"
                }
                else{
                    print("Phone Number not available")
                    
                    }
                case 1: buttons[i].setImage(AssetImage.sms.image, forState: .Normal)
                case 2: buttons[i].setImage(AssetImage.emailWhite.image, forState: .Normal)
                case 3: buttons[i].setImage(AssetImage.hangout.image, forState: .Normal)
                default:buttons[i].setImage(AssetImage.cross.image, forState: .Normal)
                }
                
            }
            
            let point :CGPoint = CGPoint(x: topVC.view.frame.size.width/2, y: topVC.view.frame.size.height/2)
            
            
            let rad = ALRadialMenu()
                .setButtons(buttons)
                .setDelay(0.05)
                .setAnimationOrigin(point)
                .presentInView(topVC.view)
            rad.delegate = self
            
        }
    }
    
    func getButtonIndex(i : Int) {
        print(i)
    }
    
    func messageAction() {
        if let topVC = getTopViewController(){
            if MFMessageComposeViewController.canSendText(){
                let messageVC = MFMessageComposeViewController()
                if Helper.lengthOfStringWithoutSpace(userInActionController.phoneNo) > 6{
                    messageVC.recipients = [userInActionController.phoneNo!] // Optionally add some tel numbers
                    messageVC.messageComposeDelegate = self
                    // Open the SMS View controller
                    topVC.presentViewController(messageVC, animated: true, completion: nil)
                }
                else{
                    print("cant send text")
                    
                    let alertController = UIAlertController.init(title: NSLocalizedString("actionNotPossible", comment: ""), message: NSLocalizedString("phoneNumberNotAvailable", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    topVC.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func mailAction() {
        if let topVC = getTopViewController(){
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                if let email = userInActionController.email{
                    if Helper.isValidEmail(email){
                        mail.setToRecipients([email])
                        topVC.presentViewController(mail, animated: true, completion: nil)
                    }
                    else{
                        let alertController = UIAlertController.init(title: NSLocalizedString("actionNotPossible", comment: ""), message: NSLocalizedString("emailNotAvailable", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        topVC.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                else{
                    // show failure alert
                    let alertController = UIAlertController.init(title: NSLocalizedString("actionNotPossible", comment: ""), message: NSLocalizedString("emailNotAvailable", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    topVC.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            else{
                // show failure alert
                let alertController = UIAlertController.init(title: NSLocalizedString("actionNotPossible", comment: ""), message: "Mail not enabled", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                topVC.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue :
            print("message canceled")
            
        case MessageComposeResultFailed.rawValue :
            print("message failed")
            
        case MessageComposeResultSent.rawValue :
            print("message sent")
            
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue :
            print("mail canceled")
            
        case MessageComposeResultFailed.rawValue :
            print("mail failed")
            
        case MessageComposeResultSent.rawValue :
            print("mail sent")
            
        default:
            break
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showMoreActions(actionProperty : ActionProperty){
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            return
        }
//        let workitem = Parser.fetchWorkitem(forId: unwrappedWorkitemId)
//        let cardType = CardType(value : workitem?.cardType)
//        let cardSubtype = CardSubtype(value : workitem?.cardSubtype)
        
//        var actionArray = Parser.fetchActions(forType: cardType, forSubtype: cardSubtype, forCardStatus: CardStatus.Unknown)
        var actionArray = moreActionsArray
        let maxNumOfActionButtonsShown = 3 //Hardcoding it as our app need max 3 buttons
        
        let alertController = UIAlertController(title: NSLocalizedString("moreTaskAlertControllerTitle", comment: ""), message: nil , preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .Cancel) { (action) in
            print("More actions Cancelled")
        }
        alertController.addAction(cancelAction)
        
        for i in 0..<actionArray.count{
            if i >= (maxNumOfActionButtonsShown-1){
                let moreAction = UIAlertAction(title: actionArray[i].displayStringBasedOn(actionProperty), style: .Default) {
                    (action) in
                    let actionButton = ActionButton()
                    actionProperty.actionType = actionArray[i]
                    actionButton.actionProperty = actionProperty
                    self.actionOnActionButtonTapped(actionButton)
                }
                
                alertController.addAction(moreAction)
            }
        }
        
        if let topVC = getTopViewController(){
            topVC.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: - Generic Button Action
    func actionOnActionButtonTapped(sender : ActionButton){
        guard let unwrappedActionProperty = sender.actionProperty else{
            print("unwrappedActionProperty nil on ActionController")
            return
        }
        print(unwrappedActionProperty.actionType)
        
        switch unwrappedActionProperty.actionType ?? CardAction.UnknownAction{
        case .Comment:
            presentCommentViewController(unwrappedActionProperty)
        case .Like:
            updateButtonContentAndPerformAPICall(sender)
        case .Share:
            presentShareViewController(unwrappedActionProperty)
        case .Approve:
            approve(unwrappedActionProperty)
        case .Reject:
            reject(unwrappedActionProperty)
        
        //TASKS
        case .CompleteTask:
            completeTask(unwrappedActionProperty)
        case .CloseTask:
            closeTask(unwrappedActionProperty)
        case .HoldTask:
            holdTask(unwrappedActionProperty)
        case .WithdrawTask:
            withdrawTask(unwrappedActionProperty)
        case .DelegateTask:
            delegateTask(unwrappedActionProperty)
        case .ReopenTask:
            reopenTask(unwrappedActionProperty)
            
        case .More:
            showMoreActions(unwrappedActionProperty)
            
        default:
            print("Unknown Action")
        }
    }
    
    /// Like/Unlike Action
    func updateButtonContentAndPerformAPICall(sender : ActionButton){
        guard let unwrappedActionProperty = sender.actionProperty else{
            return
        }
        guard let unwrappedActionType = unwrappedActionProperty.actionType else{
            return
        }
        if unwrappedActionType == CardAction.Like{
            if unwrappedActionProperty.likedBySelf {
                sender.setTitleColor(ConstantColor.CWButtonGray, forState: .Normal)
                self.unlike(unwrappedActionProperty)
            }
            else{
                sender.setTitleColor(ConstantColor.CWBlue, forState: .Normal)
                self.like(unwrappedActionProperty)
            }
        }
    }
    
    //MARK: - Show Controller Method
    func presentCommentViewController(actionProperty : ActionProperty){
        let commentViewController = TextInputBarController()
        commentViewController.actionProperty = actionProperty
        commentViewController.modalPresentationStyle = .OverCurrentContext
        
        if let topVC = UIApplication.sharedApplication().keyWindow?.rootViewController{
            topVC.presentViewController(commentViewController, animated: true, completion: nil)
        }
        
    }
    
    
    func presentAttachmentController(attachmentViewController : UIViewController){
        attachments = nil
        let vc = BSImagePickerViewController()
        vc.takePhotos = true
        vc.maxNumberOfSelections = 6
        
        if let topVC = getTopViewController(){
            topVC.bs_presentImagePickerController(vc, animated: true,
                                                  select: { (asset: PHAsset) -> Void in
                                                    print("Selected: \(asset)")
                }, deselect: { (asset: PHAsset) -> Void in
                    print("Deselected: \(asset)")
                }, cancel: { (assets: [PHAsset]) -> Void in
                    print("Cancel: \(assets)")
                }, finish: { (assets: [PHAsset]) -> Void in
                    print("Finish: \(assets)")
                }, completion: nil)

        }
    }
    
    func presentShareViewController(actionProperty : ActionProperty){
        let shareViewController = UIStoryboard.AutoResizing().instantiateViewControllerWithIdentifier(String(ShareController)) as! ShareController
        
        shareViewController.actionProperty = actionProperty
        
        let nc = UINavigationController(rootViewController: shareViewController)
        
        if let topVC = getTopViewController(){
            topVC.presentViewController(nc, animated: true, completion: nil)
        }
    }
    
    func presentCommentController(actionProperty : ActionProperty){
        let commentViewController = TextInputBarController()
        commentViewController.actionProperty = actionProperty
        commentViewController.modalPresentationStyle = .OverCurrentContext
        
        if let topVC = getTopViewController(){
            topVC.presentViewController(commentViewController, animated: true, completion: {})
        }
    }
    
    func dismissPresentedController(){
//        delegate?.dismissPresentedController()
        if let topVC = getTopViewController(){
            topVC.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    func createTaskFeed() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let createTask = UIAlertAction(title: NSLocalizedString("createTaskAlertControllerTitle", comment: ""), style: UIAlertActionStyle.Default, handler: {
            (action) -> Void in
            
            let createTaskController = UIStoryboard.othersStoryboard().instantiateViewControllerWithIdentifier(String(CreateFeedTaskController)) as! CreateFeedTaskController
            let nc = UINavigationController.init(rootViewController: createTaskController)
            createTaskController.type = CardType.TaskType
            createTaskController.cardViewController = self.cardViewController
            
            if let topVC = UIApplication.sharedApplication().keyWindow?.rootViewController{
                topVC.presentViewController(nc, animated: true, completion: nil)
            }
        })
        
        let createFeed = UIAlertAction(title: NSLocalizedString("createfeedAlertControllerTitle", comment: ""), style: UIAlertActionStyle.Default, handler: {
            (action) -> Void in
            
            let createTaskController = UIStoryboard.othersStoryboard().instantiateViewControllerWithIdentifier(String(CreateFeedTaskController)) as! CreateFeedTaskController
            let nc = UINavigationController.init(rootViewController: createTaskController)
            createTaskController.type = CardType.FeedType
            createTaskController.cardViewController = self.cardViewController
            
            if let topVC = UIApplication.sharedApplication().keyWindow?.rootViewController{
                topVC.presentViewController(nc, animated: true, completion: nil)
            }
        })
        
        let cancel = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .Cancel, handler: {(action) -> Void in
        })
        
        alertController.addAction(createTask)
        alertController.addAction(createFeed)
        alertController.addAction(cancel)
        
        if let topVC = UIApplication.sharedApplication().keyWindow?.rootViewController{
            topVC.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func notificationButtonPressed(){
        let notificationController = UIStoryboard.notificationStoryboard().instantiateViewControllerWithIdentifier(String(NotificationController)) as! NotificationController
        let nc = UINavigationController.init(rootViewController: notificationController)
        
        if let topVC = UIApplication.sharedApplication().keyWindow?.rootViewController{
            topVC.presentViewController(nc, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
    
    
    //Mark:- Offline Handling
    func syncOfflineActions(){
        let offlineActionPropArray = Parser.GetOfflineActions(nil)
        
        for offlineActionProp in offlineActionPropArray{
            
                let actionProp = NSKeyedUnarchiver.unarchiveObjectWithData(offlineActionProp.actionProperty!) as! ActionProperty
                
                switch actionProp.actionType ?? CardAction.UnknownAction{
                case .Comment:
                    comment(actionProp)
                    Parser.deleteOfflineAction(offlineActionProp)
                case .Approve:
                    approveOfflineActionSilently(actionProp)
                    Parser.deleteOfflineAction(offlineActionProp)

                case .Reject:
                    RejectWithReason(actionProp)
                    Parser.deleteOfflineAction(offlineActionProp)

                default:
                    print("Unknown Action")
                    Parser.deleteOfflineAction(offlineActionProp)

                }
            
        }

    }
    
    
    func downloadBadgeCount() {
        Alamofire.request(Router.BadgeCount()).responseJSON { response in
            
            switch response.result{
            case .Success(let JSON):
                print("Success with JSON")
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else {
                    print("Error Occured: JSON Without success")
                    
                    return
                }
                
                
                if let dataValue = jsonData.valueForKey("data") as? Int {
                    UserDefaults.setBadgeCount(dataValue)
                }
                else {
                    UserDefaults.setBadgeCount(nil)
                }
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Session Expired"
                    print(message)
                }
            }
        }
    }
    
}