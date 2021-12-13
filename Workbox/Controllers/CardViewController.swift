
//  CardViewController.swift
//  Workbox
//
//  Created by Ratan D K on 01/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu
import Alamofire
import EZLoadingActivity
import ReachabilitySwift


protocol CardViewControllerDelegate {
    func leftSideMenuTapped()
}

class CardViewController: UIViewController,RightMenuControllerDeleagte {
    
    @IBOutlet weak var tableView: UITableView!
    
    //    var cards = NSMutableArray()
    var cardData = [Workitem]()
    
    var request: Alamofire.Request?
    var requestSearch: Alamofire.Request?
    
    var lastModifiedDateOfLastItemInCards : String?
    var currentPerspective  = Perspective.Card
    var isMoreDataAvailable = false
    var ncTitle: String?
    var tabType : TabID?
    var currentMenu: Menu?
    var currentSubMenu: SubMenu?
    var messageLabel = UILabel()
    var currentFilterIndex: Int?
    
    var refreshControl = UIRefreshControl()
    var filteredTableData = [String]()
    var searchController: UISearchController!
    var applyFilter: String?
    var isRightMenuControllerExpanded:Bool = false
    
    
    var resultsTableController: SearchController!
    var actionViews = [UIView]()
    var delegate: CardViewControllerDelegate?
    
    var skipCount = 0
    var limitCount = 10
    var indexPathsArray = [NSIndexPath]()
    var isWorkItemDownloadingFinished = false
    var fromCherries : Bool = false
    
    var rightMenuController : RightMenuController!
    var currentRightMenuSelected = NSIndexPath(forRow: 0, inSection: 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 33
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.tableViewBackGroundColor()
        cardData = Parser.fetchAllWorkitems()
        if fromCherries == false {
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.tabBarController!.tabBar.frame.size.height, 0.0)
            tableView.contentInset = contentInsets
        }
        ActionController.instance.cardViewController = self
        currentFilterIndex = 0
        
        
        tableView.registerNibWithStrings(String(TSApprovalCell), String(UserMessage01Card), String(NewsFeed01Card), String(GenericFeed01Card), String(NewJoinee01Card), String(ListView01Card), String(LeaveApproval01Card), String(GenericTask01Card),String(BPMApprovalCell), String(PMSApprovalCell))
        
        
        
        
        refreshControl.addTarget(self, action: #selector(CardViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        setSearchController()
        if fromCherries == false {
            createNavBar()
        }
        else {
            createNavBarForApprovals()
        }
        if tabType == TabID.Inbox{
            createFilterDropDown()
        }
        
        if ncTitle == "\(TabID.Inbox)" {
            clearAndReloadTableviewData()
        }
        makeMessageLabel()
        reachability()
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if fromCherries == false {
            createNavBar()
            self.tabBarController?.tabBar.hidden = false
        }
        else {
            createNavBarForApprovals()
            self.tabBarController?.tabBar.hidden = true
        }
        tableView.reloadData()
        self.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    //    override func viewDidLayoutSubviews() {
    //
    //        if searchController.searchBar.text?.characters.count <= 0 && searchController.searchBar.isFirstResponder(){
    //            self.tableView.contentOffset = CGPointMake(0, self.searchController.searchBar.bounds.size.height);
    //            self.edgesForExtendedLayout = UIRectEdge.Bottom
    //        }
    //    }
    
    func makeMessageLabel(){
        
        messageLabel = UILabel(frame: CGRectMake(0,self.view.frame.height/2 - 20,self.view.frame.width, 40))
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.textColor = UIColor.grayColor()
        messageLabel.font = UIFont.boldSystemFontOfSize(18)
        messageLabel.text = "No Cards"
        self.view.addSubview(messageLabel)
        messageLabel.hidden = true
    }
    
    func reachability(){
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        
        reachability.whenReachable = { reachability in
            //             this is called on a background thread, but UI updates must
            //             be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                if reachability.isReachableViaWiFi() {
                    self.currentPerspective = Perspective.Card
                    print("Reachable via WiFi")
                } else {
                    self.currentPerspective = Perspective.Card
                    print("Reachable via Cellular")
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                print("Not reachable")
            }
            
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func setSearchController(){
        resultsTableController = SearchController()
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search People"
        searchController.searchBar.sizeToFit()
        // searchController.searchBar.barTintColor = UIColor.
        
        searchController.searchBar.barTintColor = UIColor.tableViewBackGroundColor()
        searchController.searchBar.tintColor = UIColor.tableViewBackGroundColor()
        searchController.searchBar.backgroundColor = UIColor.tableViewBackGroundColor()
        
        
        
        tableView.tableHeaderView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = true // default is YES
        searchController.searchBar.delegate = self    // so we can monitor text changes + others
        /*
         Search is now just presenting a view controller. As such, normal view controller
         presentation semantics apply. Namely that presentation will walk up the view controller
         hierarchy until it finds the root view controller or one that defines a presentation context.
         */
        definesPresentationContext = true
        self.tableView.contentOffset = CGPointMake(0, self.searchController.searchBar.bounds.size.height);
        
        
    }
    
    func createNavBar() {
        self.navigationController?.setupNavigationBar()
        //        let addItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(CardViewController.createTaskFeed))
        
        let notifButton : UIButton = Helper.createNotificationBadge(UserDefaults.badgeCount())
        notifButton.addTarget(self, action: #selector(CardViewController.notificationButtonPressed), forControlEvents: .TouchUpInside)
        let notificationItem = UIBarButtonItem.init(customView: notifButton)
        
        let rightMenuItem = UIBarButtonItem.init(image: UIImage.init(named: "sideNav"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CardViewController.showRighMenu))
        
        
        
        navigationItem.rightBarButtonItems = [rightMenuItem,notificationItem]
        updateLeftNavBarItems()
    }
    
    
    func showRighMenu(barItem:UIBarButtonItem){
        print("show right menu Vc")
        isRightMenuControllerExpanded = !isRightMenuControllerExpanded
        
        
        
        if isRightMenuControllerExpanded{
            rightMenuController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(String(RightMenuController)) as! RightMenuController
            rightMenuController.delegate = self
            rightMenuController.currentIndex = currentRightMenuSelected
            rightMenuController.modalPresentationStyle = .OverCurrentContext
            presentViewController(rightMenuController, animated: false, completion: nil)
        }else{
            print("close")
            rightMenuController.dismissTapped()
        }
        
        //        self.navigationController?.presentViewController(rightMenuController, animated: false, completion: nil)
    }
    
    func createNavBarForApprovals() {
        self.navigationController?.setupNavigationBar()
        navigationItem.title = "Approvals"
        let cancelItem = UIBarButtonItem.init(barButtonSystemItem : UIBarButtonSystemItem.Cancel, target: self, action: #selector(self.cancelPressed))
        
        navigationItem.rightBarButtonItems = [cancelItem]
        
    }
    
    
    
    func cancelPressed() {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateLeftNavBarItems() {
        
        let menuItem = UIBarButtonItem.init(image: UIImage.init(named: "sideNav"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CardViewController.showSideMenu))
        
        //        let perspectiveItem = UIBarButtonItem.init(image: UIImage.init(named: (currentPerspective == .List ? "gridNav" : "listNav")), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CardViewController.switchPerspective(_:)))
        navigationItem.leftBarButtonItems = [menuItem]
    }
    
    func showSideMenu() {
        if let menuView =  self.navigationItem.titleView as? BTNavigationDropdownMenu{
            menuView.animationDuration = 0
            menuView.hide()
        }
        delegate?.leftSideMenuTapped()
    }
    
    func applySideMenuChanges() {
        //        downloadWorkitems()
    }
    
    
    func createTaskFeed(){
        if let menuView =  self.navigationItem.titleView as? BTNavigationDropdownMenu{
            menuView.animationDuration = 0
            menuView.hide()
        }
        ActionController.instance.createTaskFeed()
    }
    
    
    func notificationButtonPressed(){
        if let menuView =  self.navigationItem.titleView as? BTNavigationDropdownMenu{
            menuView.animationDuration = 0
            menuView.hide()
        }
        ActionController.instance.notificationButtonPressed()
        
    }
    
    func createFilterDropDown(){
        
        guard let unwrappedTabType  = tabType else{
            return
        }
        
        let filterOptions = Parser.fetchFilterOptions(String(Filter), forTabId: unwrappedTabType.rawValue)
        if let unwrappedFilterOptions = filterOptions{
            var filterDisplayNames = unwrappedFilterOptions.flatMap{$0.optionDisplayName} as [String]
            filterDisplayNames.insert("All", atIndex: 0)
            
            let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: filterDisplayNames.first!, items: filterDisplayNames
            )
            menuView.customizeDropDown()
            self.navigationItem.titleView = menuView
            menuView.currentSelectedRow = (currentFilterIndex != nil) ? currentFilterIndex! : 0
            
            menuView.didSelectItemAtIndexHandler = {
                (indexPath: Int) -> () in
                self.currentFilterIndex = indexPath
                if indexPath == 0{
                    self.applyFilter = nil
                }
                else{
                    self.applyFilter = filterDisplayNames[indexPath].lowercaseString
                }
                if self.applyFilter == "bpm task"{
                    self.downloadBPMTasks()
                    
                }
                else{
                    self.downloadWorkitems()
                }
            }
        }
    }
    
    func switchPerspective(sender: AnyObject){
        if let menuView =  self.navigationItem.titleView as? BTNavigationDropdownMenu{
            menuView.animationDuration = 0
            menuView.hide()
        }
        switch(currentPerspective){
        case .Card:
            currentPerspective  = Perspective.List
        case .List:
            currentPerspective = Perspective.Card
        default:
            currentPerspective = Perspective.Card
        }
        //                clearAndReloadTableviewData()
        //        isMoreDataAvailable = false
        
        
        updateLeftNavBarItems()
        
        tableView.reloadData()
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.tabBarController!.tabBar.frame.size.height, 0.0)
        tableView.contentInset = contentInsets
        
        
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        lastModifiedDateOfLastItemInCards = nil
        isLoading = false
        skipCount = 0
        isMoreDataAvailable = true
        self.request?.cancel()
        if self.applyFilter == "bpm task"{
            self.downloadBPMTasks()
            
        }else{
            downloadWorkitems()
        }
    }
    
    func clearAndReloadTableviewData(){
        lastModifiedDateOfLastItemInCards = nil
        isLoading = false
        skipCount = 0
        isMoreDataAvailable = true
        //        self.cardData.removeAll()
        self.request?.cancel()
        //        tableView.reloadData()
        if self.applyFilter == "bpm task"{
            self.downloadBPMTasks()
            
        }else{
            downloadWorkitems()
        }
    }
    
}

// MARK: - Table View Delegate And Datasource Extension

extension CardViewController : UITableViewDataSource, UITableViewDelegate,removeWorkItemForCollaboratorDelegate{
    
    //    func setTableViewDataSourceDelegate < D: protocol<UITableViewDataSource, UITableViewDelegate>> (dataSourceDelegate: D) {
    //        //        tableView.delegate = dataSourceDelegate
    //        //        tableView.dataSource = dataSourceDelegate
    //        tableView.estimatedRowHeight = 33
    //        tableView.rowHeight = UITableViewAutomaticDimension
    //    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isMoreDataAvailable && cardData.count > 0) {
            return cardData.count + 1;
        }
        return cardData.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row < cardData.count{
            let workItemDict = Parser.dictionaryFromData(cardData[indexPath.row].workitemData)
            
            if let unwrappedCreatedBy = workItemDict.valueForKey("createdBy") as? NSDictionary{
                let createdByUser = User(dictionaryData: unwrappedCreatedBy)
                if createdByUser?.id == UserDefaults.loggedInUser()?.id{
                    return true
                }
            }
        }
        return false
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") {action in
            //handle delete
            self.deleteWorkItem(indexPath)
            
            
        }
        deleteAction.backgroundColor = ConstantColor.CWLightGray
        return [deleteAction]
    }
    
    func removeWorkItem() {
        //        deleteWorkItem(self.tableView.indexPathForSelectedRow!)
        self.cardData.removeAtIndex(self.tableView.indexPathForSelectedRow!.row)
        
    }
    
    
    
    
    func deleteWorkItem(indexPath:NSIndexPath){
        self.deleteWorkitem(self.cardData[indexPath.row].workitemId)
        self.cardData.removeAtIndex(indexPath.row)
        
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == cardData.count) && isMoreDataAvailable {
            return loadingCell()
        }
        
        let workitem = cardData[indexPath.row]
        
        let workitemDict = Parser.dictionaryFromData(workitem.workitemData)
        let cardType =  CardType(value: workitem.cardType)
        let cardSubType =  CardSubtype(value: workitem.cardSubtype)
        
        
        
        if(currentPerspective == .List){
            switch(cardType){
            case .TimesheetType:
                switch(cardSubType){
                case .Approve:
                    let cardElement = Approval(JSON: workitemDict)
                    switch(cardElement.defaultCardTemplate){
                    case .Approval01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(TSApprovalCell), forIndexPath: indexPath) as! TSApprovalCell
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }
                default:
                    print(cardType)
                }
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier(String(ListView01Card), forIndexPath: indexPath) as! ListView01Card
                cell.updateCellWithData(workitem, sentBy: self)
                return cell
            }
        }
        else{
            switch(cardType){
            case .CurriculumApprovalTemplate:
                switch (cardSubType) {
                case .CurriculumApprovalTemplate:
                    let cardElement = PMSAppraisalTemplate(JSON: workitemDict)
                    switch(cardElement.defaultCardTemplate){
                    case .PMSApproval01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(PMSApprovalCell), forIndexPath: indexPath) as! PMSApprovalCell
                        
                        cell.updateCellWithData(cardElement, sentBy: self)
                        
                        return cell
                    }
 
                default:
                    print(cardType)
                    
                }
            case .FeedType:
                switch(cardSubType){
                case .NewJoineeType:
                    let cardElement = NewJoinee(JSON: workitemDict)
                    
                    switch(cardElement.defaultCardTemplate){
                    case .NewJoinee01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(NewJoinee01Card), forIndexPath: indexPath) as! NewJoinee01Card
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }
                    
                case .UserMessageType:
                    let cardElement = GenericFeed(JSON: workitemDict)
                    switch(cardElement.defaultCardTemplate){
                    case .UserMessage01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(UserMessage01Card), forIndexPath: indexPath) as! UserMessage01Card
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }
                case .NewsFeedType:
                    let cardElement = NewsFeed(JSON: workitemDict)
                    switch(cardElement.defaultCardTemplate){
                    case .NewsFeed01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(NewsFeed01Card), forIndexPath: indexPath) as! NewsFeed01Card
                        
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }
                default:
                    let cardElement = GenericFeed(JSON: workitemDict)
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
                    switch(cardElement.defaultCardTemplate){
                    case .GenericTask01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(GenericTask01Card), forIndexPath: indexPath) as! GenericTask01Card
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }
                case .BPMTask:
                    let cardElement = BPMApproval(JSON: workitemDict)
                    switch (cardElement.defaultCardTemplate) {
                    case .BPM01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(BPMApprovalCell), forIndexPath: indexPath) as! BPMApprovalCell
                        cell.updateCellWithData(cardElement,sentBy:self)
                        return cell
                        
                    }
                default:
                    let cardElement = GenericTask(JSON: workitemDict)
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
                    switch(cardElement.defaultCardTemplate){
                    case .LeaveApproval01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(LeaveApproval01Card), forIndexPath: indexPath) as! LeaveApproval01Card
                        
                        cell.updateCellWithData(cardElement, sentBy: self)
                        
                        return cell
                    }
                default:
                    print(cardType)
                }
            case .Performance:
                switch(cardSubType){
                case .PMSApproval:
                    let cardElement = PMSAppraisalTemplate(JSON: workitemDict)
                    switch(cardElement.defaultCardTemplate){
                    case .PMSApproval01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(PMSApprovalCell), forIndexPath: indexPath) as! PMSApprovalCell
                        
                        cell.updateCellWithData(cardElement, sentBy: self)
                        
                        return cell
                    }
                default:
                    print(cardType)
                }
            case .CSC:
                switch(cardSubType){
                case .PMSApproval:
                    let cardElement = PMSAppraisalTemplate(JSON: workitemDict)
                    switch(cardElement.defaultCardTemplate){
                    case .PMSApproval01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(PMSApprovalCell), forIndexPath: indexPath) as! PMSApprovalCell
                        
                        cell.updateCellWithData(cardElement, sentBy: self)
                        
                        return cell
                    }
                    
            
                default:
                    print(cardType)
                }
           
                
            case .Recruitment:
                switch(cardSubType){
                case.requisition:
        
                    let cardElement = GenericTask(JSON: workitemDict)
                    switch(cardElement.defaultCardTemplate){
                    case .GenericTask01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(GenericTask01Card), forIndexPath: indexPath) as! GenericTask01Card
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }

                    
                case .jobApplicationException:
                    let cardElement = GenericTask(JSON: workitemDict)
                    switch(cardElement.defaultCardTemplate){
                    case .GenericTask01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(GenericTask01Card), forIndexPath: indexPath) as! GenericTask01Card
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }

                    
                    
                    
                case .offerRollout:
                    let cardElement = GenericTask(JSON: workitemDict)
                    switch(cardElement.defaultCardTemplate){
                    case .GenericTask01Card:
                        let cell = tableView.dequeueReusableCellWithIdentifier(String(GenericTask01Card), forIndexPath: indexPath) as! GenericTask01Card
                        cell.updateCellWithData(cardElement, sentBy: self)
                        return cell
                    }
                    
                
                case .updateRequisition:
                    let cell = tableView.dequeueReusableCellWithIdentifier(String(ListView01Card), forIndexPath: indexPath) as! ListView01Card
                    cell.updateCellWithData(workitem, sentBy: self)
                    return cell

                    
                default:
                    print(cardType)
                    
                }
                
            default:
                let cardElement = GenericFeed(JSON: workitemDict)
                switch(cardElement.defaultCardTemplate){
                case .UserMessage01Card:
                    let cell = tableView.dequeueReusableCellWithIdentifier(String(UserMessage01Card), forIndexPath: indexPath) as! UserMessage01Card
                    cell.updateCellWithData(cardElement, sentBy: self)
                    return cell
                    
                }
            }
            
        }
        let cardElement = GenericFeed(JSON: workitemDict)
        let cell = tableView.dequeueReusableCellWithIdentifier(String(UserMessage01Card), forIndexPath: indexPath) as! UserMessage01Card
        cell.updateCellWithData(cardElement, sentBy: self)
        return cell
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (cell.tag == kLoadingCellTag && isWorkItemDownloadingFinished) {
            downloadMoreWorkitems()
            //            skipCount = self.cardData.count
            //
            ////            [self fetchBeers];
        }
        //
        //        if cardData.count > 9{
        //        if indexPath.row == cardData.count - 1 { // last cell
        //            print("Lastcell " + String(cardData.count) + " " + String(indexPath.row) + " " + String(skipCount))
        //            if isMoreDataAvailable {
        //                downloadMoreWorkitems()
        //            }
        ////        }
        //        }
    }
    
    //    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    ////        func loadingCell() -> UITableViewCell{
    //        let rect = CGRectMake(0, 0, tableView.bounds.width, 33)
    //        let cell = UIView(frame: rect)
    ////                    let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
    ////                    cell.tag = kLoadingCellTag;
    ////                    cell.backgroundColor = tableView.backgroundColor
    //                    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    //                    activityIndicator.center = cell.center
    //                cell.addSubview(activityIndicator)
    //                    activityIndicator.startAnimating()
    //                    return cell
    ////                }
    //
    //    }
    //
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = self.tableView.indexPathForSelectedRow!
        
        //        let workitemData = cardData[indexPath.row]
        
        let detailViewController : DetailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.detailHeaderData = cardData[indexPath.row]
        detailViewController.indexPath = indexPath
        if  self.applyFilter == "bpm task"{
            detailViewController.isBMPFilter = true
        }
        else{
            detailViewController.isBMPFilter = false
            
        }
        
        detailViewController.delegate = self
        //        detailViewController.senderViewController = self
        //        detailViewController.indexOfWorkitemInCards = indexPath.row
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indexPath = self.tableView.indexPathForSelectedRow!
        
        let workitem = cardData[indexPath.row]
        guard let unwrappedWorkitemData = cardData[indexPath.row].workitemData else{
            return
        }
        
        let workitemDict = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedWorkitemData) as! NSDictionary
        
        
        let cardType =  CardType(value: workitem.cardType)
        let cardSubType =  CardSubtype(value: workitem.cardSubtype)
        
        
        switch(cardType){
        case .TimesheetType:
            switch(cardSubType){
            case .Approve:
                let approvalDetailsController = UIStoryboard.Approvals().instantiateViewControllerWithIdentifier(String(TSApprovalDetailController)) as! TSApprovalDetailController
                approvalDetailsController.timesheetApproval = Approval(JSON: workitemDict)
                self.navigationController?.pushViewController(approvalDetailsController, animated: true)
            default:
                print(String(cardType) + "Unknown subtype")
            }
        case .Performance:
            switch(cardSubType){
            case .PMSApproval:
                let webViewController = WebViewController()
                if let workitemId = workitem.workitemId as String?, let templateId = workitemDict.valueForKeyPath("content._id") as? String, let status = workitemDict.valueForKey("status") {
                    webViewController.navTitleString = "Template Detail"
                    webViewController.isNavBarPresent = false
                    webViewController.cherryName = Cherries.PMS
                    webViewController.url = systemURL + "#/mobile/pms/template-detail-approval?templateid=\(templateId)&workitemid=\(workitemId)&status=\(status)"
                    navigationController?.pushViewController(webViewController, animated: true)
                }
                
                
            default:
                print(String(cardType) + "Unknown subtype")
            }
            
            
        case .Recruitment:
            switch(cardSubType){
            case .requisition:
                let webViewController = WebViewController()
                if let workitemId = workitem.workitemId as String?, let templateId = workitemDict.valueForKeyPath("content._id") as? String {
                    webViewController.navTitleString = "Requisition"
                    webViewController.isNavBarPresent = false
                    webViewController.cherryName = Cherries.Recruitment
                    webViewController.url = systemURL + "#/mobile/recruitment/workitemDetail?id=\(templateId)&workitemid=\(workitemId)"
                    navigationController?.pushViewController(webViewController, animated: true)
                }
                
            case .updateRequisition:
                let webViewController = WebViewController()
                if let templateId = workitemDict.valueForKeyPath("_id") as? String {
                    let nonBudgeted = "nonBudgeted"
                    webViewController.navTitleString = "Update Requisition"
                    webViewController.isNavBarPresent = false
                    webViewController.cherryName = Cherries.Recruitment
                    webViewController.url = systemURL + "#/mobile/recruitment/update-non-budgeted-requisition?id=\(templateId)&subtype=\(nonBudgeted)"
                    navigationController?.pushViewController(webViewController, animated: true)
                }

            case .jobApplicationException:
                let webViewController = WebViewController()
                if let workitemId = workitem.workitemId as String?, let templateId = workitemDict.valueForKeyPath("content.requisitionId") as? String {
                    webViewController.navTitleString = "Job Application"
                    webViewController.isNavBarPresent = false
                    webViewController.cherryName = Cherries.Recruitment
                    webViewController.url = systemURL + "#/mobile/recruitment/exception-detail?id=\(templateId)&workitemId=\(workitemId)"
                    navigationController?.pushViewController(webViewController, animated: true)
                }

            case .offerRollout:
                let webViewController = WebViewController()
                if let workitemId = workitem.workitemId as String?, let templateId = workitemDict.valueForKeyPath("content.requisitionId") as? String{
                    webViewController.navTitleString = "Offer"
                    webViewController.isNavBarPresent = false
                    webViewController.cherryName = Cherries.Recruitment
                    webViewController.url = systemURL + "#/mobile/recruitment/request-for-exception-detail?id=\(templateId)&workitemId=\(workitemId)"
                    navigationController?.pushViewController(webViewController, animated: true)
                }

                
                
            default:
                print(String(cardType) + "Unknown subtype")
            }
            
        default:
            performSegueWithIdentifier(ConstantIdentifier.Segue.cardToDetail, sender: self)
        }
        
    }
    
    
    
    
    //    Methods for adding UI elements
    func loadingCell() -> UITableViewCell{
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.tag = kLoadingCellTag;
        cell.backgroundColor = tableView.backgroundColor
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.center = CGPoint(x: UIScreen.mainScreen().bounds.midX, y: cell.bounds.midY)
        cell.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        return cell
    }
}




//MARK: - Scroll View
extension CardViewController : UIScrollViewDelegate{
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y;
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        if(maximumOffset - currentOffset <= 10.0){
            //            if(scrollView.tag == kLoadingCellTag){ ///TEMP
            //                downloadWorkitems()
            //            }
            downloadMoreWorkitems()
        }
    }
}

//MARK: - Search Controller
extension CardViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating{
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //        self.searchController.searchBar.tintColor = UIColor.whiteColor()
        //        self.searchController.searchBar.barStyle = UIBarStyle.Black
        //        self.searchController.searchBar.translucent = true
        //        self.searchController.searchBar.alpha = 0.9
        //        self.tableView.alpha = 0.9
        // Update the filtered array based on the search text.
        // Strip out all the leading and trailing spaces.
        //        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        //        let strippedString = searchController.searchBar.text!.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        // let searchText = strippedString.componentsSeparatedByString(" ") as [String]
        // Hand over the filtered results to our search results table.
        guard let searchText = searchController.searchBar.text?.lowercaseString else{
            return
        }
        downloadAndDisplaySearchedUser(searchText)
    }
    
}

//MARK: - Network Operations
extension CardViewController {
    
    func downloadWorkitems() {
        skipCount = 0
        ActionController.instance.downloadAndUpdateConfiguration()
        
        //        if (refreshControl.refreshing == false) {
        //            self.refreshControl.beginRefreshing()
        //        }
        
        self.request =  Alamofire.request(Router.GetWorkitems(limit : 10, skip : skipCount, filter: applyFilter)).responseJSON { response in
            self.refreshControl.endRefreshing()
            
            var numberOfObjects = 0
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                print(JSON)
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    let message = jsonData[kServerKeyMessage]?.lowercaseString
                    
                    #function
                    let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    
                    if let senderController =   getTopViewController(){
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                    print("Error Occured: JSON Without success:\(jsonData)")
                    return
                }
                
                guard let jsonDataDictionaryArray = jsonData.valueForKey("data") as? [NSDictionary] else{
                    print("Cannot cast JSON to Dictionary Array: \(JSON)")
                    return
                }
                
                self.cardData.removeAll()
                
                for item in jsonDataDictionaryArray{
                    if let workitem = Parser.workitemForDictionary(item){
                        let type = CardType(value : workitem.cardType)
                        let subtype = CardSubtype(value : workitem.cardSubtype)
                        
                        if let template =  Parser.fetchCardTemplate(forType: type, forSubtype: subtype) where template.characters.count > 0{
                            self.cardData.append(workitem)
                            numberOfObjects += 1
                            self.skipCount = self.skipCount + 1
                        }
                    }
                }
                
                if(numberOfObjects < self.limitCount){
                    self.isMoreDataAvailable = false
                }else{
                    self.isMoreDataAvailable = true
                }
                
                if let lastModifiedDateString = jsonDataDictionaryArray.last?.valueForKey("updatedAt") as? String {
                    self.lastModifiedDateOfLastItemInCards = lastModifiedDateString
                }
                
                if self.refreshControl.refreshing
                {
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation:UITableViewRowAnimation.Fade)
                }
                else {
                    //                                                self.tableView.reloadData()
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation:UITableViewRowAnimation.Fade)
                    
                    
                }
                self.tableView.reloadData()
                if self.cardData.count == 0 {
                    self.messageLabel.hidden = false
                    
                }
                else{
                    self.messageLabel.hidden = true
                }
                self.isWorkItemDownloadingFinished = true
                print("number of cards = \(self.cardData.count)")
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                #function
                if self.cardData.count == 0 {
                    self.messageLabel.hidden = false
                }
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "sessionExpiredMessage"
                    
                    let alertController = UIAlertController.init(title:  NSLocalizedString("errorOccured", comment: ""), message:NSLocalizedString(message, comment: "") , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    
    func downloadMoreWorkitems() {
        ActionController.instance.downloadAndUpdateConfiguration()
        
        if (refreshControl.refreshing == false) {
            self.refreshControl.beginRefreshing()
        }
        
        self.request = Alamofire.request(Router.GetWorkitems(limit : limitCount, skip : skipCount, filter: applyFilter)).responseJSON { response in
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
                    let message = jsonData[kServerKeyMessage]?.lowercaseString
                    #function
                    let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    
                    if let senderController =   getTopViewController(){
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                    print("Error Occured: JSON Without success")
                    return
                }
                
                guard let jsonDataDictionaryArray = jsonData.valueForKey("data") as? [NSDictionary] else{
                    print("Cannot cast JSON to Dictionary Array: \(JSON)")
                    return
                }
                //                    dispatch_async(dispzatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                
                for item in jsonDataDictionaryArray{
                    if let workitem = Parser.workitemForDictionary(item){
                        let type = CardType(value : workitem.cardType)
                        let subtype = CardSubtype(value : workitem.cardSubtype)
                        
                        if let template =  Parser.fetchCardTemplate(forType: type, forSubtype: subtype) where template.characters.count > 0{
                            self.cardData.append(workitem)
                            numberOfObjects += 1
                            self.skipCount = self.skipCount + 1
                            
                            if(numberOfObjects < self.limitCount){
                                self.isMoreDataAvailable = false
                            }else{
                                self.isMoreDataAvailable = true
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
                
                if self.cardData.count == 0 {
                    self.messageLabel.hidden = false
                }
                else{
                    self.messageLabel.hidden = true
                }
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                if self.cardData.count == 0 {
                    self.messageLabel.hidden = false
                }
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "sessionExpiredMessage"
                }
                let alertController = UIAlertController.init(title:  NSLocalizedString("errorOccured", comment: ""), message:NSLocalizedString(message, comment: "") , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
        }
    }
    
    func downloadAndDisplaySearchedUser(searchString : String) {
        requestSearch?.cancel()
        requestSearch =  Alamofire.request(Router.SearchUser(text: searchString)).responseJSON { response in
            
            switch response.result {
            case .Success(let JSON):
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    var message = jsonData[kServerKeyMessage]?.lowercaseString
                    #function
                    let alertController = UIAlertController.init(title:  NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    
                    if let senderController =   getTopViewController(){
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                    print("Error Occured: JSON Without success")
                    return
                }
                
                guard let jsonDataDictionaryArray = jsonData.valueForKey("data") as? [NSDictionary] else{
                    print("Cannot cast JSON to Dictionary: \(JSON)")
                    return
                }
                
                let usersData = jsonDataDictionaryArray.flatMap{ User(dictionaryData: $0)}
                let resultsController = self.searchController.searchResultsController as! SearchController
                resultsController.users.removeAll()
                resultsController.users.appendContentsOf(usersData)
                resultsController.tableView.reloadData()
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func deleteWorkitem(workitemId : String?) {
        guard let unwrappedWorkitemId = workitemId else{
            print("Nil Workitem ID")
            return
        }
        Alamofire.request(Router.DeleteWorkitem(id: unwrappedWorkitemId)).responseJSON { response in
            
            switch response.result {
            case .Success(let JSON):
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    var message = jsonData[kServerKeyMessage]?.lowercaseString
                    
                    //                    let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    //                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    //                    alertController.addAction(okAction)
                    //
                    //                    if let senderController =   getTopViewController(){
                    //                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    //                    }
                    print("Error Occured: JSON Without success "+String(jsonData))
                    return
                }
                
                print("DID DELETE" + String(workitemId))
                
            case .Failure(let error):
                var message = error.localizedDescription
                
                let alertController = UIAlertController.init(title:  NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                
                if let senderController =   getTopViewController(){
                    senderController.presentViewController(alertController, animated: true, completion: nil)
                }
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func downloadBPMTasks(){
        
        
        ActionController.instance.downloadAndUpdateConfiguration()
        
        Alamofire.request(Router.GetBPMTask()).responseJSON { response in
            self.refreshControl.endRefreshing()
            
            switch response.result {
                
            case .Success(let JSON):
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    var message = jsonData[kServerKeyMessage]?.lowercaseString
                    print("Error Occured: JSON Without success "+String(jsonData))
                    return
                }
                
                guard let jsonDataDictionaryArray = jsonData.valueForKey("data") as? [NSDictionary] else{
                    print("Cannot cast JSON to Dictionary Array: \(JSON)")
                    return
                }
                
                self.cardData.removeAll()
                
                for item in jsonDataDictionaryArray{
                    if let workitem = Parser.workitemForDictionary(item){
                        let type = CardType(value : workitem.cardType)
                        let subtype = CardSubtype(value : workitem.cardSubtype)
                        
                        if let template =  Parser.fetchCardTemplate(forType: type, forSubtype: subtype) where template.characters.count > 0{
                            self.cardData.append(workitem)
                            
                        }
                    }
                }
                self.isMoreDataAvailable = false
                
                if self.refreshControl.refreshing
                {
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation:UITableViewRowAnimation.Fade)
                }
                else {
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation:UITableViewRowAnimation.Fade)
                }
                
                self.tableView.reloadData()
                
                if self.cardData.count == 0 {
                    self.messageLabel.hidden = false
                    
                }
                else{
                    self.messageLabel.hidden = true
                }
                print("number of cards = \(self.cardData.count)")
                
                
                
            case .Failure(let error):
                var message = error.localizedDescription
                
                let alertController = UIAlertController.init(title:  NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                
                if let senderController =   getTopViewController(){
                    senderController.presentViewController(alertController, animated: true, completion: nil)
                }
                print("Request failed with error: \(error)")
            }
        }
    }
    
}


//MARK: - RightMenuController Delegate Methods

extension CardViewController{
    
    func itemSelected(type:CardType,selectedIndexPath: NSIndexPath){
        
        currentRightMenuSelected = selectedIndexPath
        
        lastModifiedDateOfLastItemInCards = nil
        isLoading = false
        skipCount = 0
        isMoreDataAvailable = true
        self.request?.cancel()
        
        switch type{
        case .CSC,.Performance:
            applyFilter = type.rawValue
            downloadWorkitems()
            break
            
        case .LMS:
            
            switch selectedIndexPath.row
            {
            case 3:
            
            let webViewController = WebViewController()
            webViewController.cherryName = cherriesFromLocal[selectedIndexPath.row]
            webViewController.url = systemURL + "#mobile/lms/tp-index"
           navigationController?.pushViewController(webViewController, animated: true)
            break
                
            default:
                break

            }
        default:
            applyFilter = nil
            downloadWorkitems()
            break
            
        }
    }
    
    func updateExpandedState() {
        isRightMenuControllerExpanded = !isRightMenuControllerExpanded
    }
    
}






