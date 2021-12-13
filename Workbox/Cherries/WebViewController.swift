//
//  WebViewController.swift
//  Workbox
//
//  Created by Ratan D K on 27/04/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Foundation


//let cookieDomain : String = "myhr.britindia.com"// Prod
let cookieDomain : String = "hrapps.britindia.com" // QA
//let cookieDomain : String = "dev.cherrywork.in" // Dev
//let webURL = "http://myhr.britindia.com/#" //Prod  today
let webURL = "http://hrapps.britindia.com/#" // QA
//let webURL = "http://dev.cherrywork.in:7023/#" // Dev



class WebViewController: UIViewController {
    
    var webView: UIWebView?
    var url: String?
    var cherryName: Cherries?
    var sideMenuController: SideMenuController?
    var sideMenuURLs: [String]? = nil
    var currentMenuIndexPath : NSIndexPath = NSIndexPath()
    var currentMenuIndex: Int = -1
    var backButtonItem: UIBarButtonItem?
    var isNavBarPresent : Bool = true
    var navTitleString : String = "Dashboard"
    var isLaunchFromAppraisal : Bool = false
    var isPushBased : Bool = false
    var isPresented : Bool = false
    var multipleRole : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        createNavBar()
        createWebView()
        setCookies()
        
       // let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies
        
        if let urlString = url {
            //            let request = NSURLRequest.init(URL: NSURL.init(string: urlString)!)
            //let urlwithPercentEscapes = urlString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())

            let request = NSMutableURLRequest.init(URL: NSURL.init(string: urlString)!)
            print(urlString)
            webView?.loadRequest(request)
        }
    }
    func loadWebView(){
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
    }
    
    func createNavBar() {
        navigationItem.title = navTitleString ?? kEmptyString
        
        self.navigationController?.setupNavigationBar()
        let menuItem = UIBarButtonItem.init(image: UIImage.init(named: "sideNav"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(showSideMenu))
        backButtonItem = UIBarButtonItem.init(image: AssetImage.backArrow.image, style: .Plain, target: self, action: #selector(backTapped))
        let cancelItem = UIBarButtonItem.init(title: "Cancel", style: .Plain, target: self, action: #selector(WebViewController.dismissController))
        
        if isNavBarPresent == true {
            navigationItem.leftBarButtonItems = [backButtonItem!, menuItem]
            navigationItem.rightBarButtonItem = cancelItem
        }
        else {
            backButtonItem = UIBarButtonItem.init(image: AssetImage.backArrow.image, style: .Plain, target: self, action: #selector(backTapped))
            navigationItem.leftBarButtonItems = [backButtonItem!]
        }
    }
    
    func backTapped() {
        if webView?.canGoBack == true {
            webView?.goBack()
        }
        else {
            dismissController()
        }
    }
    
    func dismissController() {
        if isPushBased {
            exit(0)
        }
        if( isPresented == false)
        {
            self.navigationController?.popViewControllerAnimated(true)
        }
        else{
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        
    }
    
    func setCookies() {
        NSHTTPCookieStorage.sharedHTTPCookieStorage().cookieAcceptPolicy = .Always
        
        var object = [NSMutableDictionary]()
        var name : String!
        var region : String!
        var cherry : String!
        var hrFunction : String!
    
        let idCookieDict = [NSHTTPCookieName: "id",
                               NSHTTPCookieValue: UserDefaults.getId(),
                               NSHTTPCookieDomain: cookieDomain,
                               NSHTTPCookiePath: "/",
                               ]
        let positionCookieDict = [NSHTTPCookieName: "position",
                                  NSHTTPCookieValue: UserDefaults.getPosition(),
                                  NSHTTPCookieDomain: cookieDomain,
                                  NSHTTPCookiePath: "/",
                                  ]
        
        let tokenCookieDict = [NSHTTPCookieName: "token",
                               NSHTTPCookieValue: UserDefaults.accessToken()!,
                               NSHTTPCookieDomain: cookieDomain,
                               NSHTTPCookiePath: "/",
                               ]
        
        let emailCookieDict = [NSHTTPCookieName: "email",
                               NSHTTPCookieValue: UserDefaults.loggedInEmail()!,
                               NSHTTPCookieDomain: cookieDomain,
                               NSHTTPCookiePath: "/",
                               ]
        
        let userIdCookieDict = [NSHTTPCookieName: "myid",
                                NSHTTPCookieValue: UserDefaults.userId()!,
                                NSHTTPCookieDomain: cookieDomain,
                                NSHTTPCookiePath: "/",
                                ]
        
        let info = UserDefaults.getManagerInfo()
        
        let jsonData = try? NSJSONSerialization.dataWithJSONObject(info, options: NSJSONWritingOptions.init(rawValue: 0))

//        let jsonData = try? JSONSerialization.data(withJSONObject: UserDefaults.getManagerInfo(), options: [])
        let jsonString = String.init(data: jsonData!, encoding: NSUTF8StringEncoding)
        
        let managerCookieDict = [NSHTTPCookieName: "manager",
                                NSHTTPCookieValue: jsonString!,
                                NSHTTPCookieDomain: cookieDomain,
                                NSHTTPCookiePath: "/",
        ]
        
        let roles = UserDefaults.userRole()
        let message = "Data not found"
        
        switch cherryName! {
            
        case .ChampionScoreCard:
            
            if roles["Champion Score Card"] == nil
            {
                let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                return;
                //break;
            }
            object = roles["Champion Score Card"]!
            
            if( object.count != 0 )
            {

                if(currentMenuIndex != -1)
                {
                    name = object[currentMenuIndex]["name"] as! String
                    region = object[currentMenuIndex]["region"] as! String
                }
                else{
                    name = object.first!["name"] as! String
                    region = object.first!["region"] as! String
                }
                hrFunction = "undefined"
                if region == nil{
                    region = UserDefaults.userRegion()
                }
                cherry = "csc"
            }
            else
            {
                name = "undefined"
                region = UserDefaults.userRegion()
                hrFunction = "undefined"
                cherry = "csc"
                
            }
            
            break
            
        case .PMS:
            
            if roles["Performance Management System"] == nil
            {
                let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                return;
                //break;
            }
            object = roles["Performance Management System"]!
            if( object.count != 0 )
            {
                print(object)
                if(currentMenuIndex != -1)
                {
                    name = object[currentMenuIndex]["name"] as! String
                    region = object[currentMenuIndex]["region"] as! String
                    if( object[currentMenuIndex]["hrFunction"] != nil){
                        hrFunction = object[currentMenuIndex]["hrFunction"] as! String
                    }
                    else{
                        hrFunction = "undefined"
                    }
                }
                else{
                    name = object.first!["name"] as! String
                    region = object.first!["region"] as! String
                    if( object.first!["hrFunction"] != nil){
                        hrFunction = object.first!["hrFunction"] as! String
                    }
                    else{
                        hrFunction = "undefined"
                    }
                }

           
                if region == nil{
                   region = UserDefaults.userRegion()
                }
                cherry = "pms"
            }
            else
            {
                name = "undefined"
                region = UserDefaults.userRegion()
                hrFunction = "undefined"
                cherry = "pms"
                
            }
            
            break

            
        case .LMS:
            
            if roles["Learning Management System"] == nil
            {
                let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                return;
                //break;
            }
            object = roles["Learning Management System"]!
            if( object.count != 0 )
            {
                if(currentMenuIndex != -1)
                {
                    name = object[currentMenuIndex]["name"] as! String
                    region = object[currentMenuIndex]["region"] as! String
                }
                else{
                    name = object.first!["name"] as! String
                    region = object.first!["region"] as! String
                }
                hrFunction = "undefined"
                if region == nil{
                    region = UserDefaults.userRegion()
                }
                cherry = "lms"
            }
            else
            {
                name = "undefined"
                region = UserDefaults.userRegion()
                hrFunction = "undefined"
                cherry = "lms"
                
            }
            
            break

        case .Recruitment:
            if roles["Recruitment"] == nil
            {
                let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                return;
                //break;
            }
            object = roles["Recruitment"]!
            if( object.count != 0 )
            {
                if(currentMenuIndex != -1)
                {
                    name = object[currentMenuIndex]["name"] as! String
                    region = object[currentMenuIndex]["region"] as! String
                }
                else{
                    name = object.first!["name"] as! String
                    region = object.first!["region"] as! String
                }
                hrFunction = "undefined"
                if region == nil{
                    region = UserDefaults.userRegion()
                }
                cherry = "rec"
            }
            else
            {
                name = "undefined"
                region = UserDefaults.userRegion()
                hrFunction = "undefined"
                cherry = "rec"
                
            }
            
                break

        case .Onboarding:
            if roles["On Boarding"] == nil
            {
                let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                return;
                //break;
            }
            object = roles["On Boarding"]!
            if( object.count != 0 )
            {
                if(currentMenuIndex != -1)
                {
                    name = object[currentMenuIndex]["name"] as! String
                    region = object[currentMenuIndex]["region"] as! String
                }
                else{
                    name = object.first!["name"] as! String
                    region = object.first!["region"] as! String
                }
                hrFunction = "undefined"
                if region == nil{
                    region = UserDefaults.userRegion()
                }
                hrFunction = "undefined"
                cherry = "onBoarding"
            }
            else
            {
                name = "undefined"
                region = UserDefaults.userRegion()
                hrFunction = "undefined"
                cherry = "onboarding"
                
            }
                break
        case .Leave:


//            object = roles["On Boarding"]!
//            if( object.count != 0 )
//            {
//                if(currentMenuIndex != -1)
//                {
//                    name = object[currentMenuIndex]["name"] as! String
//                    region = object[currentMenuIndex]["region"] as! String
//                }
//                else{
//                    name = object.first!["name"] as! String
//                    region = object.first!["region"] as! String
//                }
//                hrFunction = "undefined"
//                if region == nil{
//                    region = UserDefaults.userRegion()
//                }
//                hrFunction = "undefined"
//                cherry = "onBoarding"
//            }
//            else
//            {
//                name = "undefined"
//                region = UserDefaults.userRegion()
//                hrFunction = "undefined"
//                cherry = "onboarding"
//
            hrFunction = "undefined"
            cherry = "leave"
            region = "undefined"
            if let leaveRoles = UserDefaults.getLeaveroles() as? NSMutableDictionary{
            name = leaveRoles.valueForKey("name") as! String
                multipleRole = false
            }
            navTitleString = "Approvals"
            break
            
        case .DevelopmentConversations:
            
            if roles["Development Conversations"] == nil
            {
                let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                return;
                //break;
            }
            object = roles["Development Conversations"]!
            if( object.count != 0 )
            {
                if(currentMenuIndex != -1)
                {
                    name = object[currentMenuIndex]["name"] as! String
                    region = object[currentMenuIndex]["region"] as! String
                }
                else{
                    name = object.first!["name"] as! String
                    region = object.first!["region"] as! String
                }
                hrFunction = "undefined"
                if region == nil{
                    region = UserDefaults.userRegion()
                }
                cherry = "Dev"
            }
            else
            {
                name = "undefined"
                region = UserDefaults.userRegion()
                hrFunction = "undefined"
                cherry = "Dev"
                
            }
            
            break
        case .EBAT :
            
            if roles["e-BAT"] == nil
            {
                let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction.init(title: NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                return;
                //break;
            }
            object = roles["e-BAT"]!
            if( object.count != 0 )
            {
                if(currentMenuIndex != -1)
                {
                    name = object[currentMenuIndex]["name"] as! String
                    region = object[currentMenuIndex]["region"] as! String
                }
                else{
                    name = object.first!["name"] as! String
                    region = object.first!["region"] as! String
                }
                hrFunction = "undefined"
                if region == nil{
                    region = UserDefaults.userRegion()
                }
                cherry = "Dev"
            }
            else
            {
                name = "undefined"
                region = UserDefaults.userRegion()
                hrFunction = "undefined"
                cherry = "Dev"
                
            }
            

            
            break
      
            
        }
       // let roleNameCookieDict : NSDictionary
       // let regionNameCookieDict : NSDictionary
        var nameCookieValue : String!
        var regionCookieValue : String!
        if (sideMenuController?.currentIndex.row == nil || !multipleRole) {
            
            nameCookieValue = name
            regionCookieValue = region
            
            }else{
            
            
            let header:String = (sideMenuController?.sectionHeader[sideMenuController!.currentIndex.section])!
            var sectionHeaderArr = header.componentsSeparatedByString("-")
            let name: String = sectionHeaderArr[0]
            let region: String? = sectionHeaderArr[1]
            let trimmedName = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let trimmedRegion = region!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            nameCookieValue = trimmedName
            regionCookieValue = trimmedRegion
    
        }
        let roleNameCookieDict = [NSHTTPCookieName: "roleName",
                                  NSHTTPCookieValue: nameCookieValue,
                                  NSHTTPCookieDomain: cookieDomain,
                                  NSHTTPCookiePath: "/",
                                  ]
        
        let regionNameCookieDict = [NSHTTPCookieName: "regionName",
                                    NSHTTPCookieValue: regionCookieValue,
                                    NSHTTPCookieDomain: cookieDomain,
                                    NSHTTPCookiePath: "/",
                                    ]


        
        let cherrySelectedCookieDict = [NSHTTPCookieName: "cherrySelected",
                                NSHTTPCookieValue: cherry,
                                NSHTTPCookieDomain: cookieDomain,
                                NSHTTPCookiePath: "/",
                                ]
        
        let userHrFunctionCookieDict = [NSHTTPCookieName: "userhrFunction",
                                        NSHTTPCookieValue: hrFunction,
                                        NSHTTPCookieDomain: cookieDomain,
                                        NSHTTPCookiePath: "/",
                                        ]
        let nameCookieDict = [NSHTTPCookieName: "name",
                                        NSHTTPCookieValue: nameCookieValue!,
                                        NSHTTPCookieDomain: cookieDomain,
                                        NSHTTPCookiePath: "/",
                                        ]

        let matrixCookieDict = [NSHTTPCookieName: "matrixManager",
                              NSHTTPCookieValue: "true",
                              NSHTTPCookieDomain: cookieDomain,
                              NSHTTPCookiePath: "/",
                              ]
        
        let tokenCookie = NSHTTPCookie.init(properties: tokenCookieDict)
        let emailCookie = NSHTTPCookie.init(properties: emailCookieDict)
        let cherrySelectedCookie = NSHTTPCookie.init(properties: cherrySelectedCookieDict)
        let userIdCookie = NSHTTPCookie.init(properties: userIdCookieDict)
        let matrixCookieDictCookie = NSHTTPCookie.init(properties: matrixCookieDict)
       
        
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(tokenCookie!)
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(emailCookie!)
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cherrySelectedCookie!)
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(userIdCookie!)
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(matrixCookieDictCookie!)
        
        if cherryName?.displayString == "Leave Application"{
            
            let managerInfoCookie = NSHTTPCookie.init(properties: managerCookieDict)
            let idCookie = NSHTTPCookie.init(properties: idCookieDict)
            //let nameCookie = NSHTTPCookie.init(properties: nameCookieDict)
            
            NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(idCookie!)
            
            NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(managerInfoCookie!)
            
            NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(matrixCookieDictCookie!)
        }
        else{
            
        let roleNameCookie = NSHTTPCookie.init(properties: roleNameCookieDict ) //as! [String : AnyObject]

        let regionNameCookie = NSHTTPCookie.init(properties: regionNameCookieDict ) //as! [String : AnyObject]
    
        let hrFunctionCookie = NSHTTPCookie.init(properties: userHrFunctionCookieDict)
        
        let positionCookie = NSHTTPCookie.init(properties: positionCookieDict)
            
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(roleNameCookie!)

        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(regionNameCookie!)
        
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(hrFunctionCookie!)
            
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(positionCookie!)
        }
        
        
        
    }
    
    func createWebView() {
        webView = nil
        webView = UIWebView.init(frame: view.bounds)
        webView?.opaque = false
        webView?.backgroundColor = UIColor.whiteColor()
        webView?.scrollView.contentInset = UIEdgeInsetsMake(UIApplication.sharedApplication().statusBarFrame.size.height + 42, 0, 0, 0)
        view.addSubview(webView!)
        webView?.delegate = self
    }
    
    func showSideMenu( sender : UIBarButtonItem) {
        
        sideMenuController = UIStoryboard.TimeSheet().instantiateViewControllerWithIdentifier(String(SideMenuController)) as? SideMenuController
        let roles = NSUserDefaults.standardUserDefaults().dictionaryForKey("kUserRole")

        print(cherryName)
        switch cherryName! {
            //        case CherryName.Leave.rawValue:
            //            sideMenuController?.items = ["Dashboard", "Holidays", "Summary", "On-Duty"]
            
        case .ChampionScoreCard:
            let object = roles!["Champion Score Card"] as! [NSMutableDictionary]
            sideMenuController!.sectionCount = (object.count)
            var temp = [String]()
            if object.count == 1{
                multipleRole = false
                switch object.first!["name"]! as! String{
                    
                case "SDM1" :temp = ["Appraisals", "Templates", "Criterions","Reports"]
                    sideMenuController?.items[0] = temp
                    
                case "VPSA", "VPHR" : temp = ["Appraisals", "Approvals","Reports"]
                    sideMenuController?.items[0] = temp
                case "manager", "SA", "HRO", "RHRM", "RSM" : temp = ["Appraisals","Reports"]
                    sideMenuController?.items[0] = temp
                case "SDM2",
                     "CSCMGR",
                     "HROPSM",
                     "HRBP-S",
                     "NSDM" : temp = ["Appraisals","Reports"]
                    sideMenuController?.items[0] = temp
                    
                case "TSI" : temp = ["Score Card"]
                    sideMenuController?.items[0] = temp
                    
                default : temp = ["Appraisals"]
                sideMenuController?.items[0] = temp
                    
                }
            }else if object.count >= 2{
                
                multipleRole = true
                var sectionTitleArray: [String] = []
                var sectionCount = 0
                for item in object{
                    sectionTitleArray.append("\(item["name"] ?? "") - \(item["region"] ?? "")")
                    
                 //   switch object!.first!["name"]!{
                    switch item["name"]! as! String{
                        
                    case "SDM1" :temp = ["Appraisals", "Templates", "Criterions","Reports"]
                    sideMenuController?.items[sectionCount] = temp
                        
                    case "VPSA", "VPHR" : temp = ["Appraisals", "Approvals","Reports"]
                    sideMenuController?.items[sectionCount] = temp
                    case "manager", "SA", "HRO", "RHRM", "RSM" : temp = ["Appraisals","Reports"]
                    sideMenuController?.items[sectionCount] = temp
                    case "SDM2",
                         "CSCMGR",
                         "HROPSM",
                         "HRBP-S",
                         "NSDM" : temp = ["Appraisals","Reports"]
                         sideMenuController?.items[sectionCount] = temp
                        
                    case "TSI" : temp = ["Score Card"]
                    sideMenuController?.items[sectionCount] = temp
                        
                    default : temp = ["Appraisals"]
                    sideMenuController?.items[sectionCount] = temp
                    }
                    sectionCount += 1
                }
                sideMenuController?.sectionHeader = sectionTitleArray
            }
        case .PMS:
            let object = roles!["Performance Management System"] as! [NSMutableDictionary]
            var temp = [String]()
            sideMenuController!.sectionCount = (object.count)
            
            if object.count == 1{
                multipleRole = false
                switch object.first!["name"]! as! String{
                    
                case "VPSA","VPHR" : temp = ["Approvals"]
                    sideMenuController?.items[0] = temp
                    
                case "ADMIN" : temp = ["Appraisals","Templates","Criterions","Scale settings","Launch Filter Settings","Employee Status Report"]
                    sideMenuController?.items[0] = temp
                    
                case "TSI" : temp = ["Annual Appraisal"]
                    sideMenuController?.items[0] = temp
                
                case "SA","manager","RSM","HRBP" : temp = ["Appraisals"]
                sideMenuController?.items[0] = temp
                    
                default : temp = ["Appraisals"]
                sideMenuController?.items[0] =  temp
                }
            }else if object.count >= 2{
                
                multipleRole = true
                var sectionTitleArray: [String] = []
                var sectionCount = 0
                for item in object{
                    if(item["hrFunction"] != nil)
                    {
                        sectionTitleArray.append("\(item["name"] ?? "") - \(item["region"] ?? "") - \(item["hrFunction"] ?? "")")
                    }
                    else
                    {
                        
                        sectionTitleArray.append("\(item["name"] ?? "") - \(item["region"] ?? "")")
                    }
                    switch item["name"]! as! String{
                        
                    case "VPSA","VPHR" : temp = ["Approvals"]
                    sideMenuController?.items[sectionCount] = temp
                        
                    case "ADMIN" : temp = ["Appraisals","Templates","Criterions","Scale settings","Launch Filter Settings","Employee Status Report"]
                    sideMenuController?.items[sectionCount] = temp
                        
                    case "TSI" : temp = ["Annual Appraisal"]
                    sideMenuController?.items[sectionCount] = temp
                        
                    case "SA","manager","RSM","HRBP" : temp = ["Appraisals"]
                    sideMenuController?.items[sectionCount] = temp

                        
                    default : temp = ["Appraisals"]
                    sideMenuController?.items[sectionCount] =  temp
                    }
                    sectionCount += 1
                }
                sideMenuController?.sectionHeader = sectionTitleArray
            }
            
        case .Onboarding:
            let object = roles!["On Boarding"] as! [NSMutableDictionary]
            var temp = [String]()
            sideMenuController!.sectionCount = (object.count)
            
            if object.count == 1{
                multipleRole = false
                switch object.first!["name"]! as! String{
                    
                case "OBTEAM" : temp = ["Dashboard","SLA","List","Hire"]
                sideMenuController?.items[0] = temp
                    
                case "OBADMIN" : temp = ["Dashboard","SLA","List","Hire"]
                sideMenuController?.items[0] = temp
                    
                case "ADMIN" : temp = ["Dashboard"]
                    sideMenuController?.items[0] = temp
                    
                case "HRBP" : temp = ["Dashboard"]
                    
                    sideMenuController?.items[0] = temp
                    
                default : break
                }
            }else if object.count >= 2{
                
                multipleRole = true
                var sectionTitleArray: [String] = []
                var sectionCount = 0
                for item in object{
                    sectionTitleArray.append("\(item["name"] ?? "") - \(item["region"] ?? "")")
                    
                    switch item["name"]! as! String{
                        
                    case "OBTEAM" : temp = ["Dashboard","SLA","List","Hire"]
                    sideMenuController?.items[sectionCount] = temp
                        
                    case "OBADMIN" : temp = ["Dashboard","SLA","List","Hire"]
                    sideMenuController?.items[sectionCount] = temp

                        
                    default : break
                    }
                    sectionCount += 1
                }
                sideMenuController?.sectionHeader = sectionTitleArray
            }

        case .Recruitment :
            let object = roles!["Recruitment"] as! [NSMutableDictionary]
            var temp = [String]()
            sideMenuController!.sectionCount = (object.count)
            
            if object.count == 1{
                multipleRole = false
                switch object.first!["name"]! as! String{
                    
                case "HRBP", "HEADHR", "COMPOFFICER" : temp = ["Requisitions","Offered","Turn Around Time","My Tasks","IJP"]
                sideMenuController?.items[0] = temp
                    
                case "employee" : temp = ["My Task","IJP"]
                sideMenuController?.items[0] = temp
                    
                    
                case "Recruiter" : temp = ["Requisitions","Offered","Turn Around Time","My Tasks","IJP","Candidates"]
                    
                    sideMenuController?.items[0] = temp
                    
                case "RECADMIN" : temp = ["Requisitions","Offered","Turn Around Time","Candidates","Proxy-User-Access","Candidates","Upload & Delete JD","Placement Agencies"]
                    
                    sideMenuController?.items[0] = temp
                    
                 
                    
                    
                default : break
                }
            }else if object.count >= 2{
                
                multipleRole = true
                var sectionTitleArray: [String] = []
                var sectionCount = 0
                for item in object{
                    sectionTitleArray.append("\(item["name"] ?? "") - \(item["region"] ?? "")")
                    
                    switch item["name"]! as! String{
                        
                    case "HRBP", "COMPOFFICER" :
                    temp = ["Requisitions","Offered","Turn Around Time","My Tasks","IJP"]
                    sideMenuController?.items[sectionCount] = temp
                        
                   case "employee" : temp = ["My Task","IJP"]
                    sideMenuController?.items[sectionCount] = temp
                        
                    case "Recruiter" : temp = ["Requisitions","Offered","Turn Around Time","My Tasks","IJP","Candidates"]
                    
                    sideMenuController?.items[sectionCount] = temp
                        
                    case "RECADMIN" : temp = ["Requisitions","Offered","Turn Around Time","Candidates","Proxy-User-Access","Upload & Delete JD","Placement Agencies"]
                    
                    sideMenuController?.items[sectionCount] = temp
                        
                    case "HEADHR" : temp = ["Requisitions","Offered","Turn Around Time","My Tasks","IJP"]
                        sideMenuController?.items[sectionCount] = temp
                        
                    case "C & B HEAD": temp = ["Requisitions","Offered","Turn Around Time","My Tasks","IJP"]
                           sideMenuController?.items[sectionCount] = temp
                        
                    default : break
                    }
                    sectionCount += 1
                }
                sideMenuController?.sectionHeader = sectionTitleArray
            }

            
//        case .LMS:
//            
//            let object = roles!["Learning Management System"] as! [NSMutableDictionary]
//            sideMenuController?.sectionCount = (object.count)
//            if object.count == 1{
//                switch object.first!["name"]! as! String
//                {
//                case "SDM1" : sideMenuController?.items = ["Training Plan","Courses","Requirement"]
//                default:
//                    break
//                    
//                }
//            }else if object.count >= 2{
//                
//                var sectionTitleArray: [String] = []
//                for item in object{
//                    sectionTitleArray.append("\(item["name"] ?? "") - \(item["region"] ?? "")")
//                    
//                    switch item["name"]! as! String{
//                        
//                    case "SDM1" : sideMenuController?.items = ["Training Plan","Courses","Requirement"]
//                    default:
//                        break
//                        
//                    }
//                }
//                sideMenuController?.sectionHeader = sectionTitleArray
//                
//                
//            }
//            
        case .Leave:
           multipleRole = false
            let leaveRole = UserDefaults.getLeaveroles() as! NSMutableDictionary
           if leaveRole.valueForKey("roleText") as! String != "retainee"{
            sideMenuController?.items[0] = ["Dashboard", "Approvals","Team Calendar"]}
           else{
            sideMenuController?.items[0] = ["Approvals","Team Calendar"]
            }
            
        case .DevelopmentConversations:
            
            let object = roles!["Development Conversations"] as! [NSMutableDictionary]
            var temp = [String]()
            sideMenuController!.sectionCount = (object.count)
            
            if object.count == 1{
                multipleRole = false
                switch object.first!["name"]! as! String{
                    
                case "HRBP": temp = ["Development Conversations","Additional Reviewer Feedback"]
                sideMenuController?.items[0] = temp
                    
                case "employee" : temp = ["Development Conversations","Performance History","DC Guide","Additional Reviewer Feedback"]
                sideMenuController?.items[0] = temp
                    
                    
                case "Admin" : temp = ["Development Conversations"]
                
                sideMenuController?.items[0] = temp
                    
                
                    
                    
                    /*
                     Development Conversations
                     Performance History
                     DC Guide
                     Additional Reviewer Feedback
                     */
                    
                default : break
                }
            }else if object.count >= 2{
                
                multipleRole = true
                var sectionTitleArray: [String] = []
                var sectionCount = 0
                for item in object{
                    sectionTitleArray.append("\(item["name"] ?? "") - \(item["region"] ?? "")")
                    
                    switch item["name"]! as! String{
                        
                    case "HRBP": temp = ["Development Conversations"]
                        sideMenuController?.items[sectionCount] = temp
                        
                    case "employee" : temp = ["Development Conversations","Performance History","DC Guide","Additional Reviewer Feedback"]
                    sideMenuController?.items[sectionCount] = temp
                        
                    case "Admin" : temp = ["Development Conversations"]
                    
                    sideMenuController?.items[sectionCount] = temp
                        
                    
                        
                    default : break
                    }
                    sectionCount += 1
                }
                sideMenuController?.sectionHeader = sectionTitleArray
            }
            
        case .EBAT :
            let object = roles!["e-BAT"] as! [NSMutableDictionary]
            var temp = [String]()
            sideMenuController!.sectionCount = (object.count)
            
            if object.count == 1{
                multipleRole = false
                switch object.first!["name"]! as! String{
                    
                case "OBTEAM" : temp = ["Dashboard","SLA","List","Hire"]
                sideMenuController?.items[0] = temp
                    
                case "OBADMIN" : temp = ["Dashboard","SLA","List","Hire"]
                sideMenuController?.items[0] = temp
                    
                case "ADMIN" : temp = ["Dashboard"]
                sideMenuController?.items[0] = temp
                    
                case "HRBP" : temp = ["Dashboard"]
                
                sideMenuController?.items[0] = temp
                    
                default : break
                }
            }else if object.count >= 2{
                
                multipleRole = true
                var sectionTitleArray: [String] = []
                var sectionCount = 0
                for item in object{
                    sectionTitleArray.append("\(item["name"] ?? "") - \(item["region"] ?? "")")
                    
                    switch item["name"]! as! String{
                        
                    case "employee" : temp = ["e-BAT","Performance History", "Additional Reviewer Feedback"]
                    sideMenuController?.items[sectionCount] = temp
                        
                    case "HRBP" : temp = ["e-BAT", "Additional Reviewer Feedback"]
                    sideMenuController?.items[sectionCount] = temp
                        
                    case "Admin" : temp = ["Dashboard"]
                    sideMenuController?.items[sectionCount] = temp

                    default : break
                    }
                    sectionCount += 1
                }
                sideMenuController?.sectionHeader = sectionTitleArray
            }
            
        default:
            sideMenuController?.items[0] = [""]
        }
        
        sideMenuController?.delegate = self
        sideMenuController?.currentIndex = currentMenuIndexPath
        sideMenuController?.dismissControllerHandler = {() -> Void in
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        
        sideMenuController?.modalPresentationStyle = .OverCurrentContext
        presentViewController(sideMenuController!, animated: false, completion: nil)
    }
    
}

extension WebViewController : TSLeftMenuDelegate {
    func itemSelectedAtIndex(index: NSIndexPath) {
        
        currentMenuIndex = index.section
        currentMenuIndexPath = index
        self.dismissViewControllerAnimated(false, completion: nil)
        let roles = NSUserDefaults.standardUserDefaults().dictionaryForKey("kUserRole")
        if let cherryName = cherryName {
            switch cherryName {
            case .ChampionScoreCard:
                
                var urlString:String? = nil
              //  var navTitle: String = navTitleString
                
                let object = roles!["Champion Score Card"] as! [NSMutableDictionary]
                let currentRole = object[currentMenuIndex]
                
                switch currentRole["name"]! as! String{
                case "SDM1" :
                    switch index.row {
                    case 0:
                        urlString = "\(webURL)/mobile/csc/appraisal-dashboard"
                        navTitleString = "Appraisals"
                        break
                    case 1:
                        urlString = "\(webURL)/mobile/csc/template-dashboard"
                        navTitleString = "Templates"
                        break
                    case 2:
                        urlString = "\(webURL)/mobile/csc/criterions-dashboard"
                        navTitleString = "Criterions"
                        break
                    case 3:
                        urlString = "\(webURL)/mobile/cscReports/closed-appraisals"
                        navTitleString = "Reports"
                        break
                    default:
                        break
                    }
                case "SDM2",
                     "CSCMGR",
                     "HROPSM",
                     "HRBP-S",
                     "NSDM" :
                    switch index.row {
                    case 0:
                        urlString = "\(webURL)/mobile/csc/appraisal-dashboard"
                        navTitleString = "Appraisals"
                        break
                    case 1:
                        urlString = "\(webURL)/mobile/cscReports/closed-appraisals"
                        navTitleString = "Reports"
                        break
                    default:
                        break
                    }
                case "VPHR", "VPSA":
                    switch index.row {
                    case 0:
                        urlString = "\(webURL)/mobile/csc/mass-csc-approvals"
                        navTitleString = "Approvals"
                        break
                    
                    case 1:
                        urlString = "\(webURL)/mobile/cscReports/closed-appraisals"
                        navTitleString = "Reports"
                        break
                    default:
                        urlString = "\(webURL)/mobile/csc/appraisal-dashboard"
                        navTitleString = "Appraisals"
                        break
                        
                    }
                case "SA", "HRO", "RHRM", "RSM":
                    switch index.row {
                    case 0:
                        urlString = "\(webURL)/mobile/csc/appraisal-dashboard"
                        navTitleString = "Appraisals"
                        break
                    case 1:
                        urlString = "\(webURL)/mobile/cscReports/closed-appraisals"
                        navTitleString = "Reports"
                        break
                    default: break
                        
                    }
                case "manager":
                    switch index.row {
                    case 0:
                        urlString = "\(webURL)/mobile/csc/appraisal-dashboard"
                        navTitleString = "Appraisals"
                        break
                    default: break
                        
                    }
                case "TSI" :
                    urlString = "\(webURL)/mobile/csc/tsi-scorecard"
                    navTitleString = "Score Card"
                    
                default : break
                    
                }
                navigationItem.title = navTitleString
                if let urlString = urlString {
                    let request = NSURLRequest.init(URL: NSURL.init(string: urlString)!)
                    createWebView()     // re-create webview to delete back history
                    setCookies()
                    
                    webView?.loadRequest(request)
                }
                
                break
                
            case .PMS:
                var urlString:String? = nil
                
                let object = roles!["Performance Management System"] as! [NSMutableDictionary]
                let currentRole = object[currentMenuIndex]
                
                switch currentRole["name"]! as! String{
                    
                case "ADMIN" :
                    switch index.row {
                    case 0:
                        urlString = "\(webURL)/mobile/pms/appraisal-dashboard"
                        navTitleString = "Appraisals"
                        break
                    case 1:
                        urlString = "\(webURL)/mobile/pms/template-dashboard"
                        navTitleString = "Templates"
                        break
                    case 2:
                        urlString = "\(webURL)/mobile/pms/criterions-dashboard"
                        navTitleString = "Criterions"
                        break
                        
                    case 3:
                        urlString = "\(webURL)/mobile/pms/scale-settings"
                        navTitleString = "Scale settings"
                        break
                        
                    case 4:
                        urlString = "\(webURL)/mobile/pms/launch-filter-settings"
                        navTitleString = "Launch Filter"
                        
                    case 5:
                        urlString = "\(webURL)/mobile/pms//active-appraisal-list"
                        navTitleString = "Employee Status"
                    default:
                        break
                    }
                    
                case "SA","manager","RSM","HRBP" :
                    urlString = "\(webURL)/mobile/pms/appraisal-dashboard"
                    navTitleString = "Appraisals"
                        break
                

                case "VPSA","VPHR" :
                    urlString = "\(webURL)/mobile/pms/mass-pms-approvals"
                    navTitleString = "Approvals"
                    break
                    
                case "TSI" :
                    urlString = "\(webURL)/mobile/pms/employee-annual-appraisal"
                    navTitleString = "Annual Appraisal"
                    break
                    
                default : break
                    
                }
                navigationItem.title = navTitleString
                if let urlString = urlString {
                    let request = NSURLRequest.init(URL: NSURL.init(string: urlString)!)
                    createWebView()     // re-create webview to delete back history
                    setCookies()
                    
                    webView?.loadRequest(request)
                }
                
                break
                
            case .Onboarding:
                var urlString:String? = nil
                
                let object = roles!["On Boarding"] as! [NSMutableDictionary]
                let currentRole = object[currentMenuIndex]
                
                switch currentRole["name"]! as! String{
                    
                case "OBTEAM":
                    switch index.row {
                        
                    case 0:
                        urlString = "\(webURL)/mobile/onboarding/onboarding-landing"
                        navTitleString = "Dashboard"
                        break
                        
                    case 1:
                        urlString = "\(webURL)/mobile/onboarding/onboarding-SLA"
                        navTitleString = "Onboarding-SLA"
                        break
                        
                    case 2:
                        urlString = "\(webURL)/mobile/onboarding/onboarding-allList"
                        navTitleString = "Candidate-List"
                        break
                        
                    case 3:
                        urlString = "\(webURL)/mobile/onboarding/onboarding-hire"
                        navTitleString = "Hire"
                        break

                        
                    default:
                        break
                    }
                    
                case "OBADMIN":
                    switch index.row {
                    
                    case 0:
                        urlString = "\(webURL)/mobile/onboarding/onboarding-landing"
                        navTitleString = "Dashboard"
                        break
                        
                        
                    case 1:
                        urlString = "\(webURL)/mobile/onboarding/onboarding-SLA"
                        navTitleString = "Onboarding-SLA"
                        break
                        
                    case 2:
                        urlString = "\(webURL)/mobile/onboarding/onboarding-allList"
                        navTitleString = "Candidate-List"
                        break
                        
                    case 3:
                        urlString = "\(webURL)/mobile/onboarding/onboarding-hire"
                        navTitleString = "Hire"
                        break
                        
                        
                    default:
                        break
                    }
                    

                default : break
                    
                }
                navigationItem.title = navTitleString
                if let urlString = urlString {
                    let request = NSURLRequest.init(URL: NSURL.init(string: urlString)!)
                    createWebView()     // re-create webview to delete back history
                    setCookies()
                    
                    webView?.loadRequest(request)
                }
                
                break

            case .Recruitment:
                var urlString:String? = nil
                
                let object = roles!["Recruitment"] as! [NSMutableDictionary]
                let currentRole = object[currentMenuIndex]
                
                switch currentRole["name"]! as! String {
                        
                    case "HRBP","HEADHR","C & B HEAD":
                        switch index.row {
                        case 0:
                            urlString = "\(webURL)/mobile/recruitment/recruitment-requisitions"
                            navTitleString = "Requisitions"
                            break
                            
                        case 1:
                            urlString = "\(webURL)/mobile/recruitment/recruitment-offered"
                            navTitleString = "Offered"
                            break
                            
                        case 2:
                            urlString = "\(webURL)/mobile/recruitment/recruitment-tat"
                            navTitleString = "Turn Around Time"
                            break
                            
                        case 3:
                            urlString = "\(webURL)/mobile/recruitment/recruitment-task-index"
                            navTitleString = "Tasks"
                            break
                            
                        case 4:
                            urlString = "\(webURL)/mobile/recruitment/IJP"
                            navTitleString = "IJP"
                            break
                            
                        default:
                            break
                        }
                        
                        
                        
                    case "employee":
                        switch index.row {
                        case 0:
                            urlString = "\(webURL)/mobile/recruitment/recruitment-task-index"
                            navTitleString = "Tasks"
                            break
                            
                        case 1:
                            urlString = "\(webURL)/mobile/recruitment/IJP"
                            navTitleString = "IJP"
                            break
                            
                        default:
                            break
                        }
                        
                        
                    case "Recruiter":
                        
                        switch index.row {
                            
                        case 0:
                            urlString = "\(webURL)/mobile/recruitment/recruitment-requisitions"
                            navTitleString = "Requisitions"
                            break
                            
                        case 1:
                            urlString = "\(webURL)/mobile/recruitment/recruitment-offered"
                            navTitleString = "Offered"
                            break
                            
                        case 2:
                            urlString = "\(webURL)/mobile/recruitment/recruitment-tat"
                            navTitleString = "Turn Around Time"
                            break
                            
                        case 3:
                            urlString = "\(webURL)/mobile/recruitment/recruitment-task-index"
                            navTitleString = "Tasks"
                            break
                            
                        case 4:
                            urlString = "\(webURL)/mobile/recruitment/IJP"
                            navTitleString = "IJP"
                            break
                        case 5:
                            urlString =  "\(webURL)/mobile/recruitment/candidates"
                            navTitleString = "Candidates"
                            break
                            
                        default:
                            break
                            
                        }
                        
                        
                    case "RECADMIN":
                        
                        switch index.row {
                            
                        case 0:
                            urlString = "\(webURL)/mobile/recruitment/recruitment-requisitions"
                            navTitleString = "Requisitions"
                            break
                            
                        case 1:
                            urlString = "\(webURL)/mobile/recruitment/recruitment-offered"
                            navTitleString = "Offered"
                            break
                            
                        case 2:
                            urlString = "\(webURL)/mobile/recruitment/recruitment-tat"
                            navTitleString = "Turn Around Time"
                            break
                            
                        case 3:
                            urlString =  "\(webURL)/mobile/recruitment/candidates"
                            navTitleString = "Candidates"
                            break
                            
                        case 4:
                            urlString = "\(webURL)/mobile/recruitment/proxyUserAccess"
                            navTitleString = "Proxy-User-Access"
                            break
                        case 5:
                            urlString =  "\(webURL)/mobile/recruitment/deletejd"
                            navTitleString = "Upload & Delete JD"
                            break
                        case 6:
                            urlString =  "\(webURL)/mobile/recruitment/listPlacementAgency"
                            navTitleString = "Placement Agencies"
                            
                            
                        default:
                            break
                            
                            
                        }
                        
                        
                        
                    default : break
                        
                    }
                
                
                
                
                navigationItem.title = navTitleString
                if let urlString = urlString {
                    let request = NSURLRequest.init(URL: NSURL.init(string: urlString)!)
                    createWebView()     // re-create webview to delete back history
                    setCookies()
                    
                    webView?.loadRequest(request)
                }
                
                break
                
//            case .LMS:
//                var urlString:String? = nil
//                var navTitle: String = navTitleString
//               let object = roles!["Champion Score Card"] as! [NSMutableDictionary]
//                
//                switch object.first!["name"]! as! String
//                {
//                case "SDM1" :
//                    
//                    switch index.row
//                    {
//                    case 0:
//                        
//                        urlString = systemURL + "#mobile/lms/tp-index"
//                        navTitleString = "Training Plan"
//                        break
//                        
//                    case 1:
//                           urlString = systemURL + "#mobile/lms/list-of-courses"
//                           navTitleString = "Courses"
//                     default:
//                        break
//                    }
//                    navigationItem.title = navTitleString
//                    if let urlString = urlString {
//                        let request = NSURLRequest.init(URL: NSURL.init(string: urlString)!)
//                        createWebView()     // re-create webview to delete back history
//                        setCookies()
//                        
//                        webView?.loadRequest(request)
//                    }
//                default:
//                    break
//                }
                
            case .Leave:
                var urlString:String? = nil
                let leaveRole = UserDefaults.getLeaveroles() as! NSMutableDictionary
                switch index.row {
                case 0:
                   
                    
                    if leaveRole.valueForKey("roleText") as! String == "retainee"{
                        urlString = systemURL + "#/mobile/leave/approvals"
                        navTitleString = "Approvals"
                    }
                    else{
                        urlString =  systemURL + "#/mobile/leave/dashboard"
                        navTitleString = "Dashboard"
                    }
                case 1:
                    if leaveRole.valueForKey("roleText") as! String == "retainee"{
                        urlString =  systemURL + "#/mobile/leave/team-calendar"
                        navTitleString = "Team Calendar"
                    }
                    else{
                        urlString =  systemURL + "#/mobile/leave/approvals"
                        navTitleString = "Approvals"
                    }
                  
                case 2:
                    urlString =  systemURL + "#/mobile/leave/team-calendar"
                    navTitleString = "Team Calendar"
                default:
                    break
                }
                navigationItem.title = navTitleString
                if let urlString = urlString {
                    let request = NSURLRequest.init(URL: NSURL.init(string: urlString)!)
                    createWebView()     // re-create webview to delete back history
                    setCookies()
                    
                    webView?.loadRequest(request)
                }
                
            case .DevelopmentConversations:
                var urlString:String? = nil
                
                let object = roles!["Development Conversations"] as! [NSMutableDictionary]
                let currentRole = object[currentMenuIndex]
                
                switch currentRole["name"]! as! String {
                    
                case "HRBP":
                    switch index.row {
                    case 0:
                        urlString = "\(webURL)/mobile/cdp/dashboard"
                        navTitleString = "Development Conversations"
                        break
                        
                    case 1:
                        urlString = "\(webURL)/mobile/cdp/feedback-request"
                        navTitleString = "Additional Reviewer Feedback"
                        break
                        
                    default:
                        break
                    }
                    
                    
                case "employee":
                    switch index.row {
                    case 0:
                        urlString = "\(webURL)/mobile/cdp/manager-cdp-approval?activetab=%7B%22name%22:%22Development%20Form%22,%22active%22:true,%22id%22:%22tab0%22,%22emp%22:false%7D&tabsOpen=%5B%7B%22name%22:%22Development%20Form%22,%22active%22:true,%22id%22:%22tab0%22,%22emp%22:false%7D,%7B%22name%22:%22Team%20Assessment%22,%22active%22:false,%22id%22:%22tab1%22,%22emp%22:false%7D%5D&code=Development%20Form"
                        navTitleString = "Development Conversations"
                        break
                        
                    case 1:
                        urlString = "\(webURL)/mobile/cherry/cdp/performance-history"
                        navTitleString = "Performance History"
                        break
                        
                    case 2:
                        urlString = "\(webURL)/mobile/cherry/cdp/repository"
                        navTitleString = "DC Guide"
                        break
                        
                    case 3:
                        urlString = "\(webURL)/mobile/cdp/feedback-request"
                        navTitleString = "Additional Reviewer Feedback"
                        break
                        
                    default:
                        break
                    }
                    
                    
                case "Admin":
                    
                    switch index.row {
                        
                    case 0:
                        urlString = "\(webURL)/mobile/cdp/dashboard"
                        navTitleString = "Development Conversations"
                        break
                        
                    
                        
                    default:
                        break
                        
                    }
                    
                    
                
                    
                    
                    
                default : break
                    
                }
                
                
                
                
                navigationItem.title = navTitleString
                if let urlString = urlString {
                    //let urlwithPercentEscapes = urlString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())
                    let request = NSURLRequest.init(URL: NSURL.init(string: urlString)!)
                    createWebView()     // re-create webview to delete back history
                    setCookies()
                    
                    webView?.loadRequest(request)
                }
                
                break
            case .EBAT:
                var urlString:String? = nil
                
                let object = roles!["e-BAT"] as! [NSMutableDictionary]
                let currentRole = object[currentMenuIndex]
                
                switch currentRole["name"]! as! String {
                    
                case "HRBP":
                    switch index.row {
                    case 0:
                        urlString = "\(webURL)/mobile/kra/dashboard"
                        navTitleString = "e-Bat"
                        break
                        
                    case 1:
                        urlString = "\(webURL)/mobile/cdp/feedback-request"
                        navTitleString = "Additional Reviewer Feedback"
                        break
                        
                    default:
                        break
                    }
                    
                    
                case "employee":
                    switch index.row {
                    case 0:
                        urlString = "\(webURL)/mobile/kra/target-approval?"
                        navTitleString = "Target approval"
                        break
                        
                    case 1:
                        urlString = "\(webURL)/mobile/kra/performance-history"
                        navTitleString = "Performance History"
                        break
                        
                    case 2:
                        urlString = "\(webURL)/mobile/cherry/kra/feedback-request"
                        navTitleString = "Additional Reviewer Feedback"
                        break
                        
                    default:
                        break
                    }
                    
                    
                case "Admin":
                    
                    switch index.row {
                        
                    case 0:
                        urlString = "\(webURL)/mobile/kra/dashboard"
                        navTitleString = "Dashboard"
                        break
                        
                        
                        
                    default:
                        break
                        
                    }
                    
                    
                    
                    
                    
                    
                default : break
                    
                }
                
                
                
                
                navigationItem.title = navTitleString
                if let urlString = urlString {
                    //let urlwithPercentEscapes = urlString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())
                    let request = NSURLRequest.init(URL: NSURL.init(string: urlString)!)
                    createWebView()     // re-create webview to delete back history
                    setCookies()
                    
                    webView?.loadRequest(request)
                }
                
                break
                
            default:
                break
            }
            
            
            
            
            
        }
    }
}

extension WebViewController : UIWebViewDelegate {
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let urlString = request.URL?.absoluteString as String? {
            if urlString.hasSuffix("appraisal-dashboard") {
                //                currentMenuIndex = NSIndexPath(forRow: 0, inSection: currentMenuIndex.section)
                //                currentMenuIndex = NSIndexPath(forRow: 0, inSection: currentMenuIndex.section)
                
            }
            else if urlString.hasSuffix("template-dashboard") {
                //                currentMenuIndex = NSIndexPath(forRow: 1, inSection: currentMenuIndex.section)
            }
            else if urlString.hasSuffix("criterions-dashboard") {
                //                currentMenuIndex = NSIndexPath(forRow: 2, inSection: currentMenuIndex.section)
            }else if urlString.hasSuffix("mobile/cscReports/closed-appraisals") {
                //                currentMenuIndex = NSIndexPath(forRow: 1, inSection: currentMenuIndex.section)
            }
            else {
                //                currentMenuIndex = NSIndexPath(forRow: -1, inSection: currentMenuIndex.section)
            }
        }
        
        return true
    }
    
    
    func webViewDidStartLoad(webView: UIWebView) {
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
        print("Started")
    }
    
    
    
    func webViewDidFinishLoad(webView: UIWebView) {
        LoadingController.instance.hideLoadingView()
        print("finished")
    }
    
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print("Error while loading \(error)")
    }
    
    
    
}
