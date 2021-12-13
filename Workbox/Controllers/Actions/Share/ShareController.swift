//
//  ShareController.swift
//  Workbox
//
//  Created by Pavan Gopal on 03/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import VENTokenField
import ALTextInputBar
import Alamofire
import BRYXBanner

class ShareController: UIViewController {
    
    //MARK:- Variables and Outlets
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tokenField: VENTokenField!
    
    var doneButton : UIBarButtonItem!
    var actionProperty : ActionProperty!
    var requestSearch: Alamofire.Request?
    var alertBoxText : String?
    //    let cardTableViewCellHeight:CGFloat = 141
    let defaultTableViewCellHeight:CGFloat = 44
    let sectionHeight:CGFloat = 30
    var usersPresent : Bool?
    var groupsPresent = false
    //    let textInputBar = ALTextInputBar()
    var users = [User]()
    var groups = [Group]()
    var filteredUsers = [User]()
    var filteredGroups = [Group]()
    var selectedItems = NSMutableArray()
    var workItemDetail : Workitem!

    var workID: String?
    var searchState:Bool = false
    
    //MARK:- View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        //        configureInputBar()
        
        tableView.registerNibWithStrings(String(TSApprovalCell), String(UserMessage01Card), String(NewsFeed01Card), String(GenericFeed01Card), String(NewJoinee01Card), String(ListView01Card), String(LeaveApproval01Card), String(GenericTask01Card))
        
        //        navigationItem.rightBarButtonItem = nil
        self.tokenField.delegate = self;
        self.tokenField.dataSource = self;
        self.tokenField.placeholderText = "Start typing..."
        self.tokenField.toLabelText = "To:"
        self.tokenField.setColorScheme( UIColor.navBarColor())
        
        updateFramesWithAnimationDuration(0)
        //        getWorkitemDetail()
        tableView.estimatedRowHeight = 33
        tableView.rowHeight = UITableViewAutomaticDimension
        
        guard let unwrappedWorkitemId = actionProperty.workitemId else{
            print("workitem id is nill")
            return
        }
        
       workItemDetail =   Parser.fetchWorkitem(forId: unwrappedWorkitemId)
    }


    func setupNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.navBarColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.doneButton = UIBarButtonItem(title: "Done", style:UIBarButtonItemStyle.Plain, target: self, action: #selector(ShareController.doneButtonPressed(_:)))
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.rightBarButtonItem?.enabled = false
    }
    
    func updateFramesWithAnimationDuration(duration: NSTimeInterval)
    {
        var tvFrame:CGRect = tableView.frame;
        tvFrame.origin.y = CGRectGetMaxY(tokenField.frame);
        tvFrame.size.height = self.view.frame.size.height - tvFrame.origin.y;
        UIView.animateWithDuration(duration, animations:{
            self.tableView.frame = tvFrame
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

//MARK:- Extension

extension ShareController: VENTokenFieldDataSource,VENTokenFieldDelegate,UITableViewDataSource,UITableViewDelegate {
    
    //MARK:- tokenField delegate
    
    func tokenField(tokenField: VENTokenField, didChangeText text: String?) {
        if Helper.lengthOfStringWithoutSpace(text) == 0{
            navigationItem.rightBarButtonItem?.enabled = false
            filteredGroups.removeAll()
            filteredUsers.removeAll()
            searchState = false
            tableView.reloadData()
        }
        else{
            if tokenField.isFirstResponder() {
                searchState = true
                navigationItem.rightBarButtonItem?.enabled = true
            }
        }
        downloadAndDisplaySearchedUser(text!)
        alertBoxText = text
    }
    
 
    func downloadAndDisplaySearchedUser(searchString : String) {
        requestSearch?.cancel()
        requestSearch =  Alamofire.request(Router.SearchUser(text: searchString.lowercaseString)).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{

                    print("Error Occured: JSON Without success")
                    return
                }
                
                guard let jsonDataDictionaryArray = jsonData.valueForKey("data") as? [NSDictionary] else{
                    print("Cannot cast JSON to Dictionary: \(JSON)")
                    return
                }
                
                let usersData = jsonDataDictionaryArray.flatMap{ User(dictionaryData: $0)}
                
                self.filteredUsers.removeAll()
                self.filteredUsers.appendContentsOf(usersData)
                self.tableView.reloadData()
                
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                
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

    func tokenField(tokenField: VENTokenField, didDeleteTokenAtIndex index: UInt) {
        selectedItems.removeObjectAtIndex(Int(index))
        tokenField.reloadData()
        tableView.reloadData()
        updateFramesWithAnimationDuration(0.3)
        if selectedItems.count == 0 {
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    
    // MARK:- token filed datasource
    func tokenField(tokenField: VENTokenField, titleForTokenAtIndex index: UInt) -> String {
        
        if selectedItems[Int(index)] is Group {
            let group = selectedItems[Int(index)] as! Group
            //            selectedGroups.addObject(group)
            return group.name!
        }
        else {
            let user = selectedItems[Int(index)] as! User
            //            selectedUsers.addObject(user)
            return user.displayName!
        }
    }
    
    func numberOfTokensInTokenField(tokenField: VENTokenField) -> UInt {
        
        return UInt(selectedItems.count)
        
    }
    
    
    // MARK:- TableView DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if searchState == true {
            if filteredUsers.count > 0 {
                if filteredGroups.count > 0 {
                    return 2
                }
                else {
                    return 1
                }
            }
            else if filteredGroups.count > 0{
                return 1
            }
            else {
                return 0
            }
        }
        else {return 1}
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if searchState == true {
            if section == 0 {
                if filteredUsers.count > 0{
                    
                    return filteredUsers.count
                }
                else if filteredGroups.count > 0 {
                    
                    return filteredGroups.count
                }
            }
            return filteredGroups.count
        }
        else {return 1}
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //        var cardCell  = ShareCardCell()
        
        if searchState == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ShareCell
            if indexPath.section == 0 {
                if filteredUsers.count > 0{
                    cell.updateCell(indexPath,filteredUserNames:filteredUsers,selectedItems:selectedItems)
                    
                    return cell
                }
                else if filteredGroups.count > 0{
                    
                    cell.updateCell(indexPath,filteredGroupNames:filteredGroups,selectedItems:selectedItems)
                    
                    return cell
                }
            }
            //            else{
            cell.updateCell(indexPath,filteredGroupNames:filteredGroups,selectedItems:selectedItems)
            return cell
            //            }
        }
        else{
     
            let workitemDict = Parser.dictionaryFromData(workItemDetail.workitemData)
            let cardType =  CardType(value: workItemDetail.cardType)
            let cardSubType =  CardSubtype(value: workItemDetail.cardSubtype)

            
            switch(cardType){
            case .FeedType:
                switch(cardSubType){
                case .NewJoineeType:
                    let cardElement = NewJoinee(JSON: workitemDict)
                    cardElement.actionBarEnabled = false
                    cardElement.latestActivityBarEnabled = false
                    cardElement.commentBarEnabled = false
                    
                    switch(cardElement.defaultCardTemplate){
                    case .NewJoinee01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(NewJoinee01Card), forIndexPath: indexPath) as! NewJoinee01Card
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }
                    
                case .UserMessageType:
                    let cardElement = GenericFeed(JSON: workitemDict)
                    cardElement.actionBarEnabled = false
                    cardElement.latestActivityBarEnabled = false
                    cardElement.commentBarEnabled = false


                    switch(cardElement.defaultCardTemplate){
                    case .UserMessage01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(UserMessage01Card), forIndexPath: indexPath) as! UserMessage01Card
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }
                case .NewsFeedType:
                    let cardElement = NewsFeed(JSON: workitemDict)
                    cardElement.actionBarEnabled = false
                    cardElement.latestActivityBarEnabled = false
                    cardElement.commentBarEnabled = false


                    switch(cardElement.defaultCardTemplate){
                    case .NewsFeed01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(NewsFeed01Card), forIndexPath: indexPath) as! NewsFeed01Card
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }
                default:
                    let cardElement = GenericFeed(JSON: workitemDict)
                    cardElement.actionBarEnabled = false
                    cardElement.latestActivityBarEnabled = false
                    cardElement.commentBarEnabled = false


                    switch(cardElement.defaultCardTemplate){
                    case .UserMessage01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(UserMessage01Card), forIndexPath: indexPath) as! UserMessage01Card
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }
                }
            case .TaskType:
                switch(cardSubType){
                case .ManualTaskType:
                    let cardElement = GenericTask(JSON: workitemDict)
                    cardElement.actionBarEnabled = false
                    cardElement.latestActivityBarEnabled = false
                    cardElement.commentBarEnabled = false


                    switch(cardElement.defaultCardTemplate){
                    case .GenericTask01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(GenericTask01Card), forIndexPath: indexPath) as! GenericTask01Card
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }
                default:
                    let cardElement = GenericTask(JSON: workitemDict)
                    cardElement.actionBarEnabled = false
                    cardElement.latestActivityBarEnabled = false
                    cardElement.commentBarEnabled = false


                    switch(cardElement.defaultCardTemplate){
                    case .GenericTask01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(GenericTask01Card), forIndexPath: indexPath) as! GenericTask01Card
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }
                }
            case .TimesheetType:
                switch(cardSubType){
                case .Approve:
                    let cardElement = Approval(JSON: workitemDict)
                    cardElement.actionBarEnabled = false


                    switch(cardElement.defaultCardTemplate){
                    case .Approval01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(TSApprovalCell), forIndexPath: indexPath) as! TSApprovalCell
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }
                default:
                    print(cardType)
                }
            case .LeaveType:
                switch(cardSubType){
                case .Approve:
                    let cardElement = LeaveApproval(JSON: workitemDict)
                    cardElement.actionBarEnabled = false


                    switch(cardElement.defaultCardTemplate){
                    case .LeaveApproval01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(LeaveApproval01Card), forIndexPath: indexPath) as! LeaveApproval01Card
                        
                        cell.updateCellWithData(cardElement, sentBy: self)
                        
                        return cell
                    }
                default:
                    print(cardType)
                }
            default:
                let cardElement = GenericFeed(JSON: workitemDict)
                cardElement.actionBarEnabled = false
                cardElement.latestActivityBarEnabled = false
                cardElement.commentBarEnabled = false


                switch(cardElement.defaultCardTemplate){
                case .UserMessage01Card:
                    let cell = tableView.dequeueReusableCellWithIdentifier(String(UserMessage01Card), forIndexPath: indexPath) as! UserMessage01Card
                    cell.updateCellWithData(cardElement, sentBy: self)
                    return cell
                    
                }
            }
            let cardElement = GenericFeed(JSON: workitemDict)
            cardElement.actionBarEnabled = false
            cardElement.latestActivityBarEnabled = false
            cardElement.commentBarEnabled = false


            let cell = tableView.dequeueReusableCellWithIdentifier(String(UserMessage01Card), forIndexPath: indexPath) as! UserMessage01Card
            cell.updateCellWithData(cardElement, sentBy: self)
            return cell

        }
        
    }
    
    
    
    //    MARK: - TABLEVIEW DELEGATE
    //
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        if searchState == true {
    //            return defaultTableViewCellHeight
    //
    //        }
    //        return defaultTableViewCellHeight
    //    }
    //
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if filteredUsers.count > 0 {
                if selectedItems.count > 0{
                    var isPresent = false
                    let selectedId = filteredUsers[indexPath.row].id!
                    for i in 0  ..< selectedItems.count  {
                        if  let user = selectedItems[i] as? User {
                            if user.id == selectedId {
                                isPresent = true
                                selectedItems.removeObjectAtIndex(i)
                                break
                            }
                        }
                    }
                    if isPresent == false{
                        
                        self.selectedItems.addObject(filteredUsers[indexPath.row])
                    }
                    
                }
                else{
                    self.selectedItems.addObject(filteredUsers[indexPath.row])
                    
                }
            }
                
                
            else if filteredGroups.count > 0{
                if selectedItems.count > 0{
                    var isPresent = false
                    let selectedId = filteredGroups[indexPath.row].groupId!
                    for object in selectedItems {
                        if object is Group {
                            let user = object as! Group
                            if user.groupId == selectedId {
                                isPresent = true
                                selectedItems.removeObjectAtIndex(selectedItems.indexOfObject(filteredGroups[indexPath.row]))
                                
                            }
                        }
                    }
                    if isPresent == false{
                        
                        self.selectedItems.addObject(filteredGroups[indexPath.row])
                        
                    }
                }
                else{
                    self.selectedItems.addObject(filteredGroups[indexPath.row])
                    
                }
            }
        }
            
        else{
            // groups same logic
            
            if selectedItems.count > 0{
                var isPresent = false
                let selectedId = filteredGroups[indexPath.row].groupId!
                for object in selectedItems {
                    if object is Group {
                        let user = object as! Group
                        if user.groupId == selectedId {
                            isPresent = true
                            selectedItems.removeObjectAtIndex(selectedItems.indexOfObject(filteredGroups[indexPath.row]))
                            
                        }
                    }
                }
                if isPresent == false{
                    self.selectedItems.addObject(filteredGroups[indexPath.row])
                }
            }
            else{
                self.selectedItems.addObject(filteredGroups[indexPath.row])
            }
        }
        
        tokenField.resignFirstResponder()
        tokenField.reloadData()
        
        updateFramesWithAnimationDuration(0.3)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation:.None)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchState == true {
            return sectionHeight
        }
        else {return 0}
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if filteredUsers.count > 0 {
                return "PEOPLE"
            }
            else if filteredGroups.count > 0 {
                return "GROUPS"
            }
        }
        else {
            return "GROUPS"
        }
        return ""
    }
    
    //MARK:- Action Methods
    
    func doneButtonPressed(sender: AnyObject) {
        
        if filteredUsers.count == 0 {
            if let unwrappedAlertBoxText = alertBoxText{
                let alertController = UIAlertController(title: "\"\(unwrappedAlertBoxText)\" Not Found", message: "Please Enter the valid UserName or Group Name", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style:.Default ,
                                             handler:{ (action) -> Void in
                                                
                })
                alertController.addAction(okAction)
                
                presentViewController(alertController, animated: true, completion: nil)
            }
            else{
                print("cancel button should be disabled ## FIX IT")
            }
            //            tokenField.reloadData()
        }
            
        else{
            if selectedItems.count == 0 {
                let alertController = UIAlertController(title:"", message: "Please select atleast one recipient", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style:.Default ,
                                             handler:{ (action) -> Void in
                                                
                })
                alertController.addAction(okAction)
                
                presentViewController(alertController, animated: true, completion: nil)
            }
            else{
                if Helper.lengthOfStringWithoutSpace(alertBoxText) > 0{
                    
                        if actionProperty?.actionType == CardAction.Share{
                            shareOnWorkitem(selectedItems)
                        }
                        else if actionProperty?.actionType == CardAction.DelegateTask{
                            delegateWorkitem(selectedItems)
                        }
                    searchState = false
                    
                }
            }
            
        }
    }
    

    

    
    func shareOnWorkitem(selectedItemsArray: NSMutableArray) {
        
        var shareDictionary = Dictionary<String,AnyObject>()
        shareDictionary["users"] = selectedItemsArray.flatMap{ String(($0 as? User)?.email ?? "") }
        guard let unwrappedWorkitemId = actionProperty?.workitemId else{
            print("Error")
            return
        }
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: false)

        Alamofire.request(Router.ShareWorkitem(id: unwrappedWorkitemId, shareDict: shareDictionary)).responseJSON { response in
            LoadingController.instance.hideLoadingView()
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
                
//                let alertController = UIAlertController(title:"", message: "Please select atleast one recipient", preferredStyle: .Alert)
//                let okAction = UIAlertAction(title: "OK", style:.Default ,
//                    handler:{ (action) -> Void in
//                        
//                })
//                alertController.addAction(okAction)
//                
//                self.presentViewController(alertController, animated: true, completion: nil)
                
                let banner = Banner(title: "Notification", subtitle: "Shared successfully", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                
                print("Work Item Updated")
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                
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
        if let unwrappedCardViewController = actionProperty?.senderViewController as? CardViewController{
            unwrappedCardViewController.clearAndReloadTableviewData()
        }
        
    }
    
    
    func delegateWorkitem(selectedItemsArray: NSMutableArray) {
        
        var userEmailArray = [String]()
        userEmailArray = selectedItemsArray.flatMap{ String(($0 as? User)?.email ?? "") }
        guard let unwrappedWorkitemId = actionProperty?.workitemId else{
            print("Error")
            return
        }
        let alertController = UIAlertController(title: "Delegate Task", message: "Do you want to delegate this task?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            print("Cancelled")
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Delegate", style: .Default) { (action) in
            
            LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: false)

            Alamofire.request(Router.DelegateTask(workitemId: unwrappedWorkitemId, userEmailArray: userEmailArray)).responseJSON { response in
                LoadingController.instance.hideLoadingView()
                switch response.result {
                case .Success(let JSON):
                    guard let jsonData = JSON as? NSDictionary else{
                        print("Incorrect JSON from server : \(JSON)")
                        return
                    }
                    guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                        let message = jsonData[kServerKeyMessage]?.lowercaseString
                        
                        let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        
                        if let senderController =   getTopViewController(){
                            senderController.presentViewController(alertController, animated: true, completion: nil)
                        }
                        print("Error Occured: JSON Without success" + String(JSON))
                        return
                    }
                    let banner = Banner(title: "Notification", subtitle: "Task delegated successfully", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                    print("Work Item Updated")
                    self.dismissViewControllerAnimated(true, completion: nil)

                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    
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
            
//            if let unwrappedCardViewController = self.actionProperty?.senderViewController as? CardViewController{
//                unwrappedCardViewController.clearAndReloadTableviewData()
//            }

        }
        alertController.addAction(OKAction)
        if let topVC = getTopViewController(){
            topVC.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    
    
}
