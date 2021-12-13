//
//  TSHomeController.swift
//  Workbox
//
//  Created by CHetan Anand on 18/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu
import Alamofire
import EZLoadingActivity
import BRYXBanner



class TSHomeController: UIViewController, CopyButtonPressedDelegate {
    
    //MARK:- outlets and variables
    var TSHomeControllerCompletionHandler : (() -> Void)!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var clockedHours: UILabel!
    @IBOutlet weak var clockedHoursView: UIView!
    
    @IBOutlet weak var clockedHoursBackgroundView: UIView!
    @IBOutlet weak var actionSaveSubmitViewHeightContraint: NSLayoutConstraint!
    
    //    @IBOutlet weak var actionSubmitView: UIView!
    
    //    @IBOutlet weak var actionSaveSubmitView: UIView!
    
    var request: Alamofire.Request?
    var isLoading = false
    var sideMenuController: SideMenuController?
    var refreshControl = UIRefreshControl()
    var flag : Int = 0
    var filterDropDownArray = [TSWeekFromTo]()
    var kclockedHoursViewHeight:CGFloat = 47
    
    //    var filterView : BTNavigationDropdownMenu?
    var timesheetWeek = TimesheetWeek()
    var dayArray = [String]()
    var messageLabel = UILabel()
    var startEndDateForPreviousWeek = TSWeekFromTo()
    var copyOverlayController : TSCopyOverlayController!
    var statusLabel:UILabel?
    var isSubmit: Bool?
    var currentSelectedDate =  TSWeekFromTo()
    var currentTimesheetStatus:TSStatus? = nil
    var allTasks = [TSTask]()
    var date : String?
    var infoButton = UIButton()
    var resetButton = UIButton()
    var copyLastWeekButton = UIBarButtonItem()
    var saveButtonWidthCnstraintInitialValue : CGFloat!
    var fromNotif : Bool = false
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        ActionController.instance.downloadAndUpdateConfiguration()
        
        setupNavigationBar()
        makeMessageLabel()
        
        
        downloadTasks(date)
        downloadFilterDropDown()
        print(TSHomeControllerCompletionHandler)
        copyOverlayController = UIStoryboard.TimeSheet().instantiateViewControllerWithIdentifier(String(TSCopyOverlayController)) as? TSCopyOverlayController
        copyOverlayController!.delegate = self
        tableView.registerNib(UINib(nibName: String(TSHomeCell), bundle: nil), forCellReuseIdentifier: String(TSHomeCell))
        self.tableView.estimatedRowHeight = 33
        self.tableView.rowHeight = UITableViewAutomaticDimension
        clockedHoursBackgroundView.backgroundColor = UIColor.navBarColor()
        clockedHoursView.backgroundColor = UIColor.navBarColor()
        clockedHoursView.addSubview(resetButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let menuItem = UIBarButtonItem.init(image: AssetImage.sideNav.image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(TSHomeController.showSideMenu(_:)))
        let closeItem = UIBarButtonItem.init(image: AssetImage.cross.image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(TSHomeController.closeButtonPressed))
        
        let padding:CGFloat = 8
        infoButton.frame = CGRectMake(0,7,55,35)
        //        intoButton.backgroundColor = UIColor.greenColor()
        infoButton.setImage(AssetImage.info.image, forState: .Normal)
        infoButton.imageEdgeInsets = UIEdgeInsetsMake(0, padding, 0, 0)
        infoButton.addTarget(self, action: #selector(TSHomeController.infoButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        
        let resetButtonWidth:CGFloat = 55
        let resetButtonX:CGFloat = clockedHoursView.bounds.maxX - (resetButtonWidth)
        resetButton.frame = CGRectMake(resetButtonX,7,resetButtonWidth,35)
        //        resetItem.backgroundColor = UIColor.greenColor()
        
        resetButton.setImage(AssetImage.resetAll.image, forState: .Normal)
        resetButton.imageEdgeInsets = UIEdgeInsetsMake(0, 12, 0, padding)
        
        resetButton.addTarget(self, action: #selector(TSHomeController.resetButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        copyLastWeekButton = UIBarButtonItem.init(image: AssetImage.copyAll.image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(TSHomeController.copyFromPreviousWeekButtonPressed(_:)))
        
        navigationItem.leftBarButtonItems = [closeItem, menuItem]
        navigationItem.rightBarButtonItems = [copyLastWeekButton,menuItem]
        
        formatUIForOutlets()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeButtonPressed(){
        if let menuView =  self.navigationItem.titleView as? BTNavigationDropdownMenu{
            menuView.animationDuration = 0
            menuView.hide()
        }
        
        if TSHomeControllerCompletionHandler != nil {
            
            self.TSHomeControllerCompletionHandler()
            
        }
        
    }
    
    func makeMessageLabel(){
        
        messageLabel = UILabel(frame: CGRectMake(0,self.view.frame.height/2 - 20,self.view.frame.width, 40))
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.textColor = UIColor.grayColor()
        messageLabel.font = UIFont.boldSystemFontOfSize(18)
        messageLabel.text = "No Timesheets"
        self.view.addSubview(messageLabel)
        messageLabel.hidden = true
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        isLoading = false
        self.request?.cancel()
        
        if let timesheet = timesheetWeek.timesheets {
            if timesheet.count > 0 {
                downloadTasks(Helper.stringForDate(currentSelectedDate.startDate, format: "ddMMyyyy"))
            }
            
        }
        else {
            refreshControl.endRefreshing()
        }
        
    }
    
    //MARK: - Delegate method
    func copyButtonPressed(index: Int) {
        copyOverlayController.selectedRows.removeAll()
        copyOverlayController!.timesheetProjects = timesheetWeek.timesheets![index].projects
        addViewController(copyOverlayController!)
        copyOverlayController!.copyButtonForIndexPressed(index)
        
    }
    
    func projectButtonPressed(projectName: String,index:Int) {
        if var timesheets = timesheetWeek.timesheets{
            let timesheet = timesheets[index]
            if let projects = timesheet.projects{
                let projectToFindIndexOf = projects.filter({$0.name == projectName})
                let indexTofilter = projects.indexOf({$0.name == projectToFindIndexOf.first?.name })
                openTSTaskSelectControllerForIndex(index,projectIndex: indexTofilter!)
            }
        }
    }
    
    //MARK: - Get days array
    
    func getDayArray() {
        if let timesheets = timesheetWeek.timesheets {
            dayArray = [String]()
            for timesheet in timesheets {
                dayArray.append(Helper.stringForDate(timesheet.date, format: "EEEE"))
            }
            copyOverlayController!.days = dayArray
        }
    }
    
    
    //MARK: - Organise projects
    func organiseProjects(givenProjects: [TSProject]) -> [TSProject] {
        
        var allProjects = [TSProject]()
        allProjects += givenProjects
        
        // Add Non projects to Entered projects if not added
        let allNonProjectTasks = nonProjectTasks()
        for nonProjectTask in allNonProjectTasks as [TSTask] {
            var currentNonProjectIsAlreadyAdded = false
            for project in givenProjects as [TSProject] {
                if (project.id == nil && nonProjectTask.type == project.name)
                {
                    currentNonProjectIsAlreadyAdded = true
                    break;
                }
            }
            
            if !currentNonProjectIsAlreadyAdded {
                let nonProject = TSProject()
                nonProject.name = nonProjectTask.type
                nonProject.id = nil
                allProjects.append(nonProject)
            }
        }
        
        // Recreate projects with matching tasks
        var finalProjects = [TSProject]()
        for project in allProjects as [TSProject] {
            let allTasksForThisProject = tasksForType(project.name!)
            
            var newTasks = [TSTask]()
            if project.tasks?.count > 0 {
                newTasks += project.tasks!
            }
            
            for task in allTasksForThisProject as [TSTask]
            {
                var taskAlreadyEntered = false
                if project.tasks?.count > 0 {
                    for enteredTask in project.tasks! as [TSTask] {
                        if enteredTask.id == task.id {
                            taskAlreadyEntered = true
                            break;
                        }
                    }
                }
                
                if !taskAlreadyEntered {
                    
                    let newTask = TSTask()
                    newTask.id = task.id
                    newTask.name = task.name
                    newTask.type = task.type
                    newTask.submittedHours = task.submittedHours
                    newTask.milestone = task.milestone
                    
                    if let sourceTaskProject = task.project {
                        let newProject = TSProject()
                        newProject.id = sourceTaskProject.id
                        newProject.name = sourceTaskProject.name
                        newProject.type = sourceTaskProject.type
                        newTask.project = newProject
                    }
                    
                    newTasks.append(newTask)
                }
            }
            
            project.tasks = newTasks
            finalProjects.append(project)
        }
        
        return finalProjects
    }
    
    func nonProjectTasks() -> [TSTask] {
        var nonProjectTasks = [TSTask]()
        var nonProjectTypes = [String]()
        for task in allTasks as [TSTask] {
            if task.project == nil && !nonProjectTypes.contains(task.type!) {
                nonProjectTasks.append(task)
                nonProjectTypes.append(task.type!)
            }
        }
        return nonProjectTasks
    }
    
    func tasksForType(type: String) -> [TSTask] {
        var tasks = [TSTask]()
        
        for task in allTasks as [TSTask] {
            if task.type == "project" || task.type == "Project" {
                if let project = task.project where project.name == type {
                    tasks.append(task)
                }
            }
            else if task.type == type {
                tasks.append(task)
            }
        }
        return tasks
    }
    
    //MARK: - Service call for timesheet download
    func downloadWeekTimesheet(date: String?) {
        
        //      EZLoadingActivity.show("Loading", disableUI: true)
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
        
        Alamofire.request(Router.GetTimesheetForWeek(date: date)).responseJSON { response in
            //          EZLoadingActivity.hide()
            LoadingController.instance.hideLoadingView()
            
            switch response.result {
                
            case .Success(let JSON):
                
                if  let jsonData = JSON as? NSDictionary  {
                    
                    let status = jsonData[kServerKeyStatus]
                    
                    if status?.lowercaseString == kServerKeySuccess {
                        
                        if let dataDict = jsonData.valueForKey("data") as? NSDictionary  {
                            
                            if let timesheetWeekParsed = Parser.timesheetWeekFromDict(dataDict) {
                                LoadingController.instance.hideLoadingView()
                                self.timesheetWeek = timesheetWeekParsed
                                for timesheet in self.timesheetWeek.timesheets as [Timesheet]! {
                                    timesheet.projects = self.organiseProjects(timesheet.projects!)
                                }
                                self.currentTimesheetStatus = self.statusForWeekTimesheet()
                                self.getDayArray()
                                self.formatUIForOutlets()
                                self.tableView.reloadData()
                            }
                        }
                    }
                        
                    else if status?.lowercaseString == kServerKeyFailure {
                        var message = jsonData[kServerKeyMessage] as? String
                        if response.response?.statusCode == ErrorCode.Forbidden.rawValue {
                            message = "Session Expired"
                        }
                        else if message == nil {
                            message = "An error occured"
                        }
                        
                        self.messageLabel.hidden = self.timesheetWeek.timesheets?.count > 0 ? true : false
                        
                        let alertController = UIAlertController(title: kEmptyString, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let okAction = UIAlertAction(title:NSLocalizedString("okActionTitle", comment: ""), style: .Default, handler: { (action) -> Void in
                        })
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                
            case .Failure(let error):
                
                self.messageLabel.hidden = self.timesheetWeek.timesheets?.count > 0 ? true : false
                
                print("Request failed with error: \(error)")
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Session Expired. Please Login again"
                }
                let alertController = UIAlertController(title: NSLocalizedString("errorOccured", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title:NSLocalizedString("okActionTitle", comment: ""), style: .Default, handler: { (action) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func downloadTasks(date: String?) {
        
        if(refreshControl.refreshing == false){
            //          EZLoadingActivity.show("Loading", disableUI: true)
            LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
        }
        
        self.request = Alamofire.request(Router.GetTSTasks(date: date)).responseJSON { response in
            //          EZLoadingActivity.hide()
            LoadingController.instance.hideLoadingView()
            
            self.refreshControl.endRefreshing()
            switch response.result {
            case .Success(let JSON):
                
                guard let jsonData = JSON as? NSDictionary else {
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                
                let status = jsonData[kServerKeyStatus]
                
                if status?.lowercaseString == kServerKeySuccess {
                    
                    guard let dataDict = jsonData.valueForKey("data") as? [NSDictionary] else{
                        print("couldn't get the data dictionary")
                        return
                    }
                    
                    if let taskArray = dataDict as NSArray? {
                        var tasks = [TSTask]()
                        for taskDict in taskArray as! [NSDictionary] {
                            if let task = Parser.TSTaskFromDict(taskDict) {
                                tasks.append(task)
                            }
                        }
                        self.allTasks = tasks
                    }
                    self.downloadWeekTimesheet(date)
                    
                    if self.refreshControl.refreshing
                    {
                        self.refreshControl.endRefreshing()
                        self.tableView.reloadData()
                    }
                    else {
                        self.tableView.reloadData()
                        
                    }
                    //                    EZLoadingActivity.hide()
                    LoadingController.instance.hideLoadingView()
                    
                    self.isLoading = false
                }
                    
                else if status?.lowercaseString == kServerKeyFailure {
                    var message = jsonData[kServerKeyMessage]?.lowercaseString
                    
                    let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    
                    if let senderController =   getTopViewController(){
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                    print("Get tasks Request failed with error")
                }
                
            case .Failure(let error):
                var message = error.localizedDescription
                
                let alertController = UIAlertController(title: NSLocalizedString("errorOccured", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title:NSLocalizedString("okActionTitle", comment: ""), style: .Default, handler: { (action) -> Void in
                })
                alertController.addAction(okAction)
                
                if let senderController =   getTopViewController(){
                    senderController.presentViewController(alertController, animated: true, completion: nil)
                }
                print("Get tasks Request failed with error: \(error)")
            }
        }
    }
    
    
    //MARK: - Set up navigation bar
    func setupNavigationBar() {
        self.navigationController?.setupNavigationBar()
        
    }
    
    func showSideMenu( sender : UIBarButtonItem) {
        if let menuView =  self.navigationItem.titleView as? BTNavigationDropdownMenu{
            menuView.animationDuration = 0
            menuView.hide()
        }
        sideMenuController = UIStoryboard.TimeSheet().instantiateViewControllerWithIdentifier(String(SideMenuController)) as? SideMenuController
        sideMenuController?.items[0] = ["Approvals"]
        //        sideMenuController?.delegate = self
        sideMenuController?.dismissControllerHandler = {() -> Void in
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        
        sideMenuController?.modalPresentationStyle = .OverCurrentContext
        presentViewController(sideMenuController!, animated: false, completion: nil)
    }
    
    func resetButtonPressed(){
        print("resetButtonPressed")
        
        let alertController = UIAlertController.init(title: NSLocalizedString("confirmResetAlertControllerTitle", comment: ""), message:NSLocalizedString("confirmResetMessage", comment: "") , preferredStyle: UIAlertControllerStyle.Alert)
        
        let resetAction = UIAlertAction(title:NSLocalizedString("resetActionTitle", comment: ""), style: .Default, handler: { (action) -> Void in
            self.resetAll()
        })
        
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(resetAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func infoButtonPressed() {
        let timesheetInfoController = UIStoryboard.TimeSheet().instantiateViewControllerWithIdentifier(String(TSInfoController)) as! TSInfoController
        let nc = UINavigationController.init(rootViewController: timesheetInfoController)
        
        presentViewController(nc, animated: true, completion: nil)
    }
    func resetAll(){
        
        if let timesheets = timesheetWeek.timesheets{
            for timesheet in timesheets{
                if let projects = timesheet.projects{
                    for project in projects{
                        if let tasks = project.tasks{
                            for task in tasks {
                                task.submittedHours = "0"
                            }
                        }
                        project.submittedHours = "0"
                    }
                }
                timesheet.submittedHours = "0"
            }
        }
        timesheetWeek.submittedHours = "0"
        updateClockedHours()
        
        tableView.reloadData()
    }
    
    
    //MARK: - Copy from previous week functions
    
    func copyFromPreviousWeekButtonPressed( sender: UIBarButtonItem) {
        
        if let timesheet = timesheetWeek.timesheets {
            if timesheet.count > 0 {
                
                if let menuView =  self.navigationItem.titleView as? BTNavigationDropdownMenu{
                    menuView.animationDuration = 0
                    menuView.hide()
                }
                let alertController = UIAlertController(title: NSLocalizedString("copyFromPreviousWeekAlertControllerTitle", comment: ""), message: NSLocalizedString("copyFromPreviousWeekAlertControllerMessage", comment: "") , preferredStyle: .Alert)
                
                
                let copyAction = UIAlertAction(title: NSLocalizedString("copyActionTitle", comment: ""), style: .Default) { (action) -> Void in
                    self.copyFromPreviousWeek()
                }
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .Cancel) { (action) -> Void in
                    
                }
                alertController.addAction(copyAction)
                alertController.addAction(cancelAction)
                
                presentViewController(alertController, animated: true, completion: nil)
            }
        }
            
        else {
            let alertController = UIAlertController.init(title: kEmptyString, message: NSLocalizedString("noTimesheetsToCopy", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    
    func copyFromPreviousWeek() {
        
        var timesheetForPreviousWeek  = TimesheetWeek()
        let startDate = self.currentSelectedDate.startDate
        let endDate = self.currentSelectedDate.endDate
        let daysToSubtract : NSTimeInterval = -7
        let previousWeekStartDate = startDate!.dateByAddingTimeInterval(60 * 60 * 24 * daysToSubtract)
        let previousWeekEndDate = endDate!.dateByAddingTimeInterval(60 * 60 * 24 * daysToSubtract)
        self.startEndDateForPreviousWeek.startDate = previousWeekStartDate
        self.startEndDateForPreviousWeek.endDate = previousWeekEndDate
        let previousWeekStartDateInString = Helper.stringForDate(previousWeekStartDate, format: "ddMMyyyy")
        
        //        EZLoadingActivity.show("Loading", disableUI: true)
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
        
        
        Alamofire.request(Router.GetTimesheetForWeek(date: previousWeekStartDateInString)).responseJSON { response in
            //            EZLoadingActivity.hide()
            LoadingController.instance.hideLoadingView()
            
            
            switch response.result {
            case .Success(let JSON):
                if let jsonData = JSON as? NSDictionary  {
                    
                    let status = jsonData[kServerKeyStatus]
                    if status?.lowercaseString == kServerKeySuccess {
                        if  let dataDict = jsonData.valueForKey("data") as? NSDictionary  {
                            var dateArrayOfUncopiedTimesheets = [String]()
                            
                            if let timesheetWeekParsed = Parser.timesheetWeekFromDict(dataDict) {
                                timesheetForPreviousWeek = timesheetWeekParsed
                                self.formatUIForOutlets()
                                //                    EZLoadingActivity.hide()
                                LoadingController.instance.hideLoadingView()
                                
                                
                                var timesheetWeekSubmittedHours: Float = 0
                                if let sourceTimesheets = timesheetForPreviousWeek.timesheets {
                                    for sourceTimesheet in sourceTimesheets {
                                        
                                        if self.getTimeInHours(timesheetForPreviousWeek.submittedHours) <= 0 {
                                            
                                            let alertController = UIAlertController.init(title: kEmptyString, message: NSLocalizedString("noTaskEnterForPreviousWeek", comment: ""), preferredStyle: .Alert)
                                            let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: .Cancel, handler:nil)
                                            alertController.addAction(okAction)
                                            self.presentViewController(alertController, animated: true, completion: nil)
                                            return
                                        }
                                        
                                        let sourceDate = Helper.stringForDate(sourceTimesheet.date, format: "EEEE")
                                        
                                        
                                        if let destinationTimesheets = self.timesheetWeek.timesheets {
                                            for destinationTimesheet in destinationTimesheets {
                                                
                                                var isLeave = false
                                                if let nonWorkingDayType = destinationTimesheet.nonWorkingDayType {
                                                    if nonWorkingDayType == "leave" {
                                                        dateArrayOfUncopiedTimesheets.append(sourceDate)
                                                        
                                                        isLeave = true
                                                    }
                                                }
                                                
                                                if !isLeave {
                                                    
                                                    if Helper.stringForDate(destinationTimesheet.date, format: "EEEE") == sourceDate {
                                                        
                                                        var projectSubmittedHours : Float = 0
                                                        sourceTimesheet.projects = self.organiseProjects(sourceTimesheet.projects!)
                                                        if let sourceProjects = sourceTimesheet.projects {
                                                            for sourceProject in sourceProjects {
                                                                var theDestProject : TSProject?
                                                                if let destProjects = destinationTimesheet.projects {
                                                                    for aDestProject in destProjects {
                                                                        if sourceProject.name == aDestProject.name {
                                                                            theDestProject = aDestProject
                                                                            break
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                if theDestProject==nil {
                                                                    dateArrayOfUncopiedTimesheets.append(sourceDate)
                                                                }
                                                                
                                                                if theDestProject != nil && theDestProject?.status != TSStatus.Approved && theDestProject?.status != TSStatus.Submitted {
                                                                    var taskSubmittedHours : Float = 0
                                                                    if let sourceTasks = sourceProject.tasks {
                                                                        theDestProject?.tasks?.removeAll()
                                                                        for sourceTask in sourceTasks {
                                                                            
                                                                            //                                                                            var theDestTask : TSTask?
                                                                            //                                                                            if let destTasks = theDestProject?.tasks {
                                                                            //
                                                                            //                                                                                for dTask in destTasks {
                                                                            //                                                                                    if sourceTask.name == dTask.name {
                                                                            //                                                                                        theDestTask = dTask
                                                                            //                                                                                        break
                                                                            //                                                                                    }
                                                                            //                                                                                }
                                                                            //                                                                            }
                                                                            
                                                                            //                                                                            if(theDestTask != nil) {
                                                                            //
                                                                            //                                                                                if let theTaskSubmittedHours = sourceTask.submittedHours {
                                                                            //                                                                                    if let taskSubmittedHoursInFloat = Float(theTaskSubmittedHours) {
                                                                            //                                                                                        if taskSubmittedHoursInFloat > 0 {
                                                                            //                                                                                            theDestTask?.submittedHours = sourceTask.submittedHours
                                                                            //
                                                                            ////                                                                                        }
                                                                            ////                                                                                    }
                                                                            ////                                                                                }
                                                                            ////
                                                                            ////
                                                                            ////                                                                            }
                                                                            ////                                                                            else{
                                                                            let newTaskToReplace = TSTask()
                                                                            newTaskToReplace.id = sourceTask.id
                                                                            newTaskToReplace.name = sourceTask.name
                                                                            newTaskToReplace.project = sourceTask.project
                                                                            newTaskToReplace.submittedHours = sourceTask.submittedHours
                                                                            //
                                                                            theDestProject?.tasks?.append(newTaskToReplace)
                                                                            //                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                    if let unwrappedTasks = theDestProject?.tasks{
                                                                        for i in 0..<unwrappedTasks.count{
                                                                            taskSubmittedHours += Float(unwrappedTasks[i].submittedHours ?? "0.0")!
                                                                        }
                                                                    }
                                                                    theDestProject?.submittedHours = String(taskSubmittedHours)
                                                                    
                                                                }
                                                            }
                                                        }
                                                        
                                                        if let unwrappedProjects = destinationTimesheet.projects {
                                                            for i in 0..<unwrappedProjects.count {
                                                                projectSubmittedHours += Float(unwrappedProjects[i].submittedHours ?? "0.0")!
                                                            }
                                                        }
                                                        destinationTimesheet.submittedHours = String(projectSubmittedHours)
                                                        self.timesheetWeek.timesheets = destinationTimesheets
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                                if let unwrappedTimesheets = self.timesheetWeek.timesheets{
                                    for i in 0..<unwrappedTimesheets.count{
                                        timesheetWeekSubmittedHours += Float(unwrappedTimesheets[i].submittedHours ?? "0.0")!
                                    }
                                }
                                self.timesheetWeek.submittedHours = String(timesheetWeekSubmittedHours)
                                self.updateClockedHours()
                                self.tableView.reloadData()
                                
                            }
                            if dateArrayOfUncopiedTimesheets.isEmpty == false {
                                var dayString = String()
                                dayString = dateArrayOfUncopiedTimesheets.joinWithSeparator(", ")
                                let alertController = UIAlertController.init(title: kEmptyString, message: NSLocalizedString("Timesheets couldn't be copied for days \(dayString) due to leave/unallocated projects", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                                alertController.addAction(okAction)
                                self.presentViewController(alertController, animated: true, completion: nil)
                                
                                
                            }
                            
                        }
                        
                        
                        
                        
                        
                        
                        
                    }
                        
                    else if status?.lowercaseString == kServerKeyFailure {
                        var message = jsonData[kServerKeyMessage] as? String
                        if response.response?.statusCode == ErrorCode.Forbidden.rawValue {
                            message = "Session Expired"
                        }
                        else if message == nil {
                            message = "An error occured"
                        }
                        
                        let alertController = UIAlertController.init(title: kEmptyString, message: NSLocalizedString(message ?? "", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                
                self.messageLabel.hidden = self.timesheetWeek.timesheets?.count > 0 ? true : false
                
            case .Failure(let error):
                
                self.messageLabel.hidden = self.timesheetWeek.timesheets?.count > 0 ? true : false
                
                print("Request failed with error: \(error)")
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Session Expired"
                    NSLog(message)
                }
                let alertController = UIAlertController.init(title: kEmptyString, message: NSLocalizedString(message ?? "", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    
    //MARK: - Setting up the various outlets to the VD
    func formatUIForOutlets() {
        
        if currentTimesheetStatus == TSStatus.Approved || currentTimesheetStatus == TSStatus.Submitted {
            copyLastWeekButton.enabled = false
            resetButton.enabled = false
        }
        else {
            copyLastWeekButton.enabled = true
            resetButton.enabled = true
        }
        
        updateClockedHours()
        clockedHours.sizeToFit()
        clockedHours.backgroundColor = UIColor.init(white: 1.0, alpha: 0.2)
        clockedHours.layer.cornerRadius = 5
        clockedHours.clipsToBounds = true
        
        //        Helper.setBorderForButtons(saveButton,color: ConstantColor.CWBlue)
        //        Helper.setBorderForButtons(submitButton,color: ConstantColor.CWBlue)
        
        
        buttonsView.backgroundColor = UIColor.init(white: 0.95, alpha: 0.9)
        let upperBorder = CALayer()
        upperBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        upperBorder.frame = CGRectMake(0, 0, CGRectGetWidth(buttonsView.frame), 1.0)
        buttonsView.layer.addSublayer(upperBorder)
        
        statusLabel?.removeFromSuperview()
        statusLabel = nil
        buttonsView.hidden = true
        let buttonViewHeightInitialValue = buttonsView.frame.size.height
        buttonsView.frame.size.height = 0
        
        var contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        var showStatusLabel = false
        
        if currentTimesheetStatus == TSStatus.Rejected || currentTimesheetStatus == TSStatus.Submitted || currentTimesheetStatus == TSStatus.Approved
            //            || currentTimesheetStatus == TSStatus.Saved
        {
            showStatusLabel = true
        }
        
        if showStatusLabel {
            if  statusLabel == nil {
                clockedHoursView.frame.size.height = kclockedHoursViewHeight + 30
                statusLabel = UILabel(frame: CGRect(x: 0, y: clockedHoursView.frame.size.height - 30, width: view.frame.size.width, height: 30))
                statusLabel?.font = UIFont.boldSystemFontOfSize(12)
                statusLabel?.textAlignment = .Center
                clockedHoursView.addSubview(statusLabel!)
            }
            
            if let status: TSStatus = currentTimesheetStatus {
                
                statusLabel?.text = String(status).uppercaseString
                
                statusLabel?.backgroundColor = Helper.getColor(status)
            }
            
            statusLabel?.textColor = UIColor(red: 31/255.0, green: 112/255.0, blue: 81/255.0, alpha: 1.0)
            
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, buttonsView.frame.size.height, 0.0)
            
            if currentTimesheetStatus == TSStatus.Rejected ||  currentTimesheetStatus == TSStatus.Saved {
                buttonsView.hidden = false
                buttonsView.frame.size.height = buttonViewHeightInitialValue
                setSaveButtonEnabled(Parser.isElementEnabled(forType: CardType.TimesheetType, forSubtype: CardSubtype.HomeType, optionalFieldString: "save"))
                
                contentInsets = UIEdgeInsetsMake(0.0, 0.0, buttonsView.frame.size.height, 0.0)
                
            }
        }
        else
        {
            clockedHoursView.frame.size.height = kclockedHoursViewHeight
            buttonsView.hidden = false
            buttonsView.frame.size.height = buttonViewHeightInitialValue
            setSaveButtonEnabled(Parser.isElementEnabled(forType: CardType.TimesheetType, forSubtype: CardSubtype.HomeType, optionalFieldString: "save"))
            
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, buttonsView.frame.size.height, 0.0)
        }
        
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
        
        
    }
    
    //MARK: - Service call for filter dropdown
    func downloadFilterDropDown() {
        
        //        EZLoadingActivity.show("Loading", disableUI: true)
        Alamofire.request(Router.FilterForTimesheetWeek()).responseJSON { response in
            
            switch response.result {
            case .Success(let JSON):
                
                if let jsonData = JSON as? NSDictionary  {
                    print("Incorrect JSON from server : \(JSON)")
                    
                    let status = jsonData[kServerKeyStatus]
                    
                    if status?.lowercaseString == kServerKeySuccess {
                        
                        
                        if let dataDict = jsonData.valueForKey("data") as? [NSDictionary]  {
                            
                            
                            //                EZLoadingActivity.hide()
                            var filterArray = [TSWeekFromTo]()
                            if let dataArray = dataDict as NSArray? {
                                
                                for data in dataArray as! [NSDictionary] {
                                    if let date = Parser.weekFromToDict(data) {
                                        filterArray.append(date)
                                    }
                                }
                            }
                            self.filterDropDownArray = filterArray
                            
                            if self.fromNotif == true {
                                for filter in self.filterDropDownArray {
                                    if self.date == Helper.stringForDate(filter.startDate, format: "ddMMyyyy") {
                                        
                                        self.updateFilterDropDown()
                                    }
                                }
                                
                                
                            }
                            else {
                                self.updateFilterDropDown()
                                
                            }
                            
                            //                self.updateFilterDropDown()
                            
                            
                            //            else if status?.lowercaseString == kServerKeyFailure {
                            //                var message = jsonDict[kServerKeyMessage] as? String
                            //                if response.response?.statusCode == ErrorCode.Forbidden.rawValue {
                            //                    message = "Session Expired"
                            //                }
                            //                else if message == nil {
                            //                    message = "An error occured"
                            //                }
                            //            }
                        }
                    }
                        
                    else if status?.lowercaseString == kServerKeyFailure {
                        var message = jsonData[kServerKeyMessage] as? String
                        if response.response?.statusCode == ErrorCode.Forbidden.rawValue {
                            message = "Session Expired"
                        }
                        else if message == nil {
                            message = "An error occured"
                        }
                        
                        let alertController = UIAlertController.init(title: kEmptyString, message: NSLocalizedString(message ?? "", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                }
            case .Failure(let error):
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Session Expired"
                    NSLog(message)
                }
                let alertController = UIAlertController.init(title: kEmptyString, message: NSLocalizedString(message ?? "", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - Add the dropdown menu on the navigation bar
    func updateFilterDropDown() {
        
        let currentDateInDateFormat : NSDate?
        
        if date != nil {
            currentDateInDateFormat = Helper.dateForDDMMYYYYString(date)
        }
        else {
            currentDateInDateFormat = NSDate()
        }
        var currentWeekString = String()
        var indexPathForCurrentItem : Int = 0
        var selectedRow :Int!
        var newFilterItemsInString = [String]()
        let filterItems = filterDropDownArray
        
        for filter in filterItems {
            
            indexPathForCurrentItem += 1
            let startDate = filter.startDate
            let endDate = filter.endDate
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            dateFormatter.dateFormat = "dd MMM"
            let dateInString = "\(dateFormatter.stringFromDate(startDate!)) - \(dateFormatter.stringFromDate(endDate!))"
            newFilterItemsInString.append(dateInString)
            
            // To check if current falls within a week
            let daysToAdd : NSTimeInterval = 6
            let endDateForWeek = startDate!.dateByAddingTimeInterval(60 * 60 * 24 * daysToAdd)
            if let currentDate = currentDateInDateFormat {
                if (currentDate.compare(startDate!) != .OrderedAscending) &&  (currentDate.compare(endDateForWeek) != .OrderedDescending){
                    currentWeekString = "\(dateFormatter.stringFromDate(startDate!)) - \(dateFormatter.stringFromDate(endDate!))"
                    selectedRow = indexPathForCurrentItem - 1
                    
                    currentSelectedDate.startDate = startDate
                    currentSelectedDate.endDate = endDate
                }
            }
        }
        
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title:currentWeekString , items:  newFilterItemsInString)
        menuView.customizeDropDown()
        
        self.navigationItem.titleView = menuView
        
        menuView.currentSelectedRow = selectedRow
        menuView.cellTextLabelFont = UIFont.systemFontOfSize(12)
        menuView.didSelectItemAtIndexHandler = {
            (indexPath: Int) -> () in
            self.currentSelectedDate = self.filterDropDownArray[indexPath]
            
            ActionController.instance.downloadAndUpdateConfiguration()
            
            self.downloadWeekTimesheet(Helper.stringForDate(self.currentSelectedDate.startDate, format: "ddMMyyyy"))
            self.tableView.reloadData()
        }
        
    }
    
    
    func submitButtonPressed() {
        if messageLabel.hidden == false  {
            
            let alertController = UIAlertController.init(title: kEmptyString, message: NSLocalizedString("noTimesheetsToSubmit", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        else {
            
            var enteredHours:Float = 0
            for timesheet in timesheetWeek.timesheets! {
                //            if (timesheet.isWorkingDay == true) {
                if let projects = timesheet.projects {
                    for project in projects {
                        if let tasks = project.tasks {
                            for task in tasks {
                                if let hours = task.submittedHours {
                                    enteredHours += NSString(string: hours).floatValue
                                }
                            }
                        }
                    }
                    //            }
                }
            }
            
            var targetHours:Float = 0
            if let allocatedHours = timesheetWeek.allocatedHours {
                targetHours =  NSString(string: allocatedHours).floatValue
            }
            
            if enteredHours < targetHours {
                let hrsString:String = String(format: "%0.2f hrs", targetHours / 60)
                let alertController = UIAlertController.init(title: kEmptyString, message: NSLocalizedString("targetHours", comment: "") + " (\(hrsString))" + NSLocalizedString("notMet", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else {
                isSubmit = true
                submitTimesheet()
            }
            
        }
        
    }
    
    
    func saveButtonPressed() {
        if messageLabel.hidden == false  {
            
            let alertController = UIAlertController.init(title: kEmptyString, message: NSLocalizedString("noTimesheetsToSave", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
            
        else {
            submitTimesheet()
            isSubmit = false
            print("save button pressed")
        }
    }
    
    func setSaveButtonEnabled(isEnabled : Bool){
        
        if isEnabled{
            let saveButton = UIButton()
            saveButton.setTitle("SAVE", forState: .Normal)
            saveButton.addTarget(self, action: #selector(TSHomeController.saveButtonPressed), forControlEvents: .TouchUpInside)
            let submitButton = UIButton()
            submitButton.addTarget(self, action: #selector(TSHomeController.submitButtonPressed), forControlEvents: .TouchUpInside)
            
            if statusForWeekTimesheet() == TSStatus.Rejected {
                submitButton.setTitle("RE-SUBMIT", forState: .Normal)
            }
            else {
                submitButton.setTitle("SUBMIT", forState: .Normal)
            }
            
            let actionCopyDoneViewArray = [saveButton,submitButton]
            
            Helper.layoutButtons(true, actionView: buttonsView, actionViewHeightConstraint: actionSaveSubmitViewHeightContraint, actionViewInitialHeight: actionSaveSubmitViewHeightContraint.constant, viewArray: actionCopyDoneViewArray, maximumNumberOfButtonsToShow: nil)
            
            
        }
        else{
            
            let doneButton = UIButton()
            doneButton.setTitle("SUBMIT", forState: .Normal)
            doneButton.addTarget(self, action: #selector(TSHomeController.submitButtonPressed), forControlEvents: .TouchUpInside)
            
            let actionCopyDoneViewArray = [doneButton]
            
            Helper.layoutButtons(true, actionView: buttonsView, actionViewHeightConstraint: actionSaveSubmitViewHeightContraint, actionViewInitialHeight: actionSaveSubmitViewHeightContraint.constant, viewArray: actionCopyDoneViewArray, maximumNumberOfButtonsToShow: nil)
            
            
        }
    }
    
    func statusForWeekTimesheet() -> TSStatus? {
        var status:TSStatus? = nil
        
        // Status Priority: 1. Rejected !, 2. Saved !, 3. Submitted, 5. Prefilled 6. Approved 7. nil
        // Check for rejection and save
        if let timesheets = timesheetWeek.timesheets {
            for timesheet in timesheets {
                if let projects = timesheet.projects {
                    for project in projects {
                        
                        if project.status != nil && project.status != TSStatus.Prefilled {
                            status = project.status
                        }
                        
                        if status == TSStatus.Rejected || status == TSStatus.Saved {
                            break
                        }
                    }
                    
                    if status == TSStatus.Rejected || status == TSStatus.Saved {
                        break
                    }
                }
            }
        }
        
        // Check for submission
        if let timesheets = timesheetWeek.timesheets where (status != TSStatus.Rejected && status != TSStatus.Saved) {
            for timesheet in timesheets {
                if let projects = timesheet.projects {
                    for project in projects {
                        
                        if project.status != nil && project.status != TSStatus.Prefilled {
                            status = project.status
                        }
                        
                        if status == TSStatus.Submitted {
                            break
                        }
                    }
                    
                    if status == TSStatus.Submitted {
                        break
                    }
                }
            }
        }
        
        return status
    }
}

//MARK: - Extensions

extension TSHomeController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(String(TSHomeCell), forIndexPath: indexPath) as! TSHomeCell
        cell.delegate = self
        cell.getIndexPathForRow(indexPath.row)
        cell.tsStatus = currentTimesheetStatus
        
        if let timesheet = timesheetWeek.timesheets?[indexPath.row] {
            cell.updateCell(timesheet)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rowCount = timesheetWeek.timesheets?.count {
            return rowCount
        }
        return 0
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        if let timesheets = timesheetWeek.timesheets {
            if let nonWorkingDayType = timesheets[indexPath.row].nonWorkingDayType where nonWorkingDayType == "leave" {
                let alertController = UIAlertController.init(title: kEmptyString, message: NSLocalizedString("cannotAddTaskErrorMessage", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                return nil
            }
        }
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        openTSTaskSelectControllerForIndex(indexPath.row,projectIndex: 0)
        
        //        timesheetWeek = taskSelectController.timesheetWeek
    }
    
    func openTSTaskSelectControllerForIndex(dayIndex:Int,projectIndex:Int){
        let taskSelectController = UIStoryboard.TimeSheet().instantiateViewControllerWithIdentifier(String(TSTaskSelectController)) as! TSTaskSelectController
        taskSelectController.copyOverlayController = copyOverlayController
        taskSelectController.allTasks = allTasks
        taskSelectController.weekStatus = currentTimesheetStatus
        
        taskSelectController.selectedProjectIndex = projectIndex
        
        
        if var timesheets = timesheetWeek.timesheets{
            
            taskSelectController.timesheet = timesheets[dayIndex]
            taskSelectController.getDetailTaskIndex(dayIndex)
            
            taskSelectController.taskSelectCompletionHandler = {()-> Void in
                self.navigationController?.popViewControllerAnimated(true)
                
                self.timesheetWeek.timesheets![dayIndex] = taskSelectController.timesheet
                var sum:Float = 0
                
                if let updatedTimesheets = self.timesheetWeek.timesheets{
                    for timesheet in updatedTimesheets{
                        if let timesheetClockedInString = timesheet.submittedHours {
                            if let timesheetClockedInFloat = Float(timesheetClockedInString){
                                sum += timesheetClockedInFloat
                            }
                        }
                    }
                }
                self.timesheetWeek.submittedHours = String(sum)
                self.formatUIForOutlets()
                self.tableView.reloadData()
            }
            
            navigationController?.pushViewController(taskSelectController, animated: true)
            
            
        }
    }
    
    
    func getAllDaysForEntireWeek()->[String]{
        
        var daysArray = [String]()
        for timesheet in timesheetWeek.timesheets!{
            daysArray.append(Helper.stringForDate( timesheet.date, format: "EEEE"))
        }
        return daysArray
    }
}

//MARK: - Delegate method definition
extension TSHomeController : TSCopyOverlayControllerDelegate{
    
    func removeTaskController() {
        
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    func updateProjectsInTimesheet(updatedProjects: [TSProject], atIndex: Int) {
        self.timesheetWeek.timesheets![atIndex].projects = updatedProjects
        var sum:Float = 0
        
        if let updatedTimesheets = self.timesheetWeek.timesheets{
            for timesheet in updatedTimesheets{
                if let timesheetClockedInString = timesheet.submittedHours {
                    if let timesheetClockedInFloat = Float(timesheetClockedInString){
                        sum += timesheetClockedInFloat
                    }
                }
            }
        }
        self.timesheetWeek.submittedHours = String(sum)
    }
    
    
    
    func tasksToCopyFromIndexToIndices( fromIndex: Int, toIndices: [Int]) {
        var timesheetWeekSubmittedHours : Float = 0
        var hasAppliedLeave = false
        var hasUnallocatedProjects = false
        
        if let sourceTimesheet = timesheetWeek.timesheets?[fromIndex] {
            for index in 0..<toIndices.count {
                let TSIndex = toIndices[index]
                let destinationTimesheet = timesheetWeek.timesheets?[TSIndex]
                
                var isLeave = false
                if let nonWorkingDayType = destinationTimesheet?.nonWorkingDayType {
                    if nonWorkingDayType == "leave" {
                        hasAppliedLeave = true
                        isLeave = true
                    }
                }
                var projectSubmittedHours : Float = 0
                
                if !isLeave {
                    
                    if let sourceProjects = sourceTimesheet.projects {
                        for sourceProject in sourceProjects {
                            var theDestProject : TSProject?
                            
                            if let destProjects = destinationTimesheet?.projects {
                                
                                var hasProject = false
                                for aDestProject in destProjects {
                                    if sourceProject.name == aDestProject.name {
                                        theDestProject = aDestProject
                                        hasProject = true
                                        break
                                    }
                                }
                                
                                if !hasProject {
                                    hasUnallocatedProjects = true
                                }
                            }
                            
                            if theDestProject != nil && theDestProject?.status != TSStatus.Approved && theDestProject?.status != TSStatus.Submitted && getTimeInHours(sourceProject.submittedHours) > 0 {
                                var taskSubmittedHours : Float = 0
                                if let sourceTasks = sourceProject.tasks{
                                    theDestProject?.tasks?.removeAll()
                                    for sourceTask in sourceTasks{
                                        
                                        //                                    var theDestTask : TSTask?
                                        //                                    if let destTasks = theDestProject?.tasks {
                                        
                                        //                                        for dTask in destTasks {
                                        //                                            if sourceTask.name == dTask.name {
                                        //                                                theDestTask = dTask
                                        //                                                break
                                        //                                            }
                                        //
                                        //                                        }
                                        
                                        let newTaskToReplace = TSTask()
                                        newTaskToReplace.id = sourceTask.id
                                        newTaskToReplace.name = sourceTask.name
                                        newTaskToReplace.project = sourceTask.project
                                        newTaskToReplace.submittedHours = sourceTask.submittedHours
                                        theDestProject?.tasks?.append(newTaskToReplace)
                                        //                                    }
                                        
                                        //                                    if(theDestTask != nil) {
                                        //
                                        //                                        if let theTaskSubmittedHours = sourceTask.submittedHours {
                                        //                                            if let taskSubmittedHoursInFloat = Float(theTaskSubmittedHours) {
                                        //                                                if taskSubmittedHoursInFloat > 0 {
                                        //                                                   theDestTask?.submittedHours = sourceTask.submittedHours
                                        //
                                        //                                                  print("**",theDestTask?.submittedHours)
                                        //                                                }
                                        //                                            }
                                        //                                        }
                                        //                                    }
                                        //                                    else {
                                        //                                        let newTaskToReplace = TSTask()
                                        //                                        newTaskToReplace.id = sourceTask.id
                                        //                                        newTaskToReplace.name = sourceTask.name
                                        //                                        newTaskToReplace.project = sourceTask.project
                                        //                                        newTaskToReplace.submittedHours = sourceTask.submittedHours
                                        //                                        theDestProject?.tasks?.append(newTaskToReplace)
                                        //                                    }
                                    }
                                }
                                
                                if let unwrappedTasks = theDestProject?.tasks{
                                    for i in 0..<unwrappedTasks.count{
                                        taskSubmittedHours += Float(unwrappedTasks[i].submittedHours ?? "0.0")!
                                    }
                                }
                                theDestProject?.submittedHours = String(taskSubmittedHours)
                            }
                        }
                    }
                    
                    if let unwrappedProjects = destinationTimesheet?.projects {
                        for i in 0..<unwrappedProjects.count {
                            projectSubmittedHours += Float(unwrappedProjects[i].submittedHours ?? "0.0")!
                        }
                    }
                    destinationTimesheet?.submittedHours = String(projectSubmittedHours)
                    timesheetWeek.timesheets?[TSIndex] = destinationTimesheet!
                }
                destinationTimesheet?.submittedHours = String(projectSubmittedHours)
                timesheetWeek.timesheets?[TSIndex] = destinationTimesheet!
            }
        }
        if let unwrappedTimesheets = timesheetWeek.timesheets{
            for i in 0..<unwrappedTimesheets.count{
                timesheetWeekSubmittedHours += Float(unwrappedTimesheets[i].submittedHours ?? "0.0")!
            }
        }
        timesheetWeek.submittedHours = String(timesheetWeekSubmittedHours)
        
        updateClockedHours()
        tableView.reloadData()
        
        if hasAppliedLeave || hasUnallocatedProjects {
            let message = hasAppliedLeave ? "cannotCopyTaskErrorMessageDueToLeaveError" : "cannotCopyTaskErrorMessageDueToProjectAllocationError"
            let alertController = UIAlertController.init(title: kEmptyString, message: NSLocalizedString(message ?? "", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func updateClockedHours() {
        if let hours = self.timesheetWeek.submittedHours as String! {
            if let timeInFloat = Float(hours){
                let  h = Int(timeInFloat / 60)
                let m = Int(timeInFloat % 60)
                if m > 0 {
                    self.clockedHours.text = " " + String(h) + " hrs " + String(m) + " mins clocked \u{200c}"
                }
                else{
                    self.clockedHours.text = " " + String(h) + " hrs clocked \u{200c}"
                }
            }
        }
    }
    
    func submitTimesheet(){
        
        let timesheetDictionaryToSave = createTimesheetWeekDict()
        
        //                EZLoadingActivity.show("Loading", disableUI: true)
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
        
        let isSave = (isSubmit == true) ? false : true
        Alamofire.request(Router.SubmitTS( timesheetDict: timesheetDictionaryToSave, isSave: isSave)).responseJSON { response in
            //                    EZLoadingActivity.hide()
            LoadingController.instance.hideLoadingView()
            
            switch response.result {
                
            case .Success(let JSON):
                if let jsonDict = JSON as? NSDictionary {
                    print("Resopnse JSONDICTIONARY============\(jsonDict)")
                    
                    let status = jsonDict[kServerKeyStatus]
                    
                    if status?.lowercaseString == kServerKeySuccess {
                        if let _ = jsonDict[kServerKeyData] as? NSDictionary {
                            
                        }
                        if self.isSubmit == true{
                            //submit
                            let banner = Banner(title: "Notification", subtitle: "Timesheet Submitted", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                            banner.dismissesOnTap = true
                            banner.show(duration: 3.0)
                        }
                        else{//save
                            let banner = Banner(title: "Notification", subtitle: "Timesheet Saved", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                            banner.dismissesOnTap = true
                            banner.show(duration: 3.0)
                        }
                        self.downloadWeekTimesheet(Helper.stringForDate(self.currentSelectedDate.startDate, format: "ddMMyyyy"))
                    }
                    else if status?.lowercaseString == kServerKeyFailure {
                        var message = jsonDict[kServerKeyMessage] as? String
                        if response.response?.statusCode == ErrorCode.Forbidden.rawValue {
                            message = "sessionExpired"
                        }
                        else if message == nil {
                            message = "errorOccured"
                        }
                        
                        let alertController = UIAlertController.init(title: kEmptyString, message: NSLocalizedString(message ?? "", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                
                self.messageLabel.hidden = self.timesheetWeek.timesheets?.count > 0 ? true : false
                self.formatUIForOutlets()
                
            case .Failure(let error):
                
                self.messageLabel.hidden = self.timesheetWeek.timesheets?.count > 0 ? true : false
                
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
    
    func createTimesheetWeekDict()->Dictionary<String,AnyObject>{
        
        var timesheetWeekDictionary = Dictionary<String,AnyObject>()
        
        
        //        timesheetWeekDictionary["_id"] = timesheetWeek.id
        
        timesheetWeekDictionary["submittedHours"] = getTimeInHours(timesheetWeek.submittedHours)
        //      timesheetWeekDictionary["allocatedHours"] = getTimeInHours(timesheetWeek.allocatedHours)
        timesheetWeekDictionary["startDate"] = Helper.stringForDate(timesheetWeek.startDate, format: "ddMMYYYY")
        timesheetWeekDictionary["endDate"]  = Helper.stringForDate(timesheetWeek.endDate, format: "ddMMYYYY")
        timesheetWeekDictionary["overallStatus"] = timesheetWeek.status?.rawValue.lowercaseString
        
        //        var userDictObject = Dictionary<String,AnyObject>()
        
        //            if let user = timesheetWeek.submittedBy{
        //                userDictObject["_id"] = user.id
        //                userDictObject["displayName"] = user.displayName
        //                userDictObject["avatar"] = user.avatarURL
        //            }
        //        timesheetWeekDictionary["user"] = userDictObject
        
        
        let timesheetDictArray = NSMutableArray()
        if let timesheets = timesheetWeek.timesheets{
            for timesheet in timesheets{
                
                
                let timesheetDict = NSMutableDictionary()
                timesheetDict["date"] = Helper.stringForDate(timesheet.date , format: "ddMMYYYY")
                timesheetDict["status"] = timesheet.status?.rawValue.lowercaseString
                
                let timesheetSubmittedHoursInFloat = getTimeInHours(timesheet.submittedHours)
                timesheetDict["submittedHours"] = timesheetSubmittedHoursInFloat
                if timesheetSubmittedHoursInFloat > 0{
                    timesheetDict["allocatedHours"] = getTimeInHours(timesheet.allocatedHours)
                    
                    //                var workingDayStatusDict = Dictionary<String,AnyObject>()
                    //                workingDayStatusDict["isWorkingDay"] = timesheet.isWorkingDay
                    //                workingDayStatusDicx`t["nonWorkingDayType"] = timesheet.nonWorkingDayType
                    //                timesheetDict["workingDayStatus"] = workingDayStatusDict
                    
                    let projectDictArray = NSMutableArray()
                    if let projects = timesheet.projects{
                        
                        for project in projects{
                            var projectDict = Dictionary<String,AnyObject>()
                            
                            var projectDictObject = Dictionary<String,AnyObject>()
                            projectDictObject["_id"] = project.id
                            projectDictObject["name"] = project.name
                            
                            projectDict["status"] = project.status?.rawValue.lowercaseString
                            projectDict["project"] = projectDictObject
                            
                            let submittedHoursInFloatForProject = getTimeInHours(project.submittedHours)
                            projectDict["submittedHours"] = submittedHoursInFloatForProject
                            //                        projectDict["allocatedHours"] = getTimeInHours(project.allocatedHours)
                            
                            if submittedHoursInFloatForProject > 0{
                                
                                let taskDictArray = NSMutableArray()
                                if let tasks = project.tasks{
                                    for task in tasks{
                                        let submittedHoursInFloat = getTimeInHours(task.submittedHours)
                                        if submittedHoursInFloat > 0{
                                            var taskDict = Dictionary<String,AnyObject>()
                                            
                                            var taskDictObject = Dictionary<String,AnyObject>()
                                            taskDictObject["_id"] = task.id
                                            taskDictObject["name"] = task.name
                                            taskDict["task"] = taskDictObject
                                            
                                            taskDict["submittedHours"] = getTimeInHours(task.submittedHours)
                                            taskDictArray.addObject(taskDict)
                                        }
                                    }
                                    projectDict["tasks"] = taskDictArray
                                }
                                projectDictArray.addObject(projectDict)
                            }
                        }
                        timesheetDict["projects"] = projectDictArray
                        
                    }
                    timesheetDictArray.addObject(timesheetDict)
                }
            }
            timesheetWeekDictionary["days"] = timesheetDictArray
        }
        return timesheetWeekDictionary
    }
    
    func getTimeInHours(timeInMinutes:String?)->Float{
        
        if let hours = timeInMinutes as String!{
            if let timeInFloat = Float(hours){
                return Float(timeInFloat/60.0) 
            }
        }
        return 0
    }
}


//extension TSHomeController : TSLeftMenuDelegate {
//    func itemSelectedAtIndex(index: Int) {
//        self.navigationController?.navigationBar.alpha = 1.0
//        self.navigationController?.navigationBar.userInteractionEnabled = true
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        
//        let approveController = UIStoryboard.Approvals().instantiateViewControllerWithIdentifier(String(TSApprovalController)) as! TSApprovalController
//        
//        let nc = UINavigationController.init(rootViewController: approveController)
//        self.dismissViewControllerAnimated(false, completion: nil)
//
//        presentViewController(nc, animated: false, completion: nil)
//    }
//}
