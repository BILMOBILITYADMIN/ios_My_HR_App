//
//  SearchUserController.swift
//  Workbox
//
//  Created by Anagha Ajith on 21/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//


import UIKit
import VENTokenField
import ALTextInputBar
import Alamofire


protocol CreateFeedTaskSuccessDelegate {
        func createFeedTaskSuccess()
    
}

class SearchUserController: UIViewController {
    
    //MARK:- Variables and Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tokenField: VENTokenField!
    
    var postButton : UIBarButtonItem!
    var actionProperty : ActionProperty?
    var requestSearch: Alamofire.Request?
    var alertBoxText : String?
    let cardTableViewCellHeight:CGFloat = 141
    let defaultTableViewCellHeight:CGFloat = 44
    let sectionHeight:CGFloat = 30
    var usersPresent : Bool?
    var groupsPresent = false

    
    var filteredUsers = [User]()
    
    var systemGroups = [Group]()
    var customGroups = [Group]()
    
    var selectedItems = NSMutableArray()
    var workItemDetail : AnyObject?
    var workID: String?
    var searchState:Bool = false
    var titleText : String?
    var descriptionText : String?
    var userEmailId = [String]()
    var groupIdArray = [String]()
    var type : CardType?
    var attachedImages : [UIImage]?
    var delegate : CreateFeedTaskSuccessDelegate?
    var cardViewController : CardViewController?
    
    //MARK:- View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        self.tokenField.delegate = self;
        self.tokenField.dataSource = self;
        self.tokenField.placeholderText = "Start typing..."
        self.tokenField.toLabelText = "To:"
        self.tokenField.setColorScheme( UIColor.navBarColor())
        updateFramesWithAnimationDuration(0)
        downloadGroups()
    }
    
    override func viewWillAppear(animated: Bool) {
        createNavBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func createNavBar() {

        self.navigationController?.setupNavigationBar()
        if var creationType = type?.rawValue {
            
            if creationType == "feeds"{
                creationType = String(creationType.characters.dropLast())
            }
            
            navigationController?.navigationBar.topItem?.title = "Create \(creationType.capitalizedString)"
        }
        
        postButton = UIBarButtonItem(title: "Post", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SearchUserController.doneButtonPressed(_:)))
        
        self.navigationItem.rightBarButtonItem = postButton
        
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
    
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)

    }
}

//MARK:- Extension

extension SearchUserController: VENTokenFieldDataSource,VENTokenFieldDelegate,UITableViewDataSource,UITableViewDelegate {
    
    //MARK:- tokenField delegate
    
    func tokenField(tokenField: VENTokenField, didChangeText text: String?) {
        if Helper.lengthOfStringWithoutSpace(text) == 0{
            navigationItem.rightBarButtonItem = postButton

            filteredUsers.removeAll()
            searchState = false
            tableView.reloadData()
        }
        else{
            if tokenField.isFirstResponder() {
                searchState = true
                navigationItem.rightBarButtonItem = postButton
            }
        }
        downloadAndDisplaySearchedUser(text ?? "")
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
                
                var usersData = jsonDataDictionaryArray.flatMap{ User(dictionaryData: $0)}
                
                self.filteredUsers.removeAll()

                
                if self.selectedItems.count > 0{
                    var resultArray = [User]()
                    resultArray.removeAll(keepCapacity: false)
                    
                    for i in 0..<self.selectedItems.count{
                        if let user = self.selectedItems[i] as? User{
                            let userId = user.id
                            
                            resultArray = usersData.filter({$0.id?.lowercaseString.rangeOfString(userId!) != nil})
                            
                            if resultArray.count > 0 {
                                usersData.removeAtIndex(usersData.indexOf({$0.id?.lowercaseString.rangeOfString(userId!) != nil})!)
                            }
                        }
                    }
                }
                
                self.filteredUsers.appendContentsOf(usersData)
                self.tableView.reloadData()
                let indexPath = NSIndexPath(forRow: 0 , inSection: 0)
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
              
            }
        }
        
    }
    
    
    func createTask() {
        
        var attachmentDictArray =  [NSDictionary]()
        
        if let unwrappedAttachedImages = attachedImages {
            for i in 0..<unwrappedAttachedImages.count {
                if let imageData = UIImagePNGRepresentation(unwrappedAttachedImages[i]){
                    let base64String = imageData.base64EncodedStringWithOptions([])
                    attachmentDictArray.append(NSDictionary(object: base64String, forKey: "Attachment\(i)"))
                }
            }
        }
        
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
        
        Alamofire.request(Router.CreateFeedTask(type: CardType.TaskType , system: false, title: titleText!,description: descriptionText!, isPublic: false, cardType: CardType.TaskType, cardSubtype: CardSubtype.ManualTaskType, groups: groupIdArray, users: userEmailId, files: attachmentDictArray)).responseJSON { response in
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
                
                LoadingController.instance.hideLoadingView()
                if let unwrappedCardViewController = self.cardViewController {
                    unwrappedCardViewController.clearAndReloadTableviewData()
                }
                self.dismissViewControllerAnimated(false, completion: nil)
                self.delegate?.createFeedTaskSuccess()
                
                
            case .Failure(let error):
                //                print("Request failed with error: \(error)")
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Session Expired"
                    NSLog(message)
                }
                let alertController = UIAlertController.init(title: kEmptyString, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    func createFeed() {
        
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
        
        var attachmentDictArray =  [NSDictionary]()
        
        if let unwrappedAttachedImages = attachedImages {
            for i in 0..<unwrappedAttachedImages.count {
                if let imageData = UIImagePNGRepresentation(unwrappedAttachedImages[i]){
                    let base64String = imageData.base64EncodedStringWithOptions([])
                    attachmentDictArray.append(NSDictionary(object: base64String, forKey: "Attachment\(i)"))
                }
            }
        }
        
        Alamofire.request(Router.CreateFeedTask(type: CardType.FeedType , system: false, title: titleText!,description: descriptionText!, isPublic: false, cardType: CardType.FeedType, cardSubtype: CardSubtype.UserMessageType, groups: groupIdArray, users: userEmailId, files: attachmentDictArray)).responseJSON { response in
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
                
                LoadingController.instance.hideLoadingView()
                if let unwrappedCardViewController = self.cardViewController {
                    unwrappedCardViewController.clearAndReloadTableviewData()
                }
                self.dismissViewControllerAnimated(true, completion: nil)
                self.delegate?.createFeedTaskSuccess()
                
                
            case .Failure(let error):
//                print("Request failed with error: \(error)")
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Session Expired"
                    NSLog(message)
                }
                let alertController = UIAlertController.init(title: kEmptyString, message: message, preferredStyle: UIAlertControllerStyle.Alert)
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
                return 1
            }
        }
        
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if searchState == true && filteredUsers.count > 0{
                    return filteredUsers.count
        }
        else {
            switch section {
            case 0:
                if systemGroups.count > 0 {
                    return systemGroups.count
                    
                }
            case 1:
                if customGroups.count > 0 {
                return customGroups.count
                }
                
            default:
                return 0
            }
    
        }
        return 0

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let groupCell = tableView.dequeueReusableCellWithIdentifier("GroupCell")! as! CreateFeedTaskGroupCell
        
        if searchState == true {
            let peopleCell = tableView.dequeueReusableCellWithIdentifier("PeopleCell", forIndexPath: indexPath) as! CreateFeedTaskCell
            if indexPath.section == 0 {
                if filteredUsers.count > 0{
                    peopleCell.updateCell(indexPath,filteredUserNames:filteredUsers,selectedItems:selectedItems)
                    
                    return peopleCell
                }

            }
        }
        else{
            if indexPath.section == 0 {
                groupCell.updateCell(systemGroups[indexPath.row],selectedItems:selectedItems)
            }
            else {
                groupCell.updateCell(customGroups[indexPath.row],selectedItems:selectedItems)
            }
        }
        return groupCell
    }
    
    
    
    
    
    //    MARK: - TABLEVIEW DELEGATE
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if searchState == true {
            return defaultTableViewCellHeight
        }
        else {
            return 70
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchState == true{
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

            }

        else{
            // groups checkbox
            if indexPath.section == 0 {
                if selectedItems.count > 0{
                    if systemGroups.count > 0{
                        var isPresent = false
                        let selectedGroupId = systemGroups[indexPath.row].groupId
                        for i in 0 ..< selectedItems.count{
                            if let systemGroup = selectedItems[i] as? Group{
                                if systemGroup.groupId == selectedGroupId{
                                    isPresent = true
                                    selectedItems.removeObjectAtIndex(i)
                                    break
                                    
                                }
                            }
                        }
                        if isPresent == false{
                            self.selectedItems.addObject(systemGroups[indexPath.row])
                        }
                        
                    }
                    
                }
                else{
                    self.selectedItems.addObject(systemGroups[indexPath.row])
                    
                }
            }
            else if indexPath.section == 1{
                if selectedItems.count > 0{
                    
                    if customGroups.count > 0{
                        var isPresent = false
                        let selectedGroupId = customGroups[indexPath.row].groupId
                        for i in 0 ..< selectedItems.count{
                            if let systemGroup = selectedItems[i] as? Group{
                                if systemGroup.groupId == selectedGroupId{
                                    isPresent = true
                                    selectedItems.removeObjectAtIndex(i)
                                    break
                                    
                                }
                            }
                        }
                        if isPresent == false{
                            self.selectedItems.addObject(customGroups[indexPath.row])
                        }
                    }
                }
                else{
                    self.selectedItems.addObject(customGroups[indexPath.row])
                    
                }
            }
        }
        

        filteredUsers.removeAll()
        searchState = false
        tableView.reloadData()
        
        tokenField.resignFirstResponder()
        tokenField.reloadData()
        
        updateFramesWithAnimationDuration(0.3)
        //        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation:.None)
    }
    
    func addGroup(){
        
        
    }
    
    
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchState == true {
            return sectionHeight
        }
        else {return sectionHeight}
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchState == true {
            if filteredUsers.count > 0 {
                return "PEOPLE"
            }
            else {
                return "SYSTEM GROUPS"
            }
        }
        else {
            if section == 0 {
                return "SYSTEM GROUPS"
            }
            else{
                return "CUSTOM GROUPS"
            }
        }
    }
    
    //MARK:- Action Methods
    
    func doneButtonPressed(sender: AnyObject) {
        
        for i in 0..<selectedItems.count {
            if let user = selectedItems[i] as? User {
                userEmailId.append(user.email ?? "")
            }
            if let group = selectedItems[i] as? Group{
                groupIdArray.append(group.groupId ?? "")
            }
        }
        
        if filteredUsers.count == 0 && selectedItems.count == 0 {
            if let text = alertBoxText {
                let alertController = UIAlertController(title: "\"\(text)\" Not Found", message: "Please Enter the valid UserName or Group Name", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style:.Default ,
                    handler:{ (action) -> Void in
                        
                })
                alertController.addAction(okAction)
                
                presentViewController(alertController, animated: true, completion: nil)
                //            tokenField.reloadData()
            }
            else {
                let alertController = UIAlertController(title: "Alert", message: "Please select atleast one recipient", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style:.Default ,
                    handler:{ (action) -> Void in
                        
                })
                alertController.addAction(okAction)
                presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
            
        else {
            if Helper.lengthOfStringWithoutSpace(alertBoxText) > 0{
                shareOnWorkitem(selectedItems)
            }
            searchState = false
            //        tableView.reloadData()
            //        navigationItem.rightBarButtonItem = nil
            switch type! {
            case .FeedType:
                createFeed()
            default:
                createTask()
            }
        }
    }
    
    
    
    func shareOnWorkitem(selectedItemsArray: NSMutableArray) {
        
        //        let userStringArray = selectedItemsArray.flatMap{ String(($0 as? User)?.email ?? "") }
        //
        //        let groupStringArray = selectedItemsArray.flatMap{ String(($0 as? Group)?.name ?? "") }
        //
        
        var shareDictionary = Dictionary<String,AnyObject>()
        
        shareDictionary["users"] = selectedItemsArray.flatMap{ String(($0 as? User)?.email ?? "") }
        //        shareDictionary["groups"] = selectedItemsArray.flatMap{ String(($0 as? Group)?.name ?? "") }
        
        guard let unwrappedWorkitemId = actionProperty?.workitemId else{
            print("Error")
            return
        }
        
        
        
        Alamofire.request(Router.ShareWorkitem(id: unwrappedWorkitemId, shareDict: shareDictionary)).responseJSON { response in
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
                
                print("Work Item Updated")
                
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
        if let unwrappedCardViewController = actionProperty?.senderViewController as? CardViewController{
            unwrappedCardViewController.clearAndReloadTableviewData()
        }
        
    }
    
    
    func downloadGroups() {
        //        EZLoadingActivity.show("Loading", disableUI: true)
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
        
        Alamofire.request(Router.GetGroups()).responseJSON { response in
            //            EZLoadingActivity.hide()
            LoadingController.instance.hideLoadingView()
            
            
            switch response.result {
                
            case .Success(let JSON):
                if let jsonDict = JSON as? NSDictionary {
                    let status = jsonDict[kServerKeyStatus]
                    
                    if status?.lowercaseString == kServerKeySuccess {
                        var systemArray = [Group]()
                        var customArray = [Group]()
                        if let dataArray = jsonDict[kServerKeyData] as? NSArray {
                            for groupDict in dataArray as! [NSDictionary] {
                                if let group = Parser.groupForDict(groupDict) {
                                    if group.type == GroupType.System.rawValue {
                                        systemArray.append(group)
                                    }
                                    else {
                                        customArray.append(group)
                                    }
                                }
                            }
                        }
                        self.systemGroups = systemArray
                        self.customGroups = customArray
                        self.tableView.reloadData()
                    }
                    else if status?.lowercaseString == kServerKeyFailure {
                        var message = jsonDict[kServerKeyMessage] as? String
                        if response.response?.statusCode == ErrorCode.Forbidden.rawValue {
                            message = "Session Expired"
                        }
                        else if message == nil {
                            message = "An error occured"
                        }
                        
                        let alertController = UIAlertController.init(title: kEmptyString, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                
            case .Failure(let error):
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Session Expired"
                }
                let alertController = UIAlertController.init(title: kEmptyString, message:message , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}
