//
//  NotificationController.swift
//  Workbox
//
//  Created by Anagha Ajith on 23/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire


class NotificationController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var notificationArray = [NSMutableAttributedString]()
    var timeArray = [String]()
    var notification = [Notification]()
    var isLoading = false
    var refreshControl = UIRefreshControl()
    var request : Alamofire.Request?
    var hrFunction : String?
//    var webURL = "http://hrapps.britindia.com/#"
    
    var webURL = "http://dev.cherrywork.in:7023/#"
    
//    172.16.8.236
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationFetch()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        refreshControl.addTarget(self, action:#selector(NotificationController.handleRefresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        createNavBar()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        ActionController.instance.downloadBadgeCount()
        super.viewWillDisappear(animated)
    }
    
    //MARK: - Create navigation bar
    func createNavBar() {
        self.navigationController?.setupNavigationBar()
        navigationController?.navigationBar.topItem?.title = "Notifications"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: AssetImage.cross.image, style: .Plain, target: self, action: #selector(NotificationController.backButtonPressed(_:)))
    }
    
    func backButtonPressed(sender: UIBarButtonItem) {
//        ActionController.instance.downloadBadgeCount()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        isLoading = false
        self.request?.cancel()
        notificationFetch()
    }
    
    //MARK: - Service call to fetch notifications
    func notificationFetch() {
        if(refreshControl.refreshing == false){
            
            //          EZLoadingActivity.show("Loading", disableUI: true)
            
            LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
        }
        
        self.request = Alamofire.request(Router.NotificationFetch()).responseJSON { response in
            
            LoadingController.instance.hideLoadingView()
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                print(JSON)
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else {
                    print("Error Occured: JSON Without success")
                    return
                }
                
                self.notification.removeAll()
                print("1:", self.notification.count)
                
                if let dataDict = jsonData.valueForKey("data") as? NSDictionary  {
                    
                    if let receiverDict = dataDict.valueForKey("receiver") as? NSDictionary {
                        
                        if let  roleDict = receiverDict.valueForKey("role") as? NSDictionary {
                                self.hrFunction = roleDict.valueForKey("hrFunction") as? String
                        }
                
                    }
                }
                
                if let dataDict = jsonData.valueForKey("data") as? NSDictionary  {
                  
                    if let notificationDict = dataDict.valueForKey("notifications") as? [NSDictionary] {
                        
                        var notificationArraylocal = [Notification]()
                        
                        if let dataArray = notificationDict as NSArray? {
                            
                            for data in dataArray as! [NSDictionary] {
                                
                                if let notificationParsed = Parser.notificationFetch(data) {
                                    
                                    LoadingController.instance.hideLoadingView()
                                    
                                    notificationArraylocal.append(notificationParsed)
                                }
                            }
                        }
                        
                        self.notification = notificationArraylocal
                        self.updateNotificationTable()
                    }
                }
                
                
                
                if self.refreshControl.refreshing
                {
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                }
                else {
                    self.tableView.reloadData()
                }
                
                if self.notificationArray.isEmpty == true {
                    let messageLabel = UILabel(frame: CGRectMake(0,self.view.frame.height/2 - 64,self.view.frame.width, 40))
                    messageLabel.textAlignment = NSTextAlignment.Center
                    messageLabel.textColor = UIColor.grayColor()
                    messageLabel.font = UIFont.boldSystemFontOfSize(18)
                    messageLabel.text = "No Notifications"
                    
                    self.tableView.separatorColor = UIColor.clearColor()
                    self.tableView.userInteractionEnabled = false
                    self.tableView.addSubview(messageLabel)
                }
                
            case .Failure(let error):
                
                print("Request failed with error: \(error)")
                
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
    
    //MARK: - Updating notification table
    func updateNotificationTable(){
       
        notificationArray.removeAll()
        for notif in notification {
            var displayNameString = String()
            var weekString = String()
            
            if let type = notif.content {
           
                if let message = notif.message{
                    if let displayName = notif.updatedBy?.displayName {
                        displayNameString = displayName
                    }
                   
                    if notif.applicationType == "updateRequisition" || notif.applicationType == "requisition" || notif.applicationType == "scheduleInterview" || notif.applicationType == "postIJP" || notif.applicationType == "postER" || notif.applicationType == "interviewFeedback" || notif.applicationType == "offerRollout" || notif.applicationType == "generateOffer" || notif.applicationType == "applicationEvaluation" || notif.applicationType == "profileEvaluation" || notif.applicationType == "approveRequisition" || notif.applicationType == "sourceRequisition" || notif.applicationType == "uploadDocuments" || notif.applicationType == "Info Process" || notif.applicationType == "Approval Process" || notif.applicationType == "Reject Process" ||
                    notif.applicationType == "Cancel Process"{
                        
                        if let displayName = notif.sender?.displayName {
                            displayNameString = displayName
                        }
                        
                        if let startDate = notif.startDate , endDate = notif.endDate {
                            weekString = " for \(Helper.stringForDate(startDate, format: "dd-MM-YYY")) to \(Helper.stringForDate(endDate, format: "dd-MM-YYY"))"
                            
                        }
                        
                        let attributedStr2 = NSMutableAttributedString(string:weekString)
                        let attributedStr1 = NSMutableAttributedString(string:message)
                        
                       
                        let displayNameRange = (message as NSString).rangeOfString(displayNameString as String)
                        attributedStr1.setAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(13), NSForegroundColorAttributeName : UIColor.blackColor()], range: displayNameRange)
                        
                        attributedStr1.appendAttributedString(attributedStr2)

                        
                        notificationArray.append(attributedStr1)

                        
                    }
                    
                    if let content = type.valueForKey("timesheet"){
                        if let startDate = notif.startDate , endDate = notif.endDate {
                            weekString = " for \(Helper.stringForDate(startDate, format: "dd-MM-YYY")) to \(Helper.stringForDate(endDate, format: "dd-MM-YYY"))"
                          
                        }
                        let attributedStr2 = NSMutableAttributedString(string:weekString)
                        let messageInString = "\(message) by "
                        let attributedStr1 = NSMutableAttributedString(string:messageInString)
                        
                        let attributedString = NSMutableAttributedString(string: displayNameString, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(13)])
                        attributedString.appendAttributedString(attributedStr2)
                        attributedStr1.appendAttributedString(attributedString)
                        
                        notificationArray.append(attributedStr1)
                        
                    }
                        
                    else if let content = type.valueForKey("workitem") , _ = content.valueForKey("status"){
                        if let startDate = content.valueForKey("startDate") as? String, endDate = content.valueForKey("endDate") as? String{
                            
                            let startDateInDateFormat = Helper.dateForDDMMYYYYString(startDate)
                            let endDateInDateFormat = Helper.dateForDDMMYYYYString(endDate)
                            
                            weekString = " for \(Helper.stringForDate(startDateInDateFormat, format: "dd-MM-yyyy"))  to \(Helper.stringForDate(endDateInDateFormat, format: "dd-MM-yyyy"))"
                            
                        }
                        let attributedStr2 = NSMutableAttributedString(string:weekString)
                        let messageInString = "\(message) of "
                        let attributedStr1 = NSMutableAttributedString(string: messageInString)
                        let attributedString = NSMutableAttributedString(string: displayNameString, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(13)])
                        attributedString.appendAttributedString(attributedStr2)
                        attributedStr1.appendAttributedString(attributedString)
                        
                        notificationArray.append(attributedStr1)
                        
                    }
                    
                    else if let _ = type.valueForKey("appraisalTemplate") {
                        if let senderName = notif.sender?.displayName as String? {
                            let messageInString = "\(message) by "
                        let attributedStr1 = NSMutableAttributedString(string: messageInString)
                        let attributedString = NSMutableAttributedString(string: senderName, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(13)])
//                        attributedString.appendAttributedString(attributedStr2)
                        attributedStr1.appendAttributedString(attributedString)
                        
                        notificationArray.append(attributedStr1)
                        }
                    }
                    else if let _ = type.valueForKey("appraisalProcess") {
                        if let senderName = notif.sender?.displayName as String? {
                            let messageInString = "\(message) by "
                            let attributedStr1 = NSMutableAttributedString(string: messageInString)
                            let attributedString = NSMutableAttributedString(string: senderName, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(13)])
                            //                        attributedString.appendAttributedString(attributedStr2)
                            attributedStr1.appendAttributedString(attributedString)
                            
                            notificationArray.append(attributedStr1)
                        }
                    }
                    
                    else if let _ = type.valueForKey("onBoardingProcess") {
                        if let senderName = notif.sender?.displayName as String? {
                            let messageInString = "\(message) by "
                            let attributedStr1 = NSMutableAttributedString(string: messageInString)
                            let attributedString = NSMutableAttributedString(string: senderName, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(13)])
                            //                        attributedString.appendAttributedString(attributedStr2)
                            attributedStr1.appendAttributedString(attributedString)
                            
                            notificationArray.append(attributedStr1)
                        }
                    }
                    
                    
                    
                    
                    
                }
            }
            
            let dateInString = Helper.stringForDate(notif.updatedAt, format: "dd MMMM")
            timeArray.append(dateInString)
        }
        
        
        if notificationArray.isEmpty == true {
            
            let messageLabel = UILabel(frame: CGRectMake(0,self.view.frame.height/2 - 64,self.view.frame.width, 40))
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.textColor = UIColor.grayColor()
            messageLabel.font = UIFont.boldSystemFontOfSize(18)
            messageLabel.text = "No Notifications"
            
            tableView.separatorColor = UIColor.clearColor()
            tableView.userInteractionEnabled = false
            tableView.addSubview(messageLabel)
        }
    }
    
    //MARK: - Service call for notification read/unread
    func notificationRead(notificationId: String,index:Int) {
        Alamofire.request(Router.NotificationRead(id: notificationId)).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
               
                guard let jsonData = JSON as? NSDictionary else{
                    self.notification[index].read = false
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
                    self.notification[index].read = false

                    return
                }
                self.notification[index].read = true
                
            case .Failure(let error):
                self.notification[index].read = false
                print("Request failed with error: \(error)")
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
        tableView.reloadData()

    }
}

    //MARK: - Extensions
extension NotificationController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(String(NotificationCell), forIndexPath: indexPath) as! NotificationCell
        if notification[indexPath.row].read == true {
            cell.contentView.backgroundColor = UIColor.tableViewBackGroundColor()
        }
        else{
            cell.contentView.backgroundColor = UIColor.tableViewCellBackGroundColor()

        }
        cell.updateCell(notification[indexPath.row] ,notification: notificationArray[indexPath.row],time: timeArray[indexPath.row])

        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let notificationId = notification[indexPath.row].id {
            
            notificationRead(notificationId,index: indexPath.row)
            
            if let notificationDict = notification[indexPath.row].content {
                print(notificationDict)
                if let name = notificationDict.valueForKey("timesheet"), status = name.valueForKey("status") as? String{
                    
                    if status == String("rejected") {
                        
                        let timesheetController = UIStoryboard.TimeSheet().instantiateViewControllerWithIdentifier(String(TSHomeController)) as! TSHomeController
                        
                        if let startDate = name.valueForKey("startDate") as? String, endDate = name.valueForKey("endDate") as? String{
                            print(startDate)
                            print(endDate)
                            timesheetController.date = startDate
                            timesheetController.fromNotif = true
                        }
                        
                        self.navigationController?.pushViewController(timesheetController, animated: true)
                        timesheetController.TSHomeControllerCompletionHandler = { () -> Void in
                            
                            self.navigationController?.popViewControllerAnimated(true)
                            
                        }
                    }
                }
                else if let leaveProcess = notificationDict.valueForKey("leaveProcess"){
                    if let leaveID = leaveProcess.valueForKey("leaveID"){
                        
                        let webViewController = WebViewController()
                      
                            webViewController.navTitleString = "Leave Process"
                            webViewController.isNavBarPresent = true
                            webViewController.cherryName = Cherries.Leave
                        webViewController.url = "\(webURL)/mobile/leave/detail/\(leaveID)"
                            navigationController?.pushViewController(webViewController, animated: true)
                
                }
                }
                else if let name = notificationDict.valueForKey("workitem"), status = name.valueForKey("status") as? String , id = name.valueForKey("_id") as? String {
                    if status == String("submitted") {
                        let approveDetail = UIStoryboard.Approvals().instantiateViewControllerWithIdentifier(String(TSApprovalDetailController)) as! TSApprovalDetailController
                        approveDetail.workItemId = id
                        print(approveDetail.workItemId)
                        self.navigationController?.pushViewController(approveDetail, animated: true)
                    }
                }
                
                else if let content = notificationDict.valueForKey("appraisalTemplate") , id = content.valueForKey("_id") as? String, status = content.valueForKey("status") as? String{
                    
                        let webViewController = WebViewController()
                        if let workitemId = content.valueForKey("workitemId") as? String {
                            webViewController.navTitleString = "Template Detail"
                            webViewController.isNavBarPresent = false
                            webViewController.cherryName = Cherries.ChampionScoreCard
                            webViewController.url = "\(webURL)/mobile/pms/template-detail-approval?templateid=\(id)&workitemid=\(workitemId)&status=\(status)"
                            navigationController?.pushViewController(webViewController, animated: true)

                    }
                
                
                }
                    
                else if let content = notificationDict.valueForKey("onBoardingProcess") {
                
                    if let currentStage = content.valueForKey("currentStage") as? String, formId = content.valueForKey("formId"){
                    
                    let webViewController = WebViewController()
                   
                    switch currentStage {
                        
                    case "medicalForm" : webViewController.navTitleString = "Medical Form"
                    webViewController.cherryName = Cherries.Onboarding
                    webViewController.url = "\(webURL)/mobile/onboarding/onboarding-medicalObt?id=\(formId)"
                        
                    case "bgvReportSubmission" : webViewController.navTitleString = "Verification"
                    webViewController.cherryName = Cherries.Onboarding
                    webViewController.url = "\(webURL)/mobile/onboarding/onboarding-employeeinfo?id=\(formId)"
                        
                    case "formSubmission" : webViewController.navTitleString = "Form Submission"
                    webViewController.cherryName = Cherries.Onboarding
                    webViewController.url = "\(webURL)/mobile/onboarding/onboarding-checklist?id=\(formId)"
                        
                        
                    case "hire" : webViewController.navTitleString = "Hire Joiner"
                    webViewController.cherryName = Cherries.Onboarding
                    webViewController.url = "\(webURL)/mobile/onboarding/onboarding-allList?id=\(formId)"
                        
                    default: webViewController.navTitleString = "Form Submission"
                    webViewController.cherryName = Cherries.Onboarding
                    webViewController.url = "\(webURL)/mobile/onboarding/onboarding-checklist?id=\(formId)"

                        
                        }
                        navigationController?.pushViewController(webViewController, animated: true)

                        
                    }
                    
                    
                }
                    
                    
                else if notification[indexPath.row].applicationType == "updateRequisition"{
                    
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    if let content = notification[indexPath.row].content{
                        if let updateRequisition = content.valueForKey("updateRequisition"){
                            if let requisitionId = updateRequisition.valueForKey("requisitionId"){
                                let nonBudgeted = "nonBudgeted"
                                webViewController.navTitleString = "Update"
                                webViewController.cherryName = Cherries.Recruitment
                                webViewController.url = "\(webURL)/mobile/recruitment/update-non-budgeted-requisition?id=\(requisitionId)&subtype=\(nonBudgeted)"
                            }
                            
                        }
                     navigationController?.pushViewController(webViewController, animated: true)
                    
                    }
                }
                else if notification[indexPath.row].applicationType == "requisition"{
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    if let content = notification[indexPath.row].content{
                        if let requisition = content.valueForKey("requisition"){
                            if let requisitionId = requisition.valueForKey("requisitionId"){
                                webViewController.navTitleString = "Requisition"
                                webViewController.cherryName = Cherries.Recruitment
                                webViewController.url = "\(webURL)/mobile/recruitment/recruitment-description?id=\(requisitionId)"
                            }
                            
                        }
                        navigationController?.pushViewController(webViewController, animated: true)
                        
                    }

                }
                    
                else if notification[indexPath.row].applicationType == "sourceRequisition"{
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    if let content = notification[indexPath.row].content{
                        if let requisition = content.valueForKey("sourceRequisition"){
                            if let requisitionId = requisition.valueForKey("requisitionId"){
//                                
//                                if let position = requisitionBody.valueForKey("positionName"),location = requisitionBody.valueForKey("location"), id = workitemData.valueForKey("_id"){
                                webViewController.navTitleString = "Requisition"
                                webViewController.cherryName = Cherries.Recruitment
                                webViewController.url = "\(webURL)/mobile/recruitment/recruitment-sourcing?id=\(requisitionId)"
                                
                                
                              //  }
                            
                            }
                        
                        
                        }
                        navigationController?.pushViewController(webViewController, animated: true)
                
                    }
                }
                
                else if notification[indexPath.row].applicationType == "scheduleInterview"{
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    if let content = notification[indexPath.row].content{
                        if let scheduleInterview = content.valueForKey("scheduleInterview"){
                            if let requisitionId = scheduleInterview.valueForKey("requisitionId"){
                                webViewController.navTitleString = "Schedule Interview"
                                webViewController.cherryName = Cherries.Recruitment
                                webViewController.url = "\(webURL)/mobile/recruitment/recruitment-newapplicants?id=\(requisitionId)"
                            }
                            
                        }
                        navigationController?.pushViewController(webViewController, animated: true)
                        
                    }

                }
                
                else if (notification[indexPath.row].applicationType == "postIJP" || notification[indexPath.row].applicationType == "postER"){
                    
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    webViewController.navTitleString = "Recruitment"
                    webViewController.cherryName = Cherries.Recruitment
                    webViewController.url = "\(webURL)/mobile/recruitment/IJP"
                    navigationController?.pushViewController(webViewController, animated: true)
                    
                }
                
                else if notification[indexPath.row].applicationType == "interviewFeedback"{
                    
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    if let content = notification[indexPath.row].content{
                        if let interviewFeedback = content.valueForKey("interviewFeedback"){
                            if let requisitionId = interviewFeedback.valueForKey("requisitionId"), applicationId = interviewFeedback.valueForKey("applicationId"), candidate = interviewFeedback.valueForKey("candidate"){
                                let email = candidate.valueForKey("emailId")
                                webViewController.navTitleString = "Feedback"
                                webViewController.cherryName = Cherries.Recruitment
                                webViewController.url = "\(webURL)/mobile/recruitment/shortlistdetails?id=\(requisitionId)&applicationId=\(applicationId)&email=\(email!)"
                            }
                            
                        }
                        navigationController?.pushViewController(webViewController, animated: true)
                        
                    }

                    
                }
                    
                else if notification[indexPath.row].applicationType == "profileEvaluation"{
                    
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    if let content = notification[indexPath.row].content{
                        if let interviewFeedback = content.valueForKey("profileEvaluation"){
                            let candidate = interviewFeedback.valueForKey("candidate")
                            if let requisitionId = interviewFeedback.valueForKey("requisitionId"), applicationId = interviewFeedback.valueForKey("applicationId"), email = candidate?.valueForKey("emailId"){
                                webViewController.navTitleString = "Profile Evaluation"
                                webViewController.cherryName = Cherries.Recruitment
                                webViewController.url = "\(webURL)/mobile/recruitment/recruitment-candidatedetailview?id=\(requisitionId)&applicationId=\(applicationId)&email=\(email)"
                            }
                            
                        }
                        navigationController?.pushViewController(webViewController, animated: true)
                        
                    }
                    
                    
                }
                    
                else if notification[indexPath.row].applicationType == "applicationEvaluation"{
                    
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    if let content = notification[indexPath.row].content{
                        if let interviewFeedback = content.valueForKey("applicationEvaluation"){
                            let candidate = interviewFeedback.valueForKey("candidate")
                            if let requisitionId = interviewFeedback.valueForKey("requisitionId"), applicationId = interviewFeedback.valueForKey("applicationId"), email = candidate?.valueForKey("emailId"){
                                webViewController.navTitleString = "Application Evaluation"
                                webViewController.cherryName = Cherries.Recruitment
                                webViewController.url = "\(webURL)/mobile/recruitment/shortlistdetails?id=\(requisitionId)&applicationId=\(applicationId)&email=\(email)"
                            }
                            
                        }
                        navigationController?.pushViewController(webViewController, animated: true)
                        
                    }
                    
                    
                }
                    
                else if notification[indexPath.row].applicationType == "approveRequisition"{
                    
                    dismissViewControllerAnimated(false, completion: nil)
                }



                
                else if notification[indexPath.row].applicationType == "offerRollout"{
                    
                    let roles = UserDefaults.userRole()
                    let object = roles["Recruitment"]!
                    let role = object.first!["name"] as? String
                    
                    if role == "COMPHEAD"{
                        dismissViewControllerAnimated(false, completion: nil)
                    }
                    else if role == "HRBP"{
                        
                        let webViewController = WebViewController()
                        
                        webViewController.isNavBarPresent = false
                        if let content = notification[indexPath.row].content{
                            
                                
                                    webViewController.navTitleString = "Offers"
                                    webViewController.cherryName = Cherries.Recruitment
                                    webViewController.url = "\(webURL)/mobile/recruitment/offered"
                                
                                
                            
                            navigationController?.pushViewController(webViewController, animated: true)
                            
                        }

                    }
                }
                    
                else if notification[indexPath.row].applicationType == "generateOffer"{
                    
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    if let content = notification[indexPath.row].content{
                        if let generateOffer = content.valueForKey("generateOffer"){
                            if let offerId = generateOffer.valueForKey("offerId"){
                                webViewController.navTitleString = "Schedule Interview"
                                webViewController.cherryName = Cherries.Recruitment
                                webViewController.url = "\(webURL)/mobile/recruitment/recruitment-offereddetail?Cid=\(offerId)"
                            }
                            
                        }
                        navigationController?.pushViewController(webViewController, animated: true)
                        
                    }

                    
                }
                    
                else if notification[indexPath.row].applicationType == "uploadDocuments"{
                    
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    if let content = notification[indexPath.row].content{
                        if let interviewFeedback = content.valueForKey("uploadDocuments"){
                           
                            if let requisitionId = interviewFeedback.valueForKey("requisitionId"), applicationId = interviewFeedback.valueForKey("applicationId"), email = interviewFeedback.valueForKey("candidateEmail"){
                                webViewController.navTitleString = "Document Upload"
                                webViewController.cherryName = Cherries.Recruitment
                                webViewController.url = "\(webURL)/mobile/recruitment/shortlistdetails?id=\(requisitionId)&applicationId=\(applicationId)&email=\(email)"
                            }
                            
                        }
                        navigationController?.pushViewController(webViewController, animated: true)
                        
                    }
                    
                    
                }

                    
                
                else if let content = notificationDict.valueForKey("appraisalProcess") {
               if let id = content.valueForKey("templateId") as? String, currentStage = content.valueForKey("currentStage") as? String, fromDate = notificationDict.valueForKeyPath("appraisalProcess.evaluationPeriod.from") as? String , toDate = notificationDict.valueForKeyPath("appraisalProcess.evaluationPeriod.to") as? String {
                
                    var hrFunc = notificationDict.valueForKeyPath("appraisalProcess.hrFunction") as? String
                    let webViewController = WebViewController()
                
                    webViewController.isNavBarPresent = false
                
                var appName:String = kEmptyString
                if let uwAppName = content["name"] as? String {
                    appName = Helper.urlEncode(uwAppName)
                }
                
                switch currentStage {
                    
                case "closed" : webViewController.navTitleString = "Closed Appraisal"
                webViewController.cherryName = Cherries.PMS
                let roles = UserDefaults.userRole()
                let object = roles["Performance Management System"]!
                let role = object.first!["name"] as? String
                
                if role == "TSI"{
                webViewController.url = "\(webURL)/mobile/pms/tsi-annual-scores?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)&hrFunction="
                }
                else{
                    if role != "HRBP"{
                    hrFunc = notification[indexPath.row].receiver?.hrFunction
                    }
                    webViewController.url = "\(webURL)/mobile/pms/pms-report?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                }
                    
                case "Target Settings" : webViewController.navTitleString = "Targets"
                webViewController.cherryName = Cherries.ChampionScoreCard
                    webViewController.url = "\(webURL)/mobile/csc/employee-target-fill-list?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
               
                case "Target Approval" : webViewController.navTitleString = "Approvals"
                webViewController.cherryName = Cherries.ChampionScoreCard
                    webViewController.url = "\(webURL)/mobile/csc/mass-target-approvals?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                
                case "Achievement Update By RSA" : webViewController.navTitleString = "Achievements"
                webViewController.cherryName = Cherries.ChampionScoreCard
                    webViewController.url = "\(webURL)/mobile/csc/employee-achievement-fill-list?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                
                case "Achievement Review By Manager" : webViewController.navTitleString = "Review"
                webViewController.cherryName = Cherries.ChampionScoreCard
                    webViewController.url = "\(webURL)/mobile/csc/mass-achievement-approvals?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                
                case "Review and Update By Capability Team" : webViewController.navTitleString = "Scores"
                webViewController.cherryName = Cherries.ChampionScoreCard
                    webViewController.url = "\(webURL)/mobile/csc/employee-scores?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                    
                case "Review By HR Office" : webViewController.navTitleString = "Template Detail"
                webViewController.cherryName = Cherries.ChampionScoreCard
                    webViewController.url = "\(webURL)/mobile/csc/employee-scores-approval-byhrofficer?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                    
                case "KRA Inputs By Sales Admin" :webViewController.navTitleString = "Target Inputs"
                webViewController.cherryName = Cherries.PMS
                webViewController.url = "\(webURL)/mobile/pms/employee-goals-upload?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)&hrFunction=\(hrFunction)"
                    
                case "KRA Approval By Manager" :webViewController.navTitleString = "Target Approval"
                webViewController.cherryName = Cherries.PMS
                webViewController.url = "\(webURL)/mobile/pms/mass-target-approvals?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)&hrFunction=\(hrFunction)"

                    
                case "Achievement Input By Sales Admin" :webViewController.navTitleString = "Achievement Input"
                webViewController.cherryName = Cherries.PMS
                webViewController.url = "\(webURL)/mobile/pms/employee-achievements-upload?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"

                case "Self Assessment By Employee" :webViewController.navTitleString = "Self Assessment"
                webViewController.cherryName = Cherries.PMS
                webViewController.url = "\(webURL)/mobile/pms/tsi-annual-detail?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)&hrFunction=\(hrFunction)"

                case "Manager Assessment" :webViewController.navTitleString = "Manager Assessment"
                webViewController.cherryName = Cherries.PMS
                webViewController.url = "\(webURL)/mobile/pms/employee-assesment-appovals?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)&hrFunction=\(hrFunction)"
                    
                    
                case "HRBP Approval" :webViewController.navTitleString = "HRBP Approval"
                webViewController.cherryName = Cherries.PMS
                webViewController.url = "\(webURL)/mobile/pms/employee-drilldown-tree-data?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)&hrFunction=\(hrFunction)"
                    
                default: webViewController.navTitleString = "Template Detail"
                webViewController.cherryName = Cherries.ChampionScoreCard
                    webViewController.url = "\(webURL)/mobile/csc/employee-scores-approval-byrhrm?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)&hrFunction=\(hrFunction)"
                    
                }
                
                navigationController?.pushViewController(webViewController, animated: true)
                        
                
                    
                }
                }
                
            }
        }
    }
}