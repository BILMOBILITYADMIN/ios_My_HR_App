//
//  TSApprovalDetailControllerViewController.swift
//  Workbox
//
//  Created by Anagha Ajith on 17/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire

class TSApprovalDetailController: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate {

//    @IBOutlet weak var rejectButton: ActionButton!

   
//    @IBOutlet weak var approveButton: ActionButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var buttonsViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var projectTitle: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var clockedHoursLabel: UILabel!
    @IBOutlet weak var allocatedHoursLabel: UILabel!
    
    var kDropDownButtonTag = 1000
    var collapsedSection = [Int]()
    var timesheetDaysArray = [Day]()
    var timesheetApproval: Approval?
    var timesheetTaskArray = [Task]()
    var buttonsViewHeightContraintInitialValue: CGFloat!
    var messageLabel = UILabel()
    var workItemId : String?
    var request: Alamofire.Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let workId = workItemId  {
            
            downloadWorkItem(workId)
        }
        else {
            createTimesheetData()
            updateHeaderView()
        }

        makeMessageLabel()
        buttonsViewHeightContraintInitialValue = buttonsViewHeightContraint.constant
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.hidden = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setActionBar()
        
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        setActionBar()
//        
//    }
    
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   //MARK: - Service call to download workitem
    func downloadWorkItem(unwrappedWorkitemId : String) {
        
        self.request =  Alamofire.request(Router.GetWorkitemDetail(id: unwrappedWorkitemId)).responseJSON { response in
            
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                
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
                    print("Error Occured: JSON Without success")
                    return
                }
                
                guard let jsonDataDictionary = jsonData.valueForKey("data") as? NSDictionary else{
                    print("Cannot cast JSON to Dictionary: \(JSON)")
                    return
                }
                self.timesheetApproval = Approval(JSON: jsonDataDictionary)
                self.createTimesheetData()
                self.updateHeaderView()
                self.setActionBar()
                self.buttonsViewHeightContraintInitialValue = self.buttonsViewHeightContraint.constant
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.tabBarController?.tabBar.hidden = true
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
    
    
    func makeMessageLabel (){
        
        messageLabel = UILabel(frame: CGRectMake(0,self.view.frame.height/2 - 20,self.view.frame.width, 40))
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.textColor = UIColor.grayColor()
        messageLabel.font = UIFont.boldSystemFontOfSize(18)
        messageLabel.text = "No Approvals"
        self.view.addSubview(messageLabel)
        messageLabel.hidden = true
    }
    
    func createTimesheetData() {
        
        if let days = timesheetApproval?.days{
            timesheetDaysArray = days
        }
    }
    
    func setActionBar(){
        let currentUser = UserDefaults.loggedInUser()
        let status = timesheetApproval?.cardStatus

        let assignedArray = timesheetApproval?.assignedTo
        
        if let users =  assignedArray?.filter({$0.id == currentUser?.id}){
            if users.count > 0 {
//                //////
//                let copyButton = UIButton()
//                copyButton.setTitle("COPY", forState: .Normal)
//                copyButton.addTarget(self, action: #selector(TSTaskSelectController.copyButtonPressed), forControlEvents: .TouchUpInside)
//                let doneButton = UIButton()
//                doneButton.addTarget(self, action: #selector(TSTaskSelectController.doneButtonPressed), forControlEvents: .TouchUpInside)
//                
//                doneButton.setTitle("DONE", forState: .Normal)
//                
//                
//                //////
                let approveButton = UIButton(frame: CGRectMake(0,0,0,0))
                approveButton.setTitle("APPROVE", forState: .Normal)
                approveButton.addTarget(self, action: #selector(TSApprovalDetailController.approveButtonPressed(_:)), forControlEvents: .TouchUpInside)

                buttonsViewHeightContraint.constant = buttonsViewHeightContraintInitialValue
                
                let rejectButton = UIButton(frame: CGRectMake(0,0,0,0))
                rejectButton.addTarget(self, action: #selector(TSApprovalDetailController.rejectButtonPressed(_:)), forControlEvents: .TouchUpInside)
                rejectButton.setTitle("REJECT", forState: .Normal)
                
                approveButton.enabled = true
                rejectButton.enabled = true
                
                let actionApproveRejectViewArray = [approveButton,rejectButton]
                
                Helper.layoutButtons(true, actionView: buttonsView, actionViewHeightConstraint: buttonsViewHeightContraint, actionViewInitialHeight: buttonsViewHeightContraint.constant, viewArray: actionApproveRejectViewArray, maximumNumberOfButtonsToShow: nil)
                
                
                
                Helper.setBorderForButtons(approveButton, color: UIColor.navBarColor())
                Helper.setBorderForButtons(rejectButton, color: UIColor.redColor())
            }
            else{
                buttonsViewHeightContraint.constant = 0
           
            }
        }
        

                if status == CardStatus.Approved{
                    buttonsViewHeightContraint.constant = 0
                   
                }
                else if(status == CardStatus.Rejected) {
                    buttonsViewHeightContraint.constant = 0
                }

    }
    
    func updateHeaderView() {
        headerView.backgroundColor = UIColor.navBarColor()
        let imageURL = timesheetApproval?.submittedBy?.avatarURLString ?? ""
                profileImageView.setImageWithOptionalUrl(imageURL.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
       
        if let name = timesheetApproval?.submittedBy?.displayName{
            nameLabel.text = name
        }
            profileImageView.setImageWithOptionalUrl(timesheetApproval?.submittedBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        if let projectName = timesheetApproval?.projectName{
            projectTitle.text = projectName
        }
        
        
        if let startDate = timesheetApproval?.weekStartDate {
            if let endDate = timesheetApproval?.weekEndDate{
                periodLabel.text = "\(Helper.stringForDate(startDate, format: "dd MMM")) - \(Helper.stringForDate(endDate, format: "dd MMM"))"
            }
            else{
                periodLabel.text = "\(Helper.stringForDate(startDate, format: "dd MMM")) - present"
            }
        }
        allocatedHoursLabel.text = Helper.timeInHMformatForMinutes(Int(timesheetApproval!.allocatedHours * 60))
        clockedHoursLabel.text = Helper.timeInHMformatForMinutes(Int(timesheetApproval!.submittedHours * 60))
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.clipsToBounds = true
        
        self.statusLabel.text = self.timesheetApproval?.cardStatus != nil ? self.timesheetApproval?.cardStatus.rawValue.capitalizedString : kEmptyString
    }
    
    func indexPathsForSectionWithNumberOfRows( section: Int, noOfRows: Int) -> [NSIndexPath] {
        
        var indexPaths = [NSIndexPath]()
        indexPaths.removeAll()
        var i = 0
        
        while (i < noOfRows){
            let indexPath = NSIndexPath(forRow: i, inSection: section)
            indexPaths.append(indexPath)
            i += 1
        }
        return indexPaths
    }
}

//MARK: - Extensions

extension TSApprovalDetailController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let unwrappedDays = (timesheetApproval?.days) where  unwrappedDays.count > 0{
            self.messageLabel.hidden = true
            return unwrappedDays.count
        }
        else {
            self.messageLabel.hidden = false
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if collapsedSection.contains(section) == true{
            return 0
        }
        else{
            if let count = (timesheetApproval?.days?[section].tasks?.count){
                return count
            }
            else{
                print("Tasks not present/Invalid Submit")
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let approvalProjectCell = tableView.dequeueReusableCellWithIdentifier("TSApprovalProjectCell", forIndexPath: indexPath) as! TSApprovalProjectCell
        let timesheetTask = timesheetDaysArray[indexPath.section].tasks![indexPath.row]
        
        if let projectName = timesheetApproval?.projectName {
            approvalProjectCell.updateProjectCell(timesheetTask,projectName:projectName)
        }
        else{
            approvalProjectCell.updateProjectCell(timesheetTask,projectName:(timesheetApproval?.projectId)!)
        }
        return approvalProjectCell
    }
}


extension TSApprovalDetailController: UITableViewDelegate {
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionView: UIView?
        let dropDownButton = UIButton()
        
        dropDownButton.tag = kDropDownButtonTag
        dropDownButton.frame = CGRectMake(tableView.frame.size.width - 30, 10 , 20, 20 )
        dropDownButton.setImage(AssetImage.arrow.image, forState: UIControlState.Normal)
        dropDownButton.userInteractionEnabled = false
        
        
        let dayLabel = UILabel.init(frame: CGRectMake(8, 10 , tableView.frame.size.width/2 - 20 , 15))
        dayLabel.text = Helper.stringForDate(timesheetDaysArray[section].date, format: "EEEE")
        dayLabel.font = UIFont.systemFontOfSize(13)
        
        let allocatedHoursLabel = UILabel.init(frame: CGRectMake(tableView.frame.size.width/2 - 10, 10, 45, 15))
        
        allocatedHoursLabel.text = String(timesheetApproval?.days?[section].allocatedHours ?? 0.0)
        
        allocatedHoursLabel.font = UIFont.systemFontOfSize(13)
        
        let submittedHoursLabel = UILabel.init(frame: CGRectMake(tableView.frame.size.width - 100, 10, 50, 15))
        
        if let days = timesheetApproval!.days{
            
            
            if let tasks = days[section].tasks{
                var sum:Float = 0
                for task in tasks{
                    sum += Float(task.hours!)
                }
                submittedHoursLabel.text = Helper.timeInHMformatForMinutes(Int(sum * 60))
            }
        }
        
        submittedHoursLabel.font = UIFont.systemFontOfSize(13)
        
        sectionView = UIView.init(frame:CGRectMake(0, 0, tableView.frame.size.width, 44))
        sectionView?.addSubview(dayLabel)
        sectionView?.addSubview(allocatedHoursLabel)
        sectionView?.addSubview(submittedHoursLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TSApprovalDetailController.sectionTapped(_:)))
        sectionView!.addGestureRecognizer(tapGesture)
        sectionView?.backgroundColor = UIColor.whiteColor()
        sectionView?.tag = section
        sectionView?.addSubview(dropDownButton)
        return sectionView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func sectionTapped(sender:UITapGestureRecognizer){
        
        tableView.beginUpdates()
        
        guard let section = sender.view?.tag else{
            print("Section ERROR")
            return
        }
        
        let shouldCollapse : Bool = !collapsedSection.contains(section)
        
        if let button = sender.view?.viewWithTag(kDropDownButtonTag) {
            
            if shouldCollapse {
                
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    button.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI))
                })
            }
            else {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    button.transform = CGAffineTransformMakeRotation(CGFloat(0))
                })
            }
        }
        
        timesheetTaskArray = (timesheetApproval?.days?[section].tasks)!
        if (shouldCollapse) {
            
            let numOfRows = timesheetTaskArray.count
            let  indexPaths = indexPathsForSectionWithNumberOfRows(section, noOfRows: numOfRows)
            
            collapsedSection.append(section)
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
        }
        else {
            let numOfRows = timesheetTaskArray.count
            let  indexPaths = indexPathsForSectionWithNumberOfRows(section, noOfRows: numOfRows)
            collapsedSection.removeAtIndex((collapsedSection.indexOf(section))!)
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
        }
        tableView.endUpdates()
    }
    @IBAction func backButtonPressed(sender: AnyObject) {
        //        self.navigationController?.navigationBarHidden = true
        self.navigationController?.popViewControllerAnimated(true)
        //        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension TSApprovalDetailController{
    
     func approveButtonPressed(sender: AnyObject) {
        print("approve")
        guard let unwrappedWorkItemId = timesheetApproval?.id else{
            print("Work Item Id is nil")
            return
        }
        var actionProperty = ActionProperty()
        actionProperty.workitemId = unwrappedWorkItemId
        actionProperty.senderViewController = self
        ActionController.instance.approve(actionProperty)
//      let tsApprovalController =  self.navigationController?.viewControllers[0] as? TSApprovalController
//        tsApprovalController?.clearAndReloadTableviewData()
    }
    
     func rejectButtonPressed(sender: AnyObject) {
        print("reject")
        guard let unwrappedWorkItemId = timesheetApproval?.id else{
            print("Work Item Id is nil")
            return
        }
        var actionProperty = ActionProperty()
        actionProperty.workitemId = unwrappedWorkItemId
        actionProperty.senderViewController = self
        ActionController.instance.reject(actionProperty)
//        let tsApprovalController =  self.navigationController?.viewControllers[0] as? TSApprovalController
//        tsApprovalController?.clearAndReloadTableviewData()
    }
}
