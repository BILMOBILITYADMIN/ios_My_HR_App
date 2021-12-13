//
//  DetailViewController.swift
//  Workbox
//
//  Created by Chetan Anand on 27/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity
import ALTextInputBar
import BRYXBanner


protocol removeWorkItemForCollaboratorDelegate {
    func removeWorkItem()
}
class DetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var detailHeaderData : Workitem?
    var workitemId : String?
    var request: Alamofire.Request?
//    var isLoading = false
    var refreshControl = UIRefreshControl()
    var comments = [Comment]()
    var collaboratorMenuButton = UIBarButtonItem()
    var indexPath : NSIndexPath?
    let textInputView = CWTextInputView()
    var delegate : removeWorkItemForCollaboratorDelegate?
    var isBMPFilter : Bool?
    var bpmTaskDetailData : BPMTaskDetail?
    

    //    var senderViewController : CardViewController?
    //    var indexOfWorkitemInCards : Int?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 33
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.userInteractionEnabled = true
        tableView.keyboardDismissMode = .OnDrag
        
        self.registerForKeyboardNotifications()
    tableView.registerNibWithStrings(String(DetailCommentCell),String(UserMessageDetail) ,String(GenericTaskDetail), String(NewsFeedDetail), String(GenericFeedDetail), String(NewJoineeDetail),String(BPMApprovalDetailCell), String(LeaveDetail))
        
        if let unwrappedWorkitemId = detailHeaderData?.workitemId{
            workitemId = unwrappedWorkitemId
        }
 
        
        self.tabBarController?.tabBar.hidden = true
        
        let actionProp = ActionProperty()
        actionProp.actionType = CardAction.Comment
        actionProp.workitemId = workitemId
        actionProp.senderViewController = self
        textInputView.addAction(actionProp, placeholderText: "Write your comment...", leftViewEnabled: true, textBarEnabled: true)
        if isBMPFilter == false {
            downloadWorkItemDetail()
        }
        else{
            
            downloadBPMTaskDetail()
        }
   
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
//        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(DetailViewController.dismissKeyboard))
//                view.addGestureRecognizer(swipe)

        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        tableView.reloadData()
        createCollaborator()
        
        self.scrollToLastRow()
        
        updateAndReloadTableview()


    }
    
    func handleRefresh(){
        if isBMPFilter == false {
            downloadWorkItemDetail()
            
        }
        else{
            
            downloadBPMTaskDetail()
        }
    }
    
    
    
    func scrollToLastRow() {
        if comments.count > 0{
        let indexPath = NSIndexPath(forRow: comments.count - 1 , inSection: 1)
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
        }
    }
    
    func updateAndReloadTableview(){
        guard let unwrappedWorkitemData = detailHeaderData?.workitemData else{
            return
        }
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedWorkitemData) as! NSDictionary

        guard let unwrappedComments = Parser.commentsFromAnyObject(dataDictionary.valueForKey("comments")) else{
            return
        }
        self.comments = unwrappedComments

        tableView.reloadData()
//        scrollToLastRow()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
   
        detailHeaderData =  Parser.fetchWorkitem(forId: workitemId!)
 
    }
    
    // This is how we attach the input bar to the keyboard
    override var inputAccessoryView: UIView? {
        get {
            return textInputView
        }
    }
    
    // Another ingredient in the magic sauce
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func dismissKeyboard() {
        
        textInputView.textView.resignFirstResponder()
        
    }
    
    func createCollaborator(){
        
      collaboratorMenuButton = UIBarButtonItem.init(image: AssetImage.subscriber.image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DetailViewController.collaboratorButtonPressed(_:)))
        navigationItem.rightBarButtonItem = collaboratorMenuButton
        
        
    }
    
    func collaboratorButtonPressed(sender: UIBarButtonItem){
    
        guard let unwrappedWorkitem = detailHeaderData else{
            print("detailHeaderData unwrapping failed")
            return
        }
        
        guard let unwrappedWorkitemData = unwrappedWorkitem.workitemData else{
            print("unwrappedWorkitem.workitemData unwrapping failed")
            return
        }
        
        
        
        
        let workitemDict = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedWorkitemData) as! NSDictionary
        let collaborator = Collaborators()
        
        if let unwrappedData = workitemDict.valueForKey("subscribers") as? NSDictionary {
            collaborator.collaboratorsList =  [User(dictionaryData: unwrappedData)!]
        }
        else if let unwrappedData = workitemDict.valueForKey("subscribers") as? [NSDictionary] {
            
            collaborator.collaboratorsList =  unwrappedData.flatMap { User(dictionaryData: $0) }
        }
        else{
            print("error")
        }
        if let workItemId = workitemDict.valueForKey("_id") as? String{
            collaborator.workItemId = workItemId
            
        }
        if let unwrappedcollaboratorCreatedBy = workitemDict.valueForKey("createdBy") as? NSDictionary{
            collaborator.createdBy = User(dictionaryData: unwrappedcollaboratorCreatedBy)
 
        }
        
        let collaboratorVC = UIStoryboard(name: "Collaborator", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier(String(CollaboratorController)) as! CollaboratorController
        
        collaboratorVC.collaboratorObject = collaborator
        collaboratorVC.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        let nc = UINavigationController.init(rootViewController: collaboratorVC)

        self.presentViewController(nc,  animated: true, completion: nil)
        collaboratorVC.deleteCollaboratorWorkItemCompletionHandler = {() -> Void in
            // here
//            let vc = self.navigationController?.viewControllers[0] as! CardViewController
//            vc.deleteWorkitem(vc.cardData[self.indexPath!.row].workitemId)
//            vc.cardData.removeAtIndex(self.indexPath!.row)
//            
//            vc.tableView.beginUpdates()
//            vc.tableView.deleteRowsAtIndexPaths([self.indexPath!], withRowAnimation: .Automatic)
//            vc.tableView.endUpdates()
            self.delegate?.removeWorkItem()
            self.navigationController?.popViewControllerAnimated(false)
        }
        
    }
}

// MARK: - Table View Delegate And Datasource Extension
extension DetailViewController: UITableViewDelegate, UITableViewDataSource,BPMApprovalDetailCellDelegate {
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0){
            return 0
        }else{
            return 32
        }
    }
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.whiteColor()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }
        else{
            return comments.count
        }
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        
//        return "Comments"
//        
//    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44))
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: headerView.frame.size.width, height: 44))
        label.text = "Comments"
        label.font = UIFont.boldSystemFontOfSize(14)
        label.textColor = UIColor.darkGrayColor()
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == 0 && indexPath.row == 0){
            
            guard let unwrappedWorkitem = detailHeaderData else{
                return UITableViewCell()
            }
            
            guard let unwrappedWorkitemData = unwrappedWorkitem.workitemData else{
                return UITableViewCell()
            }
            
            let workitemDict = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedWorkitemData) as! NSDictionary
            
            let cardType =  CardType(value: unwrappedWorkitem.cardType)
            let cardSubType =  CardSubtype(value: unwrappedWorkitem.cardSubtype)
            
            
            
            switch(cardType){
            case .FeedType:
                switch(cardSubType){
                case .NewJoineeType:
                    let cardElement = NewJoinee(JSON: workitemDict)
                    let cell = tableView.dequeueReusableCellWithIdentifier(String(NewJoineeDetail), forIndexPath: indexPath) as! NewJoineeDetail
                    cell.updateCellWithData(cardElement, sentBy: self)
                    return cell
                    
                case .UserMessageType:
                    let cardElement = GenericFeed(JSON: workitemDict)
                    let cell = tableView.dequeueReusableCellWithIdentifier(String(UserMessageDetail), forIndexPath: indexPath) as! UserMessageDetail
                    cell.updateCellWithData(cardElement, sentBy: self)
                    return cell
                case .NewsFeedType:
                    let cardElement = NewsFeed(JSON: workitemDict)
                    let cell = tableView.dequeueReusableCellWithIdentifier(String(NewsFeedDetail), forIndexPath: indexPath) as! NewsFeedDetail
                    cell.updateCellWithData(cardElement, sentBy: self)
                    return cell
                default:
                    let cardElement = GenericFeed(JSON: workitemDict)
                    let cell = tableView.dequeueReusableCellWithIdentifier(String(UserMessageDetail), forIndexPath: indexPath) as! UserMessageDetail
                    cell.updateCellWithData(cardElement, sentBy: self)
                    return cell
                }
            case .TaskType:
                switch(cardSubType){
                case .ManualTaskType:
                    let cardElement = GenericTask(JSON: workitemDict)
                    let cell = tableView.dequeueReusableCellWithIdentifier(String(GenericTaskDetail), forIndexPath: indexPath) as! GenericTaskDetail
                    cell.updateCellWithData(cardElement, sentBy: self)
                    return cell
                case .BPMTask:
                    let cardElement = BPMApproval(JSON:workitemDict)
                    
                    let cell = tableView.dequeueReusableCellWithIdentifier(String(BPMApprovalDetailCell), forIndexPath: indexPath) as! BPMApprovalDetailCell
                    cell.delegate = self
                    cell.updateCellWithData(cardElement,sentBy: self,bpmTaskDetail: bpmTaskDetailData)
                    
                    return cell
                    
                default:
                    let cardElement = GenericTask(JSON: workitemDict)
                    let cell = tableView.dequeueReusableCellWithIdentifier(String(GenericTaskDetail), forIndexPath: indexPath) as! GenericTaskDetail
                    cell.updateCellWithData(cardElement, sentBy: self)
                    return cell
                }
                
            case .LeaveType:
                switch(cardSubType){
                case .Approve:
                    let cardElement = LeaveApproval(JSON: workitemDict)
                    let cell = tableView.dequeueReusableCellWithIdentifier(String(LeaveDetail), forIndexPath: indexPath) as! LeaveDetail
                    cell.updateCellWithData(cardElement, sentBy: self)
                    return cell
                default:
                    let cardElement = GenericTask(JSON: workitemDict)
                    let cell = tableView.dequeueReusableCellWithIdentifier(String(GenericTaskDetail), forIndexPath: indexPath) as! GenericTaskDetail
                    cell.updateCellWithData(cardElement, sentBy: self)
                    return cell
                    
                }
            default:
                switch(cardSubType){
                default:
                    let cardElement = GenericFeed(JSON: workitemDict)
                    let cell = tableView.dequeueReusableCellWithIdentifier(String(UserMessageDetail), forIndexPath: indexPath) as! UserMessageDetail
                    cell.updateCellWithData(cardElement, sentBy: self)
                    return cell
                }
            }

        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier(String(DetailCommentCell), forIndexPath: indexPath) as! DetailCommentCell
            cell.updateCellWithData(comments[indexPath.row])
            return cell
        }
    
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        dismissKeyboard()
        
        if indexPath.section == 1 {
            var alertController = UIAlertController()
            
            if (comments[indexPath.row].commentedBy?.displayName != UserDefaults.loggedInUser()?.displayName){
               let msgText = "Only '\(comments[indexPath.row].commentedBy?.displayName ?? "")' can delete this comment"
                
                alertController = UIAlertController(title: "No actions available", message: msgText , preferredStyle: .ActionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                    print(" actions Cancelled")
                }
                
                alertController.addAction(cancelAction)
            }
            else{
                alertController = UIAlertController(title: "More Actions", message: nil , preferredStyle: .ActionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                    print(" actions Cancelled")
                }
                
                let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
                    print("Delete")
                    self.deleteComment(self.comments[indexPath.row].id, indexPath: indexPath)
                    
                    
                }
                alertController.addAction(cancelAction)
                alertController.addAction(deleteAction)
            }
            
            
            if let topVC = getTopViewController(){
                topVC.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func showBPMDetailDelegate(bpmTaskDetail:BPMTaskDetail?){
        let bpmDetailsController = UIStoryboard.POPRStoryboard().instantiateViewControllerWithIdentifier(String(BPMDetailController)) as! BPMDetailController
        bpmDetailsController.bpmTaskDetailObject = bpmTaskDetail
        self.navigationController?.pushViewController(bpmDetailsController, animated: true)
        
    }
    
    
}


//MARK: - Network Operations
extension DetailViewController{
    
    
    func downloadWorkItemDetail() {
//        if(!isLoading){
            print(#function)
//            isLoading = true
            guard let unwrappedWorkitemId = workitemId else{
                return
            }
            
            if(refreshControl.refreshing == false){
//                EZLoadingActivity.show("Loading", disableUI: true)
                LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)

            }
            
            self.request =  Alamofire.request(Router.GetWorkitemDetail(id: unwrappedWorkitemId)).responseJSON { response in
//                EZLoadingActivity.hide()
                LoadingController.instance.hideLoadingView()

                self.refreshControl.endRefreshing()
                
                //                var numberOfObjects = 0
                switch response.result {
                case .Success(let JSON):
                    print("Success with JSON")
                    
                    guard let jsonData = JSON as? NSDictionary else{
                        print("Incorrect JSON from server : \(JSON)")
                        return
                    }
                    guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                        var message = jsonData[kServerKeyMessage]?.lowercaseString
                        
                        let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        
                        if let senderController =   getTopViewController(){
                            senderController.presentViewController(alertController, animated: true, completion: nil)
                        }
                        print("Error Occured: JSON Without success")
                        return
                    }
                    
                    guard let jsonDataDictionary = jsonData.valueForKey("data") as? NSDictionary else{
                        print("Cannot cast JSON to Dictionary: \(JSON)")
                        return
                    }
                    
                    self.comments.removeAll()
                    
                    if let workitem = Parser.workitemForDictionary(jsonDataDictionary){
                        self.detailHeaderData =  workitem
                    }
                    
                    if let unwrappedComments = Parser.commentsFromAnyObject(jsonDataDictionary.valueForKey("comments")){
                        
                        self.comments = unwrappedComments
                        
                    }
                   
                    
                    if self.refreshControl.refreshing
                    {
                        self.refreshControl.endRefreshing()
                    }
                    else {
                        
                    }
//                    EZLoadingActivity.hide()
                    LoadingController.instance.hideLoadingView()

                    self.tableView.reloadData()
//                    self.scrollToLastRow()

                    
                    EZLoadingActivity.hide()
//                    self.isLoading = false
                    
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
//                    self.isLoading = false
                    
                    var message = error.localizedDescription
                    if error.code == 403 {
                        message = "Session Expired"
                    }
                    let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            
            
        
        
    }
    
    
    func deleteComment(commentId : String?, indexPath : NSIndexPath) {
        guard let unwrappedCommentId = commentId else{
            print("Nil Workitem ID")
            return
        }
        guard let unwrappedWorkitemId = workitemId else{
            return
        }
        
        Alamofire.request(Router.DeleteComment(workitemId: unwrappedWorkitemId, commentId: unwrappedCommentId)).responseJSON { response in
            
            switch response.result {
            case .Success(let JSON):
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    let banner = Banner(title: "Notification", subtitle: "Comment Deletion failed", image: UIImage(named: "Icon"), backgroundColor: ConstantColor.CWRed)
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                    
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    
                    let banner = Banner(title: "Notification", subtitle: "Comment Deletion failed", image: UIImage(named: "Icon"), backgroundColor: ConstantColor.CWRed)
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                    
                    print("Error Occured: JSON Without success  : \(JSON)")
                    return
                }
                
                print("DID DELETE" + String(commentId))
                self.comments.removeAtIndex(indexPath.row)
//                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//                ActionController.instance.updateCoredataWorkitem(self.workitemId!, senderViewController: nil)
//                self.tableView.endUpdates()

                
                
            case .Failure(let error):
                var message = error.localizedDescription
                
                let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                
                if let senderController =   getTopViewController(){
                    senderController.presentViewController(alertController, animated: true, completion: nil)
                }
                print("Request failed with error: \(error)")
            }
        }
    }
    
    
    
    func downloadBPMTaskDetail(){
       
        guard let unwrappedWorkitem = detailHeaderData else{
            return
        }
        
        guard let unwrappedWorkitemData = unwrappedWorkitem.workitemData else{
            return
        }
        
        let workitemDict = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedWorkitemData) as! NSDictionary
        let cardElement = BPMApproval(JSON:workitemDict)

        guard let upwrappedContentId = cardElement.contentId else{
            return
        }
        
        Alamofire.request(Router.GetBMPTaskDetail(contentId: upwrappedContentId)).responseJSON { response in
            self.refreshControl.endRefreshing()

            switch response.result {
            case .Success(let JSON):
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    var message = jsonData[kServerKeyMessage]?.lowercaseString
                    
                    let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    
                    if let senderController =   getTopViewController(){
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                    print("Error Occured: JSON Without success")
                    return
                }
                
                guard let jsonDataDictionary = jsonData.valueForKey("data") as? NSDictionary else{
                    print("Cannot cast JSON to Dictionary: \(JSON)")
                    return
                }
                let parsedBPMTaskDetailData = Parser.bmpTaskDetail(jsonDataDictionary)
                
                self.bpmTaskDetailData = parsedBPMTaskDetailData
                
                if self.refreshControl.refreshing
                {
                    self.refreshControl.endRefreshing()
                }
                else {
                    
                }
                self.tableView.reloadData()
                
            case .Failure(let error):
                var message = error.localizedDescription
                
                let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                
                if let senderController =   getTopViewController(){
                    senderController.presentViewController(alertController, animated: true, completion: nil)
                }
                print("Request failed with error: \(error)")
            }
        }
    }
    
}


//MARK: - Keyboard Management Methods

extension DetailViewController{
    
    // Call this method somewhere in your view controller setup code.
    func registerForKeyboardNotifications() {
        //        let notificationCenter = NSNotificationCenter.defaultCenter()
        //        notificationCenter.addObserver(self,
        //            selector: "keyboardWillBeShown:",
        //            name: UIKeyboardWillShowNotification,
        //            object: nil)
        //        notificationCenter.addObserver(self,
        //            selector: "keyboardWillBeHidden:",
        //            name: UIKeyboardWillHideNotification,
        //            object: nil)
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    func keyboardWillBeShown(sender: NSNotification) {
        //        let info: NSDictionary = sender.userInfo!
        //        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        //        let keyboardSize: CGSize = value.CGRectValue().size
        //        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        //       tableView.contentInset = contentInsets
        //        tableView.scrollIndicatorInsets = contentInsets
        
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(sender: NSNotification) {
        //        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        //        tableView.contentInset = contentInsets
        //        tableView.scrollIndicatorInsets = contentInsets
    }
}





