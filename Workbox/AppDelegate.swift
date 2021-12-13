//
//  AppDelegate.swift
//  Workbox
//
//  Created by Ratan D K on 01/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.


import UIKit
import CoreData
import LocalAuthentication
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let controller = UINavigationController()
    var hrFunction : String?
    var window: UIWindow?
    var firstViewController: FirstViewController?
    var authenticationContext = LAContext()
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Crashlytics.self])
        
        application.applicationIconBadgeNumber = -1
        
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last! as String
        print("CD Path: \(path)")
        
        let deviceId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        UserDefaults.setDeviceId(deviceId)
        
        
        
        // Create window and root
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        firstViewController = FirstViewController()
        window!.rootViewController = firstViewController
        window!.makeKeyAndVisible()
        if UserDefaults.isSetTouchId() == true{
            authenticateTouchId()
        }
        registerForAPNS(application)
        
        if let launchOptions = launchOptions {
            if let userInfo = launchOptions["UIApplicationLaunchOptionsRemoteNotificationKey"] {
                if let apsInfo = userInfo["aps"] as? NSDictionary {
                    
                    
                        
                        if let receiverInfo = apsInfo["receiver"] as? NSDictionary {
                            
                            if let  roleInfo = receiverInfo["role"] as? NSDictionary {
                                self.hrFunction = roleInfo.valueForKey("hrFunction") as? String
                            }
                            
                        }
                    
                    
                    
                    if let content = apsInfo["content"] as? NSDictionary {
                        if let workItem = content["workItem"] as? NSDictionary {
                            if let id = workItem.valueForKey("_id") as? String  {
                                let approvalDetailController = UIStoryboard.Approvals().instantiateViewControllerWithIdentifier(String(TSApprovalDetailController)) as! TSApprovalDetailController
                                approvalDetailController.workItemId = id
                                let nc = UINavigationController.init(rootViewController: approvalDetailController)
                                nc.presentViewController(approvalDetailController, animated: true, completion: nil)
                            }
                        }
                        else if let workItem = content["timesheet"] as? NSDictionary {
                            let homeController = UIStoryboard.TimeSheet().instantiateViewControllerWithIdentifier(String(TSHomeController)) as! TSHomeController
                            if let startDate = workItem.valueForKey("startDate") as? String {
                                homeController.date = startDate
                            }
                            let nc = UINavigationController.init(rootViewController: homeController)
                            nc.presentViewController(homeController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        return true
    }
    
    func registerForAPNS(application: UIApplication) {
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Alert, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = kEmptyString
        
        for i in 0 ..< deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        let deviceToken = tokenString as String
        print(deviceToken)
        
        UserDefaults.setDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if (error.code == ErrorCode.SimulatorError.rawValue) {
            UserDefaults.setDeviceToken("simulator_token")
        }
        else {
            print(error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        if let aps = userInfo["aps"] as? NSDictionary {
            
            if let receiverInfo = userInfo["receiver"] as? NSDictionary {
                 
                if let  roleInfo = receiverInfo["role"] as? NSDictionary {
                    self.hrFunction = roleInfo.valueForKey("hrFunction") as? String
                }
                
            }
            
            
            if let content = userInfo["content"] as? NSDictionary {
                if let workItem = content["workItem"] as? NSDictionary {
                    if let id = workItem.valueForKey("_id") as? String
                    {
                        let approvalDetailController = UIStoryboard.Approvals().instantiateViewControllerWithIdentifier(String(TSApprovalDetailController)) as! TSApprovalDetailController
                        approvalDetailController.workItemId = id
                        if let topVC = getTopViewController() {
                            topVC.presentViewController(approvalDetailController, animated: true, completion: nil)
                        }
                    }
                }
                else if let workItem = content["timesheet"] as? NSDictionary {
                    let homeController = UIStoryboard.TimeSheet().instantiateViewControllerWithIdentifier(String(TSHomeController)) as! TSHomeController
                    if let startDate = workItem.valueForKey("startDate") as? String {
                        homeController.date = startDate
                    }
                    if let topVC = getTopViewController() {
                        topVC.presentViewController(homeController, animated: true, completion: nil)
                    }
                }
                else if let id = content.valueForKey("_id") as? String, status = content.valueForKey("status") as? String{
                    
                    let webViewController = WebViewController()
                    if let workitemId = content.valueForKey("workitemId") as? String {
                        webViewController.navTitleString = "Template Detail"
                        webViewController.isNavBarPresent = false
                        webViewController.url = "\(webURL)/template-detail-approval?templateid=\(id)&workitemid=\(workitemId)&status=\(status)"
                        controller.pushViewController(webViewController, animated: true)
                        
                    }
                    
                    
                }
                else if let temp = content.valueForKey("appraisalProcess") {
                   
                    if let id = temp.valueForKey("templateId") as? String, currentStage = temp.valueForKey("currentStage") as? String, fromDate = content.valueForKeyPath("appraisalProcess.evaluationPeriod.from") as? String , toDate = content.valueForKeyPath("appraisalProcess.evaluationPeriod.to") as? String   {
                        
                        let receiver = userInfo["receiver"] as? NSDictionary
                        let role = receiver?.valueForKey("role") as? NSDictionary
                        let hrFunc = role?.valueForKey("hrFunction") as? String
                        
                        let webViewController = WebViewController()
                        
                        webViewController.isNavBarPresent = false
                        
                        var appName:String = kEmptyString
                        if let uwAppName = temp.valueForKey("name") as? String {
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
                               // hrFunc = notification[indexPath.row].receiver?.hrFunction
                            }
                            webViewController.url = "\(webURL)/mobile/pms/pms-report?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                            }
                            
                        case "Target Settings" : webViewController.navTitleString = "Targets"
                        webViewController.cherryName = Cherries.ChampionScoreCard
                        webViewController.url = "\(webURL)/employee-target-fill-list?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                            
                        case "Target Approval" : webViewController.navTitleString = "Approvals"
                        webViewController.cherryName = Cherries.ChampionScoreCard
                        webViewController.url = "\(webURL)/mass-target-approvals?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                            
                        case "Achievement Update By RSA" : webViewController.navTitleString = "Achievements"
                        webViewController.cherryName = Cherries.ChampionScoreCard
                        webViewController.url = "\(webURL)/employee-achievement-fill-list?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                            
                        case "Achievement Review By Manager" : webViewController.navTitleString = "Approvals"
                        webViewController.cherryName = Cherries.ChampionScoreCard
                        webViewController.url = "\(webURL)/mass-achievement-approvals?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                            
                        case "Review and Update By Capability Team" : webViewController.navTitleString = "Scores"
                        webViewController.cherryName = Cherries.ChampionScoreCard
                        webViewController.url = "\(webURL)/employee-scores?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                            
                        case "Review By HR Office" : webViewController.navTitleString = "Template Detail"
                        webViewController.cherryName = Cherries.ChampionScoreCard
                        webViewController.url = "\(webURL)/employee-scores-approval-byhrofficer?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                            
                        case "KRA Inputs By Sales Admin" :webViewController.navTitleString = "Rework"
                        webViewController.cherryName = Cherries.PMS
                        webViewController.url = "http://hrapps.britindia.com/#/mobile/pms/mass-target-approvals?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                            
                        case "KRA Approval By Manager" :webViewController.navTitleString = "Target Approval"
                        webViewController.cherryName = Cherries.PMS
                        webViewController.url = "\(webURL)/mobile/pms/mass-target-approvals?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)&hrFunction=\(hrFunction)"
                            
                            
                        case "Achievement Input By Sales Admin" :webViewController.navTitleString = "Achievement Input"
                        webViewController.cherryName = Cherries.PMS
                        webViewController.url = "\(webURL)/mobile/pms/employee-achievements-upload?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                            
                        case "Self Assessment By Employee" :webViewController.navTitleString = "Self Assessment"
                        webViewController.cherryName = Cherries.PMS
                        webViewController.url = "\(webURL)/mobile/pms/tsi-annual-detail?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)&hrFunction=\(hrFunction)"
                            
                        case "Manager Assessment" :webViewController.navTitleString = "Assessment"
                        webViewController.cherryName = Cherries.PMS
                        webViewController.url = "\(webURL)/mobile/pms/employee-assesment-appovals?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)&hrFunction=\(hrFunction)"
                            
                            
                        case "HRBP Approval" :webViewController.navTitleString = "Approval HRBP"
                        webViewController.cherryName = Cherries.PMS
                        webViewController.url = "\(webURL)/mobile/pms/employee-drilldown-tree-data?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)&hrFunction=\(hrFunction)"
                            
                            
                        default: webViewController.navTitleString = "Template Detail"
                        webViewController.cherryName = Cherries.ChampionScoreCard
                        webViewController.url = "\(webURL)/employee-scores-approval-byrhrm?appname=\(appName)&tempid=\(id)&from=\(fromDate)&to=\(toDate)"
                            
                        }
                        
                        if let topVC = getTopViewController() {
                            webViewController.isPresented = true
                            let navController = UINavigationController(rootViewController: webViewController)
                            topVC.presentViewController(navController, animated: true, completion: nil)
                        }
                        
                        
                        
                    }
                }
                
                
                    
                    
                else if let onBoardingProcess = content.valueForKey("onBoardingProcess") {
                    
                    if let currentStage = onBoardingProcess.valueForKey("currentStage") as? String, formId = onBoardingProcess.valueForKey("formId"){
                        
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
                        webViewController.url = "\(webURL)mobile/onboarding/onboarding-checklist?id=\(formId)"
                          
                        case "hire" : webViewController.navTitleString = "Form Submission"
                        webViewController.cherryName = Cherries.Onboarding
                        webViewController.url = "\(webURL)/mobile/onboarding/onboarding-allList?id=\(formId)"
                            
                        default: webViewController.navTitleString = "Form Submission"
                        webViewController.cherryName = Cherries.Onboarding
                        webViewController.url = "\(webURL)mobile/onboarding/onboarding-checklist?id=\(formId)"
                            
                            
                        }
                        
                        if let topVC = getTopViewController() {
                            webViewController.isPresented = true
                            let navController = UINavigationController(rootViewController: webViewController)
                            topVC.presentViewController(navController, animated: true, completion: nil)
                        }
                        

                        
                    
                        
                    }
                    
                    
                }

                else if let updateRequisition = content.valueForKey("updateRequisition") {
                    
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    
                    if let requisitionId = updateRequisition.valueForKey("requisitionId"){
                        let nonBudgeted = "nonBudgeted"
                        webViewController.navTitleString = "Update"
                        webViewController.cherryName = Cherries.Recruitment
                        webViewController.url = "\(webURL)mobile/recruitment/update-non-budgeted-requisition?id=\(requisitionId)&subtype=\(nonBudgeted)"
                    }
                    
                    
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                    
                    
                }
                else if let requisition = content.valueForKey("requisition"){
                    let webViewController = WebViewController()
                    
                    
                        if let requisitionId = requisition.valueForKey("requisitionId"){
                            webViewController.navTitleString = "Requisition"
                            webViewController.cherryName = Cherries.Recruitment
                            webViewController.url = "\(webURL)/mobile/recruitment/recruitment-description?id=\(requisitionId)"
                        }
                        
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                    
                }
                
                
                else if let requisition = content.valueForKey("sourceRequisition"){
                    let webViewController = WebViewController()
                    
                    
                    if let requisitionId = requisition.valueForKey("requisitionId"){
                        
                            webViewController.navTitleString = "Requisition"
                            webViewController.cherryName = Cherries.Recruitment
                            webViewController.url = "\(webURL)/mobile/recruitment/recruitment-sourcing?id=\(requisitionId)"
                            
                        
                    }
                    
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                    
                }
                    
                else if let scheduleInterview = content.valueForKey("scheduleInterview"){
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    
                            if let requisitionId = scheduleInterview.valueForKey("requisitionId"){
                                webViewController.navTitleString = "Schedule Interview"
                                webViewController.cherryName = Cherries.Recruitment
                                webViewController.url = "\(webURL)mobile/recruitment/recruitment-newapplicants?id=\(requisitionId)"
                            }
                            
                    
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                    
                    
                    
                }
                    
                else if let temp = content.valueForKey("postIJP"){ //|| notification[indexPath.row].applicationType == "postER"){
                    
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    webViewController.navTitleString = "Recruitment"
                    webViewController.cherryName = Cherries.Recruitment
                    webViewController.url = "\(webURL)mobile/recruitment/IJP"
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                    
                }
                    
                else if let temp = content.valueForKey("postER"){
                    
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    webViewController.navTitleString = "Recruitment"
                    webViewController.cherryName = Cherries.Recruitment
                    webViewController.url = "\(webURL)mobile/recruitment/IJP"
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                    
                }

                    
                else if let interviewFeedback = content.valueForKey("interviewFeedback"){
                    
                    let webViewController = WebViewController()
                    
                    
                    if let requisitionId = interviewFeedback.valueForKey("requisitionId"), applicationId = interviewFeedback.valueForKey("applicationId"),candidate = interviewFeedback.valueForKey("candidate"){
                        let email = candidate.valueForKey("emailId")
                        webViewController.navTitleString = "Feedback"
                        webViewController.cherryName = Cherries.Recruitment
                        webViewController.url = "\(webURL)mobile/recruitment/shortlistdetails?id=\(requisitionId)&applicationId=\(applicationId)&email=\(email!)"
                    }
                    
                    
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                    
                }
                    
                else if let profileEvaluation = content.valueForKey("profileEvaluation"){
                    
                    let webViewController = WebViewController()
                    
                    
                    let candidate = profileEvaluation.valueForKey("candidate")
                    if let requisitionId = profileEvaluation.valueForKey("requisitionId"), applicationId = profileEvaluation.valueForKey("applicationId"), email = candidate?.valueForKey("emailId"){
                        webViewController.navTitleString = "Profile Evaluation"
                        webViewController.cherryName = Cherries.Recruitment
                        webViewController.url = "\(webURL)/mobile/recruitment/recruitment-candidatedetailview?id=\(requisitionId)&applicationId=\(applicationId)&email=\(email)"
                    }
                    
                    
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                    
                }
                    
                else if let applicationEvaluation = content.valueForKey("applicationEvaluation"){
                    
                    let webViewController = WebViewController()
                    
                    
                    let candidate = applicationEvaluation.valueForKey("candidate")
                    if let requisitionId = applicationEvaluation.valueForKey("requisitionId"), applicationId = applicationEvaluation.valueForKey("applicationId"), email = candidate?.valueForKey("emailId"){
                        webViewController.navTitleString = "Application Evaluation"
                        webViewController.cherryName = Cherries.Recruitment
                        webViewController.url = "\(webURL)/mobile/recruitment/shortlistdetails?id=\(requisitionId)&applicationId=\(applicationId)&email=\(email)"
                    }
                    
                    
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                    
                }
                    
                    
                else if let applicationEvaluation = content.valueForKey("uploadDocuments"){
                    
                    let webViewController = WebViewController()
                    
                    if let requisitionId = applicationEvaluation.valueForKey("requisitionId"), applicationId = applicationEvaluation.valueForKey("applicationId"), email = applicationEvaluation.valueForKey("candidateEmail"){
                        webViewController.navTitleString = "Documents Upload"
                        webViewController.cherryName = Cherries.Recruitment
                        webViewController.url = "\(webURL)/mobile/recruitment/shortlistdetails?id=\(requisitionId)&applicationId=\(applicationId)&email=\(email)"
                    }
                    
                    
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                    
                }
                    
                    
                else if let interviewFeedback = content.valueForKey("approveRequisition"){
                    
                }
                    
                else if let temp = content.valueForKey("offerRollout"){
                    
                    let roles = UserDefaults.userRole()
                    let object = roles["Recruitment"]!
                    let role = object.first!["name"] as? String
                    
                    if role == "COMPLEAD"{
                        //   dismissViewControllerAnimated(false, completion: nil)
                    }
                    else if role == "HRBP"{
                        
                        let webViewController = WebViewController()
                        
                        webViewController.isNavBarPresent = false
                        
                        
                        webViewController.navTitleString = "Offers"
                        webViewController.cherryName = Cherries.Recruitment
                        webViewController.url = "\(webURL)mobile/recruitment/offered"
                        
                        if let topVC = getTopViewController() {
                            webViewController.isPresented = true
                            let navController = UINavigationController(rootViewController: webViewController)
                            topVC.presentViewController(navController, animated: true, completion: nil)
                        }
                        
                    }
                    
                }
                    
                else if let generateOffer = content.valueForKey("generateOffer"){
                    
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    
                    if let offerId = generateOffer.valueForKey("offerId"){
                        webViewController.navTitleString = "Schedule Interview"
                        webViewController.cherryName = Cherries.Recruitment
                        webViewController.url = "\(webURL)mobile/recruitment/recruitment-offereddetail?Cid=\(offerId)"
                    }
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                    
                }

                
                
                else if let appraisalTemplate = content.valueForKey("appraisalTemplate") {
                    
                    let webViewController = WebViewController()
                    if let workitemId = appraisalTemplate.valueForKey("workitemId") as? String, id = appraisalTemplate.valueForKey("_id") as? String, status  = appraisalTemplate.valueForKey("status") as? String {
                        webViewController.navTitleString = "Template Detail"
                        webViewController.isNavBarPresent = false
                        webViewController.isPushBased = true
                        webViewController.cherryName = Cherries.PMS
                        webViewController.url = "\(webURL)/mobile/csc/template-detail-approval?templateid=\(id)&workitemid=\(workitemId)&status=\(status)"
                        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                        let nav1 = UINavigationController()
                        firstViewController = FirstViewController()
                        nav1.viewControllers = [firstViewController!, webViewController]
                        self.window!.rootViewController = nav1
                        self.window?.makeKeyAndVisible()

                    }
                    
                    
                }}
                else if let body = userInfo["body"]{
                    if let type = body.valueForKey("applicationType"){
                    if type as! String  == "Info Process" {

                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = true
                    
                    if let cont = body.valueForKey("content"){
                        if  let leaveProcess = cont.valueForKey("leaveProcess"){
                            if let leaveId = leaveProcess.valueForKey("leaveID"){
                        webViewController.navTitleString = "Info Process"
                        webViewController.cherryName = Cherries.Leave
                        webViewController.url = "\(webURL)/mobile/leave/approval?id=\(leaveId)"
                            }
                        }
                    }
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                }
                else if type as! String == "Cancel Process" {
                    
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = true
                        
                    if let cont = body.valueForKey("content"){
                    if let leaveProcess = cont.valueForKey("leaveProcess"){
                        if let leaveId = leaveProcess.valueForKey("leaveID"){
                        webViewController.navTitleString = "Cancel Process"
                        webViewController.cherryName = Cherries.Leave
                        webViewController.url = "\(webURL)/mobile/leave/approval?id=\(leaveId)"
                        }
                    }
                        }
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                }
                else if type as! String == "Approval Process"{
                    
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = true
                    
                        if let cont = body.valueForKey("content"){
                            if let leaveProcess = cont.valueForKey("leaveProcess"){
                                if let leaveId = leaveProcess.valueForKey("leaveID"){
                        webViewController.navTitleString = "Approval Process"
                        webViewController.cherryName = Cherries.Leave
                        webViewController.url = "\(webURL)/mobile/leave/approval?id=\(leaveId)"
                                }
                            }
                    }
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                }
                else if type as! String == "Reject Process"{
                    
                    let webViewController = WebViewController()
                    
                    webViewController.isNavBarPresent = false
                    
                    if let cont = body.valueForKey("content"){
                        if let leaveProcess = cont.valueForKey("leaveProcess"){
                            if let leaveId = leaveProcess.valueForKey("leaveID"){
                        webViewController.navTitleString = "Reject Process"
                        webViewController.cherryName = Cherries.Leave
                        webViewController.url = "\(webURL)/mobile/leave/detail/\(leaveId)"
                            }
                    }
                    if let topVC = getTopViewController() {
                        webViewController.isPresented = true
                        let navController = UINavigationController(rootViewController: webViewController)
                        topVC.presentViewController(navController, animated: true, completion: nil)
                    }
                        }
                    }
                else if type as! String == "Approval Response"{
                        
                        let webViewController = WebViewController()
                        
                        webViewController.isNavBarPresent = false
                        
                        if let cont = body.valueForKey("content"){
                            if let leaveProcess = cont.valueForKey("leaveProcess"){
                                if let leaveId = leaveProcess.valueForKey("leaveID"){
                                    webViewController.navTitleString = "Approval Response"
                                    webViewController.cherryName = Cherries.Leave
                                    webViewController.url = "\(webURL)/mobile/leave/detail/\(leaveId)"
                                }
                            }
                            if let topVC = getTopViewController() {
                                webViewController.isPresented = true
                                let navController = UINavigationController(rootViewController: webViewController)
                                topVC.presentViewController(navController, animated: true, completion: nil)
                            }
                        }
                        }
                
            }
            
        }
    }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if UserDefaults.isSetTouchId() == true{
            authenticateTouchId()
        }
    }
    
    func errorMessageForLAErrorCode( errorCode:Int ) -> String{
        
        var message = ""
        
        switch errorCode {
            
            //    case LAError.AppCancel.rawValue:
            //        message = "Authentication was cancelled by application"
            
        case LAError.AuthenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            //    case LAError.InvalidContext.rawValue:
            //        message = "The context is invalid"
            
        case LAError.PasscodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.SystemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if UserDefaults.isSetTouchId() == true {
                    self.authenticateTouchId()
                }
                
            }
            //    case LAError.TouchIDLockout.rawValue:
            //        message = "Too many failed attempts."
            
        case LAError.TouchIDNotAvailable.rawValue:
            message = "TouchID is not available on the device"
            
        case LAError.UserCancel.rawValue:
            message = "The user did cancel"
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if UserDefaults.isSetTouchId() == true {
                    self.authenticateTouchId()
                }
            }
            
        case LAError.UserFallback.rawValue:
            message = "The user chose to use the fallback"
            // here
            
            
        default:
            message = "Authentication was cancelled by application"
            
        }
        print(message)
        return message
        
    }
    
    func authenticateTouchId(){
        if UserDefaults.isConfigured() == true && UserDefaults.accessToken() != nil  {
            // 1. Create a authentication context
            
            var error:NSError?
            
            // 2. Check if the device has a fingerprint sensor
            // If not, show the user an alert view and bail out!
            if #available(iOS 9.0, *) {
                let time:NSTimeInterval = 5
                authenticationContext.touchIDAuthenticationAllowableReuseDuration = time
                guard authenticationContext.canEvaluatePolicy(.DeviceOwnerAuthentication, error: &error) else {
                    
                    print("device doesnt support touchId")
                    return
                    
                }
            } else {
                // Fallback on earlier versions
            }
            
            // 3. Check the fingerprint
            if #available(iOS 9.0, *) {
                authenticationContext.evaluatePolicy(
                    .DeviceOwnerAuthentication,
                    localizedReason: "Unlock using fingerprint",
                    reply: { [unowned self] (success, error) -> Void in
                        
                        if( success ) {
                            // Fingerprint recognized
                            // Go to view controller
                            //                            self.firstViewController?.launchTabBarController()
                            
                        }else {
                            
                            // Check if there is an error
                            if let error = error {
                                print(error.localizedDescription)
                                _ = self.errorMessageForLAErrorCode(error.code)
                                
                                // self.showAlertViewAfterEvaluatingPolicyWithMessage(message)
                                print("Error")
                            }
                            
                        }
                        
                    })
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "in.cherrywork.Workbox" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Workbox", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}

