//
//  TSApprovalController.swift
//  Workbox
//
//  Created by Anagha Ajith on 16/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu
import ALTextInputBar
import Alamofire
import EZLoadingActivity
import Alamofire



class TSApprovalController: UIViewController, UINavigationControllerDelegate, UINavigationBarDelegate, ALTextInputBarDelegate {

    var request: Alamofire.Request?
    var isLoading = false
    var refreshControl = UIRefreshControl()
    var approvalDataArray = [Approval]()
    var lastModifiedDateOfLastItemInCards : String?
    var isMoreDataAvailable = true
    var messageLabel = UILabel()
    var menuView: BTNavigationDropdownMenu?

    
//    var allApprovalsArray = [Approval]()
    var filteredApprovalsArray = [Approval]()
    // dummy data; to be filled with projects array
    var filterDropdownArray = [String]()
    let textInputBar = ALTextInputBar()
    var timesheetsToApproveArray = [String]()
    var rightButton : UIButton?
    var selectedIndex:Int = 0
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: String(TSApprovalCell), bundle: nil), forCellReuseIdentifier: String(TSApprovalCell))
        tableView.estimatedRowHeight = 33
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl.addTarget(self, action: #selector(TSApprovalController.handleRefresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        textInputBar.hidden = true
        makeMessageLabel()
        setupNavigationBar()

        // Do any additional setup after loading the view.
        
        clearAndReloadTableviewData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        createFilterDropDown()
        
        if (menuView != nil){
            menuView!.currentSelectedRow = selectedIndex
            menuView!.setMenuTitle("\(filterDropdownArray[selectedIndex])")
            
        }
        tableView.reloadData()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        textInputBar.frame.size.width = view.bounds.size.width
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        lastModifiedDateOfLastItemInCards = nil
        isLoading = false
        isMoreDataAvailable = true
        self.request?.cancel()
        downloadTasks()
    }
    
    func makeMessageLabel (){
        
        messageLabel = UILabel(frame: CGRectMake(0,self.view.frame.height/2 - 20,self.view.frame.width, 40))
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.textColor = UIColor.grayColor()
        messageLabel.font = UIFont.boldSystemFontOfSize(18)
        messageLabel.text = "No Approvals"
        self.view.addSubview(messageLabel)
        messageLabel.hidden = true
    }
    
    func clearAndReloadTableviewData(){
        lastModifiedDateOfLastItemInCards = nil
        isLoading = false
        isMoreDataAvailable = true
//        self.approvalDataArray.removeAll()
        self.request?.cancel()
//        tableView.reloadData()
        downloadTasks()
    }
    

    //Function to set up the navigation bar along with buttons.
    func setupNavigationBar() {
        
        self.navigationController?.setupNavigationBar()
        
        let leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(TSApprovalController.cancelButtonPressed(_:)))
        
        let rightButton = UIBarButtonItem(title: nil, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(TSApprovalController.approveAllButtonPressed(_:)))
        rightButton.image = AssetImage.approveAll.image
        
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    //Function for the dropdown filter
    func createFilterDropDown() {
        let filterItems = filterDropdownArray
        if filterItems.count > 0{
            menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: filterItems.first!, items: filterItems)
            menuView?.customizeDropDown()
            self.navigationItem.titleView = menuView
            menuView?.didSelectItemAtIndexHandler = {
                (indexPath: Int) -> () in
                self.selectedIndex = indexPath
                self.filterApprovalsTimesheetForProjectSelected()
            }
        }
        else{
            print("NO Projects to approve")
        }
    }
    
    func filterApprovalsTimesheetForProjectSelected(){
       
        if filterDropdownArray.count > 0{
        let projectName = filterDropdownArray[selectedIndex]
            
        filteredApprovalsArray.removeAll(keepCapacity: false)
        filteredApprovalsArray = approvalDataArray.filter({$0.projectName! == projectName && $0.cardStatus == .Open})
            if self.filteredApprovalsArray.count == 0 {
                navigationItem.rightBarButtonItem?.enabled = false
                self.messageLabel.hidden = false
            }
            else{
                for approval in filteredApprovalsArray{
                    let loggedInUser = UserDefaults.loggedInUser()
                    if let assignedUser = approval.assignedTo?.filter({$0.id == loggedInUser!.id}){
                        if assignedUser.count > 0{
                        navigationItem.rightBarButtonItem?.enabled = true
                        }
                        else{
                            navigationItem.rightBarButtonItem?.enabled = false
                            print("you are not a manager")

                        }
                    }
                }
                self.messageLabel.hidden = true
            }

        tableView.reloadData()
        }
        else{
            print("you are not a manager")
        }
        
    }
    
    //Function for approve all
    func approveAllButtonPressed(sender : UIBarButtonItem) {
        
        menuView?.hide()
        
        let alertController = UIAlertController(title: NSLocalizedString("approveAllAlertControllerTitle", comment: ""), message: "Approve all the timesheets?", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: NSLocalizedString("okActionTitle", comment: ""), style: .Default, handler: { (action) -> Void in
            var array = [String]()
            for timesheet in  self.filteredApprovalsArray{
                array.append(timesheet.id!)
                //                for a in array {
                //                ActionController.instance.approve(a, sentBy: self)
                //                }
                
            }
            if array.count > 0{
            ActionController.instance.approveAll(array, sentBy: self)
            }
            else{
                let alertController = UIAlertController(title: NSLocalizedString("actionNotPossible", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title:NSLocalizedString("okActionTitle", comment: ""), style: .Default, handler: { (action) -> Void in
                })
                alertController.addAction(ok)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
        })
        let cancel = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .Default, handler: { (action) -> Void in
            
        })
        alertController.addAction(ok)
        alertController.addAction(cancel)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //Function for cancel button
    func cancelButtonPressed(sender: UIBarButtonItem){
        menuView?.hide()
        dismissViewControllerAnimated(true, completion: nil)
        print("Cancel button Pressed")
        
    }
    
    //Function to configure the input text bar
    func configureInputBar() {
        
        rightButton = UIButton(frame: CGRectMake(0,0,30,30))
        rightButton!.setImage(AssetImage.send.image, forState: UIControlState.Normal)
        textInputBar.showTextViewBorder = true
        textInputBar.rightView = rightButton
        textInputBar.backgroundColor = UIColor(white: 0.95, alpha: 1)
        rightButton!.addTarget(self, action: #selector(TSApprovalController.sendButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func sendButtonPressed(sender:UIButton){
        print("Send button pressed")
           print(textInputBar.text)
    }
    
    //MARK: - ALTextInputBar Delegate method
    func textViewDidChange(textView: ALTextView) {
        
        if Helper.lengthOfStringWithoutSpace(textView.text!) == 0{
            rightButton?.enabled = false
        }
        else
        {
            rightButton?.enabled = true
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return textInputBar
        }
    }
    
    // This is also required
    override func canBecomeFirstResponder() -> Bool {
        
        return true
    }
}

//MARK: - Extensions
extension TSApprovalController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredApprovalsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let approveCell = tableView.dequeueReusableCellWithIdentifier(String(TSApprovalCell), forIndexPath: indexPath) as! TSApprovalCell
        
        approveCell.updateCellWithData(filteredApprovalsArray[indexPath.row], sentBy: self)
        
        return approveCell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        textInputBar.hidden = true
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
   
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let approvalDetailsController = UIStoryboard.Approvals().instantiateViewControllerWithIdentifier(String(TSApprovalDetailController)) as! TSApprovalDetailController
        
        approvalDetailsController.timesheetApproval = (filteredApprovalsArray[indexPath.row])
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.pushViewController(approvalDetailsController, animated: true)
    }
    
}


//MARK: - Network Operations
extension TSApprovalController {
    
    func downloadTasks() {
        if(!isLoading){
            isLoading = true
            
            if(refreshControl.refreshing == false){
//                EZLoadingActivity.show("Loading", disableUI: true)
                LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)

            }
            LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)

            self.request =  Alamofire.request(Router.GetWorkitems(limit: 0, skip: 0, filter: InboxFilter.Timesheet.rawValue)).responseJSON { response in
//                EZLoadingActivity.hide()
                LoadingController.instance.hideLoadingView()

                self.refreshControl.endRefreshing()
                
                var numberOfObjects = 0
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
                        
                        if let senderController =   getTopViewController(){
                            senderController.presentViewController(alertController, animated: true, completion: nil)
                        }
                        print("Error Occured: JSON Without success")
                        return
                    }
                    
                    guard let jsonDataDictionary = jsonData.valueForKey("data") as? [NSDictionary] else{
                        print("Cannot cast JSON to Dictionary Array: \(JSON)")
                        return
                    }

                    
                    self.approvalDataArray.removeAll()
                    let _ = jsonDataDictionary.map{
                        numberOfObjects += 1
                        
                            let subType =  CardSubtype(rawValue: ($0.valueForKeyPath("card.subtype") as? String) ?? "") ?? CardSubtype.UnknownType
                            
                            if subType == CardSubtype.Approve{
                                self.approvalDataArray.append(Approval(JSON: $0))
                            }
                    }

                    for timesheetApproval in self.approvalDataArray{

                        if let projectName = timesheetApproval.projectName{
                            let resultsArray = self.filterDropdownArray.filter({$0 == projectName})
                            if resultsArray.count == 0{
                            self.filterDropdownArray.append(projectName)
                            }
                        }
                            
                        else{
                            if let projectId = timesheetApproval.projectId{
                                let resultsArray = self.filterDropdownArray.filter({$0 == projectId})
                                if resultsArray.count == 0{
                                    self.filterDropdownArray.append(projectId)
                                }
                            }
                            else{
                                timesheetApproval.projectName = "Others"
                                let resultsArray = self.filterDropdownArray.filter({$0 == "Others"})
                                if resultsArray.count == 0{
                                    self.filterDropdownArray.append("Others")
                                    print("project ID nil")
                                }
                            }
                        }
                    }
                    
                    
                    if(numberOfObjects <= 0){
                        self.isMoreDataAvailable = false
                    }else{
                        self.isMoreDataAvailable = true
                    }
                    
                    if let lastModifiedDateString = jsonDataDictionary.last?.valueForKey("updatedAt") as? String {
                        self.lastModifiedDateOfLastItemInCards = lastModifiedDateString
                    }
                    
                    if self.refreshControl.refreshing
                    {
                        self.refreshControl.endRefreshing()
                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation:UITableViewRowAnimation.Fade)
                    }
                    else {
                         self.createFilterDropDown()
                        self.filterApprovalsTimesheetForProjectSelected()
                        self.tableView.reloadData()
                        
                    }
//                    EZLoadingActivity.hide()
                    LoadingController.instance.hideLoadingView()

                    self.isLoading = false
                    if self.filteredApprovalsArray.count == 0 {
                        self.messageLabel.hidden = false
                        self.navigationItem.rightBarButtonItem?.enabled = false
                    }
                    else{
                        self.messageLabel.hidden = true
                        self.navigationItem.rightBarButtonItem?.enabled = true
                    }
                    
                    
                case .Failure(let error):
                    if self.filteredApprovalsArray.count == 0 {
                        self.messageLabel.hidden = false
                        
                    }
                    else{
                        self.messageLabel.hidden = true
                        
                    }
                    print("Request failed with error: \(error)")
                    self.isLoading = false
                   
                    var message = error.localizedDescription
                    if error.code == 403 {
                        message = "Session Expired"
                    }
                    let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
}









