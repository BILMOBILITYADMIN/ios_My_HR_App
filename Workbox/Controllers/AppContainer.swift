//
//  AppContainer.swift
//  Workbox
//
//  Created by Ratan D K on 15/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//  

import UIKit
import Alamofire
import EZLoadingActivity

protocol SideMenuControllerDelegate {
    func logoutHandler()
}

class AppContainer: UIViewController {
    
    var tabs = NSArray()
    
    var myTabBarController: UITabBarController!
    var delegate: SideMenuControllerDelegate?
    var leftViewController: LeftMenuController?
    
    var currentInboxMenu: Menu?
    var currentInboxSubmenu: SubMenu?
    var currentReportsMenu: Menu?
    var currentReportsSubmenu: SubMenu?
    var currentCherriesMenu: Menu?
    var currentCherriesSubmenu: SubMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTabsFromDB()
        launchTabBar()
        if !UserDefaults.isConfigurationDownloaded() {
            downloadConfiguration()
        }
        else{
            downloadConfiguration()
        }
        ActionController.instance.downloadBadgeCount()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func downloadConfiguration() {
//        EZLoadingActivity.show("Loading", disableUI: true)
//        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)

        Alamofire.request(Router.GetConfiguration(email: UserDefaults.loggedInEmail()!)).responseJSON { response in
//            EZLoadingActivity.hide()
//            LoadingController.instance.hideLoadingView()

            
            switch response.result {
                
            case .Success(let JSON):
                print(JSON)
                if let jsonDict = JSON as? NSDictionary {
                    let status = jsonDict[kServerKeyStatus]
                    
                    if status?.lowercaseString == kServerKeySuccess {
                        if let dataDict = jsonDict[kServerKeyData] as? NSDictionary {
                            
                            Helper.clearDBForConfig()
                            
                            // Tabs
                            if let tabArray = dataDict["tabs"] as? NSArray {
                                for tabDict in tabArray as! [NSDictionary] {
                                    let _ = Parser.TabForDictionary(tabDict)
                                }
                            }
                            
                            // Side nav menu
                            if let navArray = dataDict["navigation"] as? NSArray {
                                for menuDict in navArray as! [NSDictionary] {
                                    let _ = Parser.menuForDictionary(menuDict)
                                }
                            }
                            
                            // Card config
                            if let cardConfigDict = dataDict["cardConfig"] as? NSDictionary {
                                
                                if let cherryArray = cardConfigDict.valueForKey("types") as? NSArray{
                                    var accessibleCherries = [String]()
                                    for cherry in cherryArray{
                                        Parser.cherryForDictionary(cherry as? String)
                                        accessibleCherries.append(cherry["name"] as! String)
                                        
                                    }
                                    UserDefaults.sharedInstance.setValue(accessibleCherries, forKey: "accessibleCherries")
                                    UserDefaults.sharedInstance.synchronize()
                                }
                                
                                if let cardsArray = cardConfigDict["cards"] as? NSArray {
                                    for cardDict in cardsArray as! [NSDictionary] {
                                        let cardConfig = Parser.CardConfigForDictionary(cardDict)
                                        let cardSubType = CardSubtype(value: cardConfig?.subType)
                                        
//                                        if  let templateIdSring = cardConfig?.templateId{
//                                            CardConfiguration.cardTemplate.setValue(templateIdSring, forKey: String(cardSubType))
//                                        }
                                    }
                                }
                            }
                            
                            //Filters
                            if let unwrappedDataDict = dataDict["filters"] as? [NSDictionary] {
                                Parser.filtersForDictionaryArray(unwrappedDataDict)
                            }
                            else{
                                print("Filters: casting to Dictionary Array failed")
                            }
                            
                            // Permissions
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            do {
                                try appDelegate.managedObjectContext.save()
                                UserDefaults.setIsConfigurationDownloaded(true)
                            } catch let error {
                                print("Coredata error: \(error)")
                            }
                            
                            // Card config version
                            if let unwrappedVersion = dataDict["cardConfigVersion"] as? String {
                                UserDefaults.setConfigVersion(unwrappedVersion)
                            }
                            
                            self.launchTabBar()
                        }
                    }
                    else if status?.lowercaseString == kServerKeyFailure {
                        #function
                        var message = jsonDict[kServerKeyMessage] as? String
                        if response.response?.statusCode == ErrorCode.Forbidden.rawValue {
                            message = "Invalid credentials"
                        }
                        else if message == nil {
                            message = "An error occured"
                        }
//                        print(message)
                        
                        let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        
                        if let senderController =   getTopViewController(){
                            senderController.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                }
                
            case .Failure(let error):
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Session Expired"
                }
                
                let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                
                if let senderController =   getTopViewController(){
                    senderController.presentViewController(alertController, animated: true, completion: nil)
                }
                print(message)
            }
        }
    }
    
    func launchTabBar()  {
        
        let tabNames = ["\(TabID.Inbox)", "\(TabID.Reports)", "\(TabID.Cherries)"]
        
        var navControllers = [UINavigationController]()
        for tabName:String in tabNames {
            let index:Int = tabNames.indexOf(tabName)!
//            let tabItem = UITabBarItem.init(tabBarSystemItem: UITabBarSystemItem.init(rawValue: index)!, tag: index)
            
            if (tabName == "\(TabID.Cherries)") {
                let tabItem = UITabBarItem.init(title: tabName, image: UIImage.init(named: "cherry"), tag: index)
                let cherriesController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(String(CherriesController)) as! CherriesController
                cherriesController.tabBarItem = tabItem
                cherriesController.delegate = self
                
                let nc = UINavigationController.init(rootViewController: cherriesController)
                navControllers.append(nc)
            }
                
            else if (tabName == "\(TabID.Reports)") {
                let tabItem = UITabBarItem.init(title: tabName, image: UIImage.init(named: "reportsTab"), tag: index)
             let reportsController = UIStoryboard.reportStoryboard().instantiateViewControllerWithIdentifier(String(ReportController)) as! ReportController
                reportsController.tabBarItem = tabItem
                reportsController.delegate = self
                let nc = UINavigationController.init(rootViewController: reportsController)
                navControllers.append(nc)
                
            }
                
            else {
                let cardController = UIStoryboard.cardsStoryboard().instantiateViewControllerWithIdentifier(String(CardViewController)) as! CardViewController
                let tabItem = UITabBarItem.init(title: tabName, image: UIImage.init(named: "inboxTab"), tag: index)
                cardController.tabType = TabID.Inbox
                cardController.tabBarItem = tabItem
                cardController.ncTitle = tabName
                cardController.delegate = self
                
                let nc = UINavigationController.init(rootViewController: cardController)
                navControllers.append(nc)
            }
        }
        
        if myTabBarController != nil {
            removeViewController(myTabBarController)
            myTabBarController.viewControllers = nil
            myTabBarController = nil
        }
        
        myTabBarController = UITabBarController()
        myTabBarController.viewControllers = navControllers
        myTabBarController.tabBar.selectionIndicatorImage?.imageWithRenderingMode(.AlwaysTemplate)
       // myTabBarController.tabBar.selectedItem = myTabBarController.tabBar.items[2]
        myTabBarController.selectedIndex = 2
        myTabBarController.tabBar.tintColor = UIColor.navBarColor()
        addViewController(myTabBarController)
    }
    
    // MARK: DATA LOADING
    func loadTabsFromDB() {
        
        let tabIDsArray = [TabID.Inbox, TabID.Reports, TabID.Cherries]
        let tabArray = NSMutableArray()
        
        for tabID in tabIDsArray {
            let predicate = NSPredicate(format: "id = %@", argumentArray: [String(tabID)])
            let newObject = Parser.newObjectForPredicate(predicate, entityName: String(Tab)) as! Tab
            newObject.id = String(tabID)
            newObject.isDefault = (tabID == TabID.Inbox)
            tabArray.addObject(newObject)
        }
        
        tabs = tabArray
    }
}


// MARK: EXTENSIONS

extension AppContainer: CardViewControllerDelegate, CherriesControllerDelegate, ReportControllerDelegate {
    func leftSideMenuTapped() {
        
        leftViewController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(String(LeftMenuController)) as? LeftMenuController
        leftViewController?.delegate = self
        
        switch myTabBarController.selectedIndex {
        case TabIndex.Inbox.rawValue:
            leftViewController?.currentMenu = currentInboxMenu
            leftViewController?.currentSubmenu = currentInboxSubmenu
        case TabIndex.Reports.rawValue:
            leftViewController?.currentMenu = currentReportsMenu
            leftViewController?.currentSubmenu = currentReportsSubmenu
        case TabIndex.Cherries.rawValue:
            leftViewController?.currentMenu = currentCherriesMenu
            leftViewController?.currentSubmenu = currentCherriesSubmenu
        default:
            leftViewController?.currentMenu = nil
            leftViewController?.currentSubmenu = nil
        }
        
        leftViewController!.modalPresentationStyle = .OverCurrentContext
        presentViewController(leftViewController!, animated: false, completion: nil)
    }
}

extension AppContainer: LeftMenuControllerDelegate {
    func logoutHandler() {
        delegate?.logoutHandler()
    }
    
    func menuSelected(menu: Menu, subMenu: SubMenu?) {
        
        switch myTabBarController.selectedIndex {
        case TabIndex.Inbox.rawValue:
            currentInboxMenu = menu
            currentInboxSubmenu = subMenu
        case TabIndex.Reports.rawValue:
            currentReportsMenu = menu
            currentReportsSubmenu = subMenu
        case TabIndex.Cherries.rawValue:
            currentCherriesMenu = menu
            currentCherriesSubmenu = subMenu
        default:
            print("invalid Menu")
        }
        
        if let selectedVC = myTabBarController?.selectedViewController {
            if selectedVC is UINavigationController {
                let navC = selectedVC as? UINavigationController
                if let rootVC = navC?.topViewController {
                    if rootVC is CardViewController {
                        let cardVC = rootVC as? CardViewController
                        cardVC?.currentMenu = menu
                        cardVC?.currentSubMenu = subMenu
                        cardVC?.applySideMenuChanges()
                    }
                }
            }
        }
    }
    
    func peopleSelected() {
        let groupsController = UIStoryboard.groupsStoryboard().instantiateViewControllerWithIdentifier(String(GroupsController)) as! GroupsController
        let nc = UINavigationController.init(rootViewController: groupsController)
        
        let delay = 0.3 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.presentViewController(nc, animated: false, completion: nil)
        }
    }
}
