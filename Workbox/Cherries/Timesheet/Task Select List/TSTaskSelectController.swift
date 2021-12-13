//
//  TSTaskSelectController.swift
//  Workbox
//
//  Created by Pavan Gopal on 17/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu
import Alamofire

protocol TSTaskSelectCotrollerDelegate {
    
    func getUpdatedTimesheet(updatedProjectArray: [TSProject], atIndex: Int, fromController : TSTaskSelectController)
}


class TSTaskSelectController: UIViewController {

        //MARK:- Outlets and variables
    
    var taskSelectCompletionHandler:(() -> Void)!

    @IBOutlet weak var headerBackgroundView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var clockedHoursLabel: UILabel!
    @IBOutlet weak var selectedMonthLabel: UILabel!
    @IBOutlet weak var selectedDayLabel: UILabel!
    @IBOutlet weak var allocatedHoursLabel: UILabel!
    @IBOutlet weak var tableViewHeaderView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var actionCopyDoneViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var hoursAllocatedHeaderLabel: UILabel!
    @IBOutlet weak var hoursClockedHeaderLabel: UILabel!
    
    @IBOutlet weak var actionCopyDoneView: UIView!
    @IBOutlet weak var actionDoneView: UIView!
    
    var timesheet = Timesheet()
    var allTasks: [TSTask]?
    var days : [String]?
    var messageLabel = UILabel()
    var allProjectsCopy = [TSProject]()
    var copyToDaysArray:[Int]?
    var filteredTasks = [TSTask]()
    var selectedProjectIndex: Int = 0
    var timePicker = UIPickerView()
    var indexSelected = NSIndexPath()
    var searchState : Bool?
    var sum:Double? = 0.0
    var isCalledFromHeader = false
    var canScroll = true
    let kTimePickerHeight:CGFloat = 160
    let kTimePickerBackgroundView:CGFloat = 200
    let kToolBarViewHeight:CGFloat = 40
    let kMinutesForHour = 60
    var  pickerViewBackgroundView  = UIView()
    var isDonePressed = false
    var weekStatus: TSStatus? = nil
//    var timesheetWeek = TimesheetWeek()
    var indexValue : Int?
    var copyOverlayController : TSCopyOverlayController?
    var delegate : TSTaskSelectCotrollerDelegate?
    var kAllowedClockedHours = 1440
    
        //MARK:- View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setUptimePicker()
        makeMessageLabel()
        
        createProjectsCopy()
        createFilterDropDown()
        updateHeaderView()
        
        
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        tableView.reloadData()
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        

        print("ProfileViewController presentingViewController = \(self.presentingViewController)")
        
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
     
        setCopyButtonEnabled(Parser.isElementEnabled(forType: CardType.TimesheetType, forSubtype: CardSubtype.AddTaskType, optionalFieldString: "copyDetail"))

    }
    
    func makeMessageLabel(){
        
        messageLabel = UILabel(frame: CGRectMake(0,self.view.frame.height/2 - 20,self.view.frame.width, 40))
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.textColor = UIColor.grayColor()
        messageLabel.font = UIFont.boldSystemFontOfSize(18)
        messageLabel.text = "No Tasks"
        self.view.addSubview(messageLabel)
        messageLabel.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        
        if parent == nil {
            // Back btn Event handler
            if let menuView = self.navigationItem.titleView as? BTNavigationDropdownMenu {
                menuView.hide()
            }
        }
    }
        //MARK:- Picker Helper Functions
    
    func setUptimePicker() {
        
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.navBarColor().CGColor
        searchBar.barTintColor = UIColor.navBarColor()
        
        pickerViewBackgroundView = UIView(frame:CGRectMake(0, self.view.frame.size.height - kTimePickerBackgroundView, self.view.frame.size.width, kTimePickerBackgroundView))
        
        pickerViewBackgroundView.hidden = true
        timePicker.dataSource = self
        timePicker.delegate = self
        timePicker.frame = CGRectMake(0, kToolBarViewHeight, self.view.frame.size.width, kTimePickerHeight)
        timePicker.backgroundColor = UIColor.whiteColor()
        timePicker.showsSelectionIndicator = true
        
        let toolBarView = UIView(frame: CGRectMake(0,0,self.view.frame.size.width,kToolBarViewHeight))
        toolBarView.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
        let cancelPickerButton = UIButton(frame: CGRectMake(8,0,100,40))
        cancelPickerButton.setTitle("Cancel", forState: .Normal)
        cancelPickerButton.tintColor = UIColor.navBarColor()
        cancelPickerButton.setTitleColor(UIColor.navBarColor(), forState: .Normal)
        
        cancelPickerButton.addTarget(self, action: #selector(TSTaskSelectController.cancelPickerButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        let donePickerButton = UIButton(frame: CGRectMake(toolBarView.frame.width - 108,0,100,40))
        donePickerButton.setTitle("Done", forState: .Normal)
        donePickerButton.setTitleColor(UIColor.navBarColor(), forState: .Normal)
        donePickerButton.tintColor = UIColor.navBarColor()
        donePickerButton.addTarget(self, action: #selector(TSTaskSelectController.donePickerButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        
        toolBarView.addSubview(donePickerButton)
        toolBarView.addSubview(cancelPickerButton)
        pickerViewBackgroundView.addSubview(timePicker)
        pickerViewBackgroundView.addSubview(toolBarView)
        
        self.view.addSubview(pickerViewBackgroundView)
    }
    
    func createProjectsCopy() {
        
        if let projects = timesheet.projects {
            var projectsCopy = [TSProject]()
            
            for project in projects {
                let newProject = TSProject()
                newProject.name = project.name
                newProject.id = project.id
                newProject.submittedHours = project.submittedHours
                newProject.allocatedHours = project.allocatedHours
                newProject.status = project.status
                
                if let tasks = project.tasks {
                    var tasksCopy = [TSTask]()
                    
                    for task in tasks {
                        let newTask = TSTask()
                        newTask.id = task.id
                        newTask.name = task.name
                        newTask.submittedHours = task.submittedHours
                        
                        newTask.project = task.project
                        tasksCopy.append(newTask)
                    }
                    newProject.tasks = tasksCopy
                }
                projectsCopy.append(newProject)
            }
            allProjectsCopy = projectsCopy
        }
    }
    
    func donePickerButtonPressed() {
        pickerViewBackgroundView.hidden = true
        isDonePressed = true
        updateModel()
        updateHeaderView()
        tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: indexSelected.row, inSection: indexSelected.section)], withRowAnimation: .None)
        
        print("done")
    }
    
    func cancelPickerButtonPressed(){
       pickerViewBackgroundView.hidden = true
        isDonePressed = false
        print("cancel")
    }
    
    
    func timeClockedSplit(timeClockedInString:String) -> String{
        if let timeClockedInFloat =  Float(timeClockedInString) {
            if timeClockedInFloat > 0 {
                let  h = Int(timeClockedInFloat / 60)
                let m = Int(timeClockedInFloat % 60)
                if m == 5{
                    if isCalledFromHeader == true{
                        return (String(h) + ":0" + String(m))
                    }
                    else{
                        return (" " + String(h) + ":0" + String(m) + " h \u{200c}")
                    }
                }
                if isCalledFromHeader == true{
                    return (String(h) + ":" + String(m))
                }
                else{
                    return (" " + String(h) + ":" + String(m) + " h \u{200c}")
                }
            }
            else {
                return ""
            }
        }
        
        return ""
    }
    
 //MARK:- UIupdate Methods
    
    func updateHeaderView(){
        isCalledFromHeader = true
        updateAllocatedAndSubmittedHoursLabel()
        
        var sum:Float = 0
        var timesheetsubmittedHours:Float = 0
        if allProjectsCopy.count > 0 {
            for project in allProjectsCopy {
                sum = 0
                if let tasks = project.tasks {
                    for task in tasks{
                        if let timeClockedInString =  task.submittedHours {
                            if let timeInFloat = Float(timeClockedInString) {
                                sum += timeInFloat
                            }
                        }
                    }
                }
                project.submittedHours = String(sum)
                if let timeInString = project.submittedHours{
                    if let timeInFloat = Float(timeInString){
                         timesheetsubmittedHours += timeInFloat
                    }
                }
            }
            timesheet.submittedHours = String(timesheetsubmittedHours)
        }
        
        selectedMonthLabel.text =  Helper.stringForDate(timesheet.date, format: "d MMM")
        selectedDayLabel.text =  Helper.stringForDate(timesheet.date, format: "EEEE")
        
        //Timesheet Configuration
        
        setClockedHoursEnabled(Parser.isElementEnabled(forType: CardType.TimesheetType, forSubtype: CardSubtype.AddTaskType, optionalFieldString: "clockedHours"))
        setAllocatedHoursEnabled(Parser.isElementEnabled(forType: CardType.TimesheetType, forSubtype: CardSubtype.AddTaskType, optionalFieldString: "allocatedHours"))
//        setCopyButtonEnabled(Parser.isElementEnabled(forType: Cardtype.TimesheetType, forSubtype: CardSubtype.AddTaskType, optionalFieldString: "copyDetail"))

        
    }
    
    func updateAllocatedAndSubmittedHoursLabel() {
        if let allocatedHours = timesheet.projects![selectedProjectIndex].allocatedHours where allocatedHours.characters.count > 0 {
            if let intTime = Float(allocatedHours) {
                allocatedHoursLabel.text = Helper.timeInHMformatForMinutes(Int(intTime))
            }
            else {
                allocatedHoursLabel.text = Helper.timeInHMformatForMinutes(0)
            }
        }
        else {
            allocatedHoursLabel.text = Helper.timeInHMformatForMinutes(0)
        }
        
        if let clockedHours = allProjectsCopy[selectedProjectIndex].submittedHours where clockedHours.characters.count > 0 {
            if let intTime = Float(clockedHours) {
                clockedHoursLabel.text = Helper.timeInHMformatForMinutes(Int(intTime))
            }
            else {
                clockedHoursLabel.text = Helper.timeInHMformatForMinutes(0)
            }
        }
        else {
            clockedHoursLabel.text = Helper.timeInHMformatForMinutes(0)
        }
    }
    
    
   func setClockedHoursEnabled(isEnabled : Bool){
    clockedHoursLabel.hidden = !isEnabled
    hoursClockedHeaderLabel.hidden = !isEnabled
    
    }
    func setAllocatedHoursEnabled(isEnabled : Bool){
        allocatedHoursLabel.hidden = !isEnabled
        hoursAllocatedHeaderLabel.hidden = !isEnabled
    }
    
    func setCopyButtonEnabled( isEnabled : Bool){
        if isEnabled{
            let copyButton = UIButton()
            copyButton.setTitle("COPY", forState: .Normal)
            copyButton.addTarget(self, action: #selector(TSTaskSelectController.copyButtonPressed), forControlEvents: .TouchUpInside)
            let doneButton = UIButton()
            doneButton.addTarget(self, action: #selector(TSTaskSelectController.doneButtonPressed), forControlEvents: .TouchUpInside)
            
            doneButton.setTitle("DONE", forState: .Normal)
            
            if weekStatus == TSStatus.Approved || weekStatus == TSStatus.Submitted {
                copyButton.enabled = false
                copyButton.alpha = 0.6
            }
            else {
                copyButton.enabled = true
                copyButton.alpha = 1.0
            }
            
            let actionCopyDoneViewArray = [copyButton,doneButton]
            
            Helper.layoutButtons(true, actionView: actionCopyDoneView, actionViewHeightConstraint: actionCopyDoneViewHeightContraint, actionViewInitialHeight: actionCopyDoneViewHeightContraint.constant, viewArray: actionCopyDoneViewArray, maximumNumberOfButtonsToShow: nil)
        }
        else{
            let doneButton = UIButton()
            doneButton.setTitle("DONE", forState: .Normal)
            doneButton.addTarget(self, action: #selector(TSTaskSelectController.doneButtonPressed), forControlEvents: .TouchUpInside)

            
            let actionCopyDoneViewArray = [doneButton]
            
            Helper.layoutButtons(true, actionView: actionCopyDoneView, actionViewHeightConstraint: actionCopyDoneViewHeightContraint, actionViewInitialHeight: actionCopyDoneViewHeightContraint.constant, viewArray: actionCopyDoneViewArray, maximumNumberOfButtonsToShow: nil)

        }
    }
    
    func createTimesheets() {
        
        timesheet.allocatedHours = "8.3"
        timesheet.date = NSDate()
        
        var projects = [TSProject]()
        
        for j in 0  ..< 3  {
            let project = TSProject()
            project.name = "Project \(j)"
            project.allocatedHours = "40"
            var tasks = [TSTask]()
            
            for k in 0  ..< 50  {
                let task = TSTask()
                task.name = "Task \(k)"
                tasks.append(task)
            }
            project.tasks = tasks
            projects.append(project)
        }
        timesheet.projects = projects
    }
    
    func setupNavigationBar() {
        
        self.navigationController?.setupNavigationBar()
        tableViewHeaderView.backgroundColor = UIColor.navBarColor()
        headerBackgroundView.backgroundColor = UIColor.navBarColor()
    }
 
     func copyButtonPressed() {
        guard let unwrappedCopyOverlayController = copyOverlayController else {
            return
        }
        unwrappedCopyOverlayController.timesheetProjects = allProjectsCopy
        addViewController(unwrappedCopyOverlayController)
        unwrappedCopyOverlayController.copyButtonForIndexPressed(indexValue!)
    }
    
     func doneButtonPressed() {
        timesheet.projects = allProjectsCopy
       
        if taskSelectCompletionHandler != nil{
            self.taskSelectCompletionHandler()
        }
    }
    

    
    
    func createFilterDropDown() {
        var filterItems = [String]()
        
        for project in allProjectsCopy {
            if let projectName = project.name {
                filterItems.append(projectName)
            }
        }

        
        if filterItems.count > 0 {
            let preSelectedFilterItem: String
            preSelectedFilterItem  =  filterItems[selectedProjectIndex]
            let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: preSelectedFilterItem, items: filterItems)
            menuView.customizeDropDown()
            self.navigationItem.titleView = menuView
            
            menuView.didSelectItemAtIndexHandler = {
                (indexPath: Int) -> () in
                self.cancelPickerButtonPressed()
                self.selectedProjectIndex = indexPath
                self.updateAllocatedAndSubmittedHoursLabel()
                self.tableView.reloadData()
            }
        }
        else{
           print("No projects to filter")
        }
        
     
    }
   
    @IBAction func backButtonPressed(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func infoButtonPressed(sender: AnyObject) {
        
        let timesheetInfoController = UIStoryboard.TimeSheet().instantiateViewControllerWithIdentifier(String(TSInfoController)) as! TSInfoController
        let nc = UINavigationController.init(rootViewController: timesheetInfoController)
        
       presentViewController(nc, animated: true, completion: nil)

    }
    
    func getDetailTaskIndex(index: Int) {
        
        indexValue = index
    }
}

    
//MARK:- extensions

extension TSTaskSelectController : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchState == true {
            return filteredTasks.count
        }
        else{
            if allProjectsCopy.count > 0 {
                let project = allProjectsCopy[selectedProjectIndex]
                
                if let count = project.tasks?.count {
                    if count > 0{
                        return count
                    }
                }
            }
            else {
                return 0
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("addTaskControllerCell", forIndexPath: indexPath)
        if searchState == true {
            
            cell.textLabel?.text = filteredTasks[indexPath.row].name ?? "No value"
            
            if Helper.lengthOfStringWithoutSpace(filteredTasks[indexPath.row].submittedHours) > 0{
                
                if let timeClockedInString = filteredTasks[indexPath.row].submittedHours  {
                    if let timeInFloat = Float(timeClockedInString) where timeInFloat > 0 {
                        cell.detailTextLabel?.text = " \(Helper.timeInHMformatForMinutes(Int(timeInFloat))) \(kSpaceString)"
                    }
                    else {
                        cell.detailTextLabel?.text = kEmptyString
                    }
                }
                cell.detailTextLabel?.layer.cornerRadius = 5
                cell.detailTextLabel?.clipsToBounds = true
                cell.detailTextLabel?.backgroundColor = UIColor.navBarColor()
                
            }
            else {
                cell.detailTextLabel?.backgroundColor = UIColor.clearColor()
                cell.detailTextLabel?.text = kEmptyString
            }
        }
            
        else {
            
            cell.textLabel?.text = getTask(indexPath.row).name ?? "No value"
               isCalledFromHeader = false
            if Helper.lengthOfStringWithoutSpace(getTask(indexPath.row).submittedHours) > 0{
                
                if let timeClockedInString = getTask(indexPath.row).submittedHours  {
                    if let timeInFloat = Float(timeClockedInString) where timeInFloat > 0 {
                        cell.detailTextLabel?.text = " \(Helper.timeInHMformatForMinutes(Int(timeInFloat))) \(kSpaceString)"
                    }
                    else {
                        cell.detailTextLabel?.text = kEmptyString
                    }
                }
                cell.detailTextLabel?.layer.cornerRadius = 5
                cell.detailTextLabel?.clipsToBounds = true
                cell.detailTextLabel?.backgroundColor = UIColor.navBarColor()
            }
            else {
                
                cell.detailTextLabel?.backgroundColor = UIColor.clearColor()
                cell.detailTextLabel?.text = kEmptyString
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        if let projects = timesheet.projects {
            let project = projects[selectedProjectIndex]
            
            var statusString:String? = nil
            if (project.status == TSStatus.Approved || project.status == TSStatus.Submitted) {
                statusString = "Project is already \(project.status!.rawValue)"
            }
            else if (weekStatus == TSStatus.Submitted || weekStatus == TSStatus.Approved) {
                statusString = "Timesheet is already \(weekStatus!.rawValue)"
            }
            
            if statusString != nil {
                
                    let alertController = UIAlertController(title: kEmptyString, message: statusString, preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                
                return nil
            }
        }
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchBar.resignFirstResponder()
        pickerViewBackgroundView.hidden = false
        indexSelected = indexPath
        let taskSubmittedHours = Int(allProjectsCopy[selectedProjectIndex].tasks![indexPath.row].submittedHours ?? "0") ?? 0
        if taskSubmittedHours > 0{
            timePicker.selectRow(taskSubmittedHours / kMinutesForHour , inComponent: 0, animated: true)
        }
        else {
            if let allocatedHours = timesheet.projects![selectedProjectIndex].allocatedHours where allocatedHours.characters.count > 0 {
                timePicker.selectRow(NSString(string:allocatedHours ?? "0").integerValue / kMinutesForHour, inComponent: 0, animated: true)
            }
            else {
                timePicker.selectRow(0, inComponent: 0, animated: true)
            }
        }
      
        if canScroll == false{
            let contentInset:UIEdgeInsets = UIEdgeInsetsMake(20 + (navigationController?.navigationBar.frame.size.height)!, 0, (timePicker.frame.size.height), 0)
            self.tableView.contentInset = contentInset
            self.tableView.scrollIndicatorInsets = contentInset
        }

        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pickerViewBackgroundView.hidden = true
        isDonePressed = true
        
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height , 0, 0, 0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if (maximumOffset - contentOffset <= 5) {
            canScroll = false
        }
        else{
            canScroll = true
        }
    }
    
    func getTask(index:Int)->TSTask{
        let project = allProjectsCopy[selectedProjectIndex]
            if let task = project.tasks?[index]{
                return task
            }
        
        return TSTask()
    }
}

extension TSTaskSelectController : UIPickerViewDataSource,UIPickerViewDelegate{
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return 24
        }
        else {
            return 12
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            
            if row == 1{
                return "\(row) hour"
            }
            else {
                return "\(row) hours"
            }
            
        }
        else{
            if row == 1{
                   return "05 mins"
            }
            else{
            return "\(row * 5) mins"
            }
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return tableView.frame.size.width/2
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        updateHeaderView()
    }
    
    func updateModel(){
        let hour =  timePicker.selectedRowInComponent(0)
        let min = timePicker.selectedRowInComponent(1)
        let minutes = hour * 60 + min * 5
        var totalTimesheetClockedHours = 0
        for project in allProjectsCopy{
            if let tasks = project.tasks{
                for task in tasks{
                    totalTimesheetClockedHours += NSString(string:task.submittedHours ?? "0").integerValue
                }
            }
        }
        
        if (totalTimesheetClockedHours + minutes) <= kAllowedClockedHours{
            
            if searchState == true{
                filteredTasks[indexSelected.row].submittedHours = String(minutes)
                
                guard let selectedTask = filteredTasks[indexSelected.row].name else{
                    print("error 1")
                    return
                }
                for object in filteredTasks {
                    let task = object
                    if task.name == selectedTask {
                        if allProjectsCopy.count > 0 {
                            let project = allProjectsCopy[selectedProjectIndex]
                            if let index = project.tasks?.indexOf({$0.name! == selectedTask})!{
                                project.tasks?[index] = task
                            }
                        }
                        else{
                            print("No projects")
                        }
                    }
                }
            }
            else {
                getTask(indexSelected.row).submittedHours =  String(minutes)
            }
            
            // Update project submitted hours
            for project in allProjectsCopy {
                var projectSubmittedHours = 0
                if let tasks = project.tasks {
                    for task in tasks {
                        projectSubmittedHours += NSString(string:task.submittedHours ?? "0").integerValue
                    }
                }
                project.submittedHours = String(projectSubmittedHours)
            }
        }
        else {
            let alertController = UIAlertController(title: kEmptyString, message: "Cannot clock more than 24 hours", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

extension TSTaskSelectController : UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchState = true
        filteredTasks.removeAll(keepCapacity: false)
        let searchText = searchBar.text!.lowercaseString
        if allProjectsCopy.count > 0{
         let project = allProjectsCopy[selectedProjectIndex]
            if let tasks = project.tasks{
                filteredTasks = tasks.filter({$0.name!.lowercaseString.rangeOfString(searchText) != nil})
            }
        }
        
        tableView.reloadData()
        
        if searchBar.text == ""{
            searchState = false
            tableView.reloadData()
        }
    }
//    func copyTasksToTimesheetModel(selectedRows: [Int]) {
//        timesheet.projects = allProjectsCopy
//        copyToDaysArray = selectedRows
//        if taskSelectCompletionHandler != nil{
//            self.taskSelectCompletionHandler()
//        }
//    }
}

extension TSTaskSelectController : TSCopyOverlayControllerDelegate {
  
    func removeTaskController() {
        
        navigationController?.popViewControllerAnimated(true)
        
    }
    

}

