//
//  CherriesController.swift
//  Workbox
//
//  Created by Ratan D K on 11/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import EZLoadingActivity
import BTNavigationDropdownMenu

protocol CherriesControllerDelegate {
    func leftSideMenuTapped()
}


enum CherryCategory : Int {
    
    case HumanResource
    
    var displayString : String {
        switch self{
        case .HumanResource:
            return "HR Apps"
        }
    }
}


enum Cherries : Int {
    
    case ChampionScoreCard
    case PMS
    case Recruitment
    case LMS
    case Onboarding
    case Leave
    case DevelopmentConversations
    case EBAT
    case Enominations
    
    var displayString : String {
        switch self{
        case .ChampionScoreCard:
            return "Champion Score Card"
        case .PMS:
            return "Performance Management System"
        case .Recruitment:
            return "Recruitment"
        case .LMS:
            return "LMS"
        case .Onboarding:
            return "On Boarding"
        case .Leave:
            return "Leave Application"
        case .DevelopmentConversations:
            return "Development Conversations"
        case .EBAT:
            return "e-BAT"
            
        case .Enominations :
            return "e - Nominations for Beneficiary"
        }
    }
}

let imageNames : [String : String ] = [ "Champion Score Card" :"csc","Performance Management System":"performance","Recruitment" : "recruit","LMS":"lms","On Boarding" : "Onboarding","Leave Application" : "ic_leave","Development Conversations" : "developement_conversation" , "e-BAT" : "developement_conversation","e - Nominations for Beneficiary":"developement_conversation"] // # Pavan add image names here based on index of apperance

let refreshControl = UIRefreshControl()
var isLoading = false
var cherries: [Cherry]?
var availbleCherries :[Cherries] = [.ChampionScoreCard,.PMS,.Recruitment,.LMS,.Onboarding, .Leave, .DevelopmentConversations, .EBAT,.Enominations]
var cherriesFromLocal:[Cherries] = [.ChampionScoreCard,.PMS,.Recruitment,.LMS,.Onboarding, .Leave, .DevelopmentConversations ,.EBAT, .Enominations]

class CherriesController: UIViewController, UINavigationControllerDelegate {
    var cherriesFromLocal:[Cherries] = []
    @IBOutlet weak var tableView: UITableView!
    let categories = [CherryCategory.HumanResource]
    var delegate: CherriesControllerDelegate?
    var cherryRoles = NSMutableDictionary()
    
    //MARK: - View lifecycle
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadAndUpdateConfiguration()
        var accessibleCherries = [String]()
        if let DynamicCherries =  UserDefaults.sharedInstance.valueForKey("accessibleCherries"){
            accessibleCherries = DynamicCherries  as! [String]
        }
        
        for each in accessibleCherries{
            for cher in availbleCherries{
                if each == cher.displayString{
                cherriesFromLocal.append(cher)
                    
                }
            }
        
        }
//        for  each in cherriesFromLocal{
////            if each.displayString == "Leave Application"{
////            cherriesFromLocal = [.Leave]
////                break
////            }
//        }
        
        
        refreshControl.addTarget(self, action:#selector(TSHomeController.handleRefresh(_:)), forControlEvents: .ValueChanged)
        tableView.backgroundColor = UIColor.tableViewBackGroundColor()
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        createNavBar()
        //        loadItemsFromDb()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK : - Handling pull to refresh
    func handleRefresh(refreshControl: UIRefreshControl) {
        isLoading = false
        ActionController.instance.downloadAndUpdateConfiguration()
        //        loadItemsFromDb()
        refreshControl.endRefreshing()
    }
    
    // Launch groups button press
    
    func launchGroups() {
        let groupsController = UIStoryboard.groupsStoryboard().instantiateViewControllerWithIdentifier(String(GroupsController)) as! GroupsController
        let navigationController = UINavigationController.init(rootViewController: groupsController)
        presentViewController(navigationController, animated:true, completion:nil)
    }
    
    func showSideMenu() {
        delegate?.leftSideMenuTapped()
    }
    
    // Format nav bar with bar buttons
    func createNavBar() {
        navigationItem.title = "Cherries"
        self.navigationController?.setupNavigationBar()
        
        let menuItem = UIBarButtonItem.init(image: UIImage.init(named: "sideNav"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CherriesController.showSideMenu))
        let notifButton : UIButton = Helper.createNotificationBadge(UserDefaults.badgeCount())
        notifButton.addTarget(self, action: #selector(self.notificationButtonPressed), forControlEvents: .TouchUpInside)
        let notificationItem = UIBarButtonItem.init(customView: notifButton)
        navigationItem.leftBarButtonItem = menuItem
        navigationItem.rightBarButtonItem = notificationItem
    }
    
    func loadItemsFromDb() {
        let fetchRequest = NSFetchRequest(entityName:String(Cherry))
        let sortDescriptor = NSSortDescriptor(key: "cherryName", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var result: NSArray?
        
        
        do {
            result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
            
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        if result?.count > 0 {
            //            let object: NSManagedObject = result?.firstObject as! Menu
            cherries = NSArray.init(array: result!) as? [Cherry]
        }
        
        tableView.reloadData()
    }
    
    func notificationButtonPressed(){
        if let menuView =  self.navigationItem.titleView as? BTNavigationDropdownMenu{
            menuView.animationDuration = 0
            menuView.hide()
        }
        ActionController.instance.notificationButtonPressed()
        
    }
    
    
}


//MARK: - Extensions

extension CherriesController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CherriesCell", forIndexPath:  indexPath) as! CherriesCell
        cell.contentView.backgroundColor = UIColor.tableViewBackGroundColor()
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return CherryCategory.HumanResource.displayString
    }
    
    
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let sectionHeader : UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        sectionHeader.contentView.backgroundColor = UIColor.tableViewBackGroundColor()
        sectionHeader.textLabel?.font = UIFont.systemFontOfSize(16)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let tableViewCell = cell as? CherriesCell else {
            return
        }
        tableViewCell.backgroundColor = UIColor.tableViewBackGroundColor()
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
    }
}


//MARK: - collectionview delegates and datasource

extension CherriesController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cherriesFromLocal.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        collectionView.backgroundColor = UIColor.tableViewBackGroundColor()
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CherriesCollectionCell", forIndexPath: indexPath) as! CherriesCollectionCell
        cell.updateCollectionCell(cherriesFromLocal[indexPath.row], imageName: imageNames[cherriesFromLocal[indexPath.row].displayString]!)
        
        cell.backgroundColor = UIColor.tableViewBackGroundColor()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        switch  cherriesFromLocal[indexPath.row]{
        case .ChampionScoreCard:
            let webViewController = WebViewController()
            webViewController.cherryName = cherriesFromLocal[indexPath.row]
            webViewController.url = systemURL + "#/mobile/csc/dashboard"
            navigationController?.pushViewController(webViewController, animated: true)
            break
        case .PMS:
            let webViewController = WebViewController()
            webViewController.cherryName = cherriesFromLocal[indexPath.row]
            webViewController.url = systemURL + "#/mobile/pms/dashboard"
            navigationController?.pushViewController(webViewController, animated: true)
            break
        case .Recruitment:
            let webViewController = WebViewController()
            webViewController.cherryName = cherriesFromLocal[indexPath.row]
          webViewController.url = systemURL + "#/mobile/recruitment/recruitment-dashboard/NAVIGATION_Recruitment"
            navigationController?.pushViewController(webViewController, animated: true)
            break
        case .LMS:
            let webViewController = WebViewController()
            webViewController.cherryName = cherriesFromLocal[indexPath.row]
            webViewController.url = systemURL + "#/mobile/lms/tp-index"
            navigationController?.pushViewController(webViewController, animated: true)
            break
        
        case .Onboarding:
            let webViewController = WebViewController()
            webViewController.cherryName = cherriesFromLocal[indexPath.row]
            webViewController.url = systemURL + "#/mobile/onboarding/onboarding-landing"
            navigationController?.pushViewController(webViewController, animated: true)
            break
        case .Leave:
            let webViewController = WebViewController()
            webViewController.cherryName = cherriesFromLocal[indexPath.row]
            let leaveRole = UserDefaults.getLeaveroles() as? NSMutableDictionary
        
            if (leaveRole?.valueForKey("roleText"))! as! String == "retainee"{
                webViewController.url = systemURL + "#/mobile/leave/approvals"
                webViewController.navTitleString = "Approvals"
            }
            else{
            webViewController.url = systemURL + "#/mobile/leave/dashboard"
            }
            navigationController?.pushViewController(webViewController, animated: true)
            break
        case .DevelopmentConversations:
            let webViewController = WebViewController()
            webViewController.cherryName = cherriesFromLocal[indexPath.row]
            let leaveRole = UserDefaults.getLeaveroles() as? NSMutableDictionary
            
            if (leaveRole?.valueForKey("roleText"))! as! String == "retainee"{
                webViewController.url = systemURL + "#/mobile/cdp/manager-cdp-approval?activetab=%7B%22name%22:%22Development%20Form%22,%22active%22:true,%22id%22:%22tab0%22,%22emp%22:false%7D&tabsOpen=%5B%7B%22name%22:%22Development%20Form%22,%22active%22:true,%22id%22:%22tab0%22,%22emp%22:false%7D,%7B%22name%22:%22Team%20Assessment%22,%22active%22:false,%22id%22:%22tab1%22,%22emp%22:false%7D%5D&code=Development%20Form"//http://hrapps.britindia.com/
                webViewController.navTitleString = "Development Conversations"
            }
            else{
                webViewController.url = systemURL + "#/mobile/cdp/manager-cdp-approval?activetab=%7B%22name%22:%22Development%20Form%22,%22active%22:true,%22id%22:%22tab0%22,%22emp%22:false%7D&tabsOpen=%5B%7B%22name%22:%22Development%20Form%22,%22active%22:true,%22id%22:%22tab0%22,%22emp%22:false%7D,%7B%22name%22:%22Team%20Assessment%22,%22active%22:false,%22id%22:%22tab1%22,%22emp%22:false%7D%5D&code=Development%20Form"
                webViewController.navTitleString = "Development Conversations"
            }
            navigationController?.pushViewController(webViewController, animated: true)
            break
            
        case .EBAT:
            let webViewController = WebViewController()
            webViewController.cherryName = cherriesFromLocal[indexPath.row]
            webViewController.url = systemURL + "#/mobile/kra/target-approval"//http://hrapps.britindia.com/
            webViewController.navTitleString = "e-Bat"

            navigationController?.pushViewController(webViewController, animated: true)
            break
            
        case .Enominations :
//            let webViewController = WebViewController()
//            webViewController.cherryName = cherriesFromLocal[indexPath.row]
//            webViewController.url = systemURL + "#/mobile/kra/target-approval"//http://hrapps.britindia.com/
//            webViewController.navTitleString = "e-Bat"
            
            
            let webViewController = WebViewController()
            webViewController.cherryName = cherriesFromLocal[indexPath.row]
            webViewController.url = systemURL + "#/cwapp/mynomineerequests"
            
            webViewController.navTitleString = "e-Nominee"
            
            navigationController?.pushViewController(webViewController, animated: true)
            break

        }
    }
}

extension CherriesController{
    
    func downloadAndUpdateConfiguration() {
       // EZLoadingActivity.show("Loading", disableUI: true)
        
        Alamofire.request(Router.GetConfiguration(email: UserDefaults.loggedInEmail()!)).responseJSON { response in
       // EZLoadingActivity.hide()
            
            switch response.result {
                
            case .Success(let JSON):
                print(JSON)
                if let jsonDict = JSON as? NSDictionary {
                    let status = jsonDict[kServerKeyStatus]
                    
                    if status?.lowercaseString == kServerKeySuccess {
                        if let dataDict = jsonDict[kServerKeyData] as? NSDictionary {
                            
                            // Tabs
                            if let tabArray = dataDict["tabs"] as? NSArray {
                                for tabDict in tabArray as! [NSDictionary] {
                                    let _ = Parser.TabForDictionary(tabDict)
                                    //                                    print(tab?.id)
                                }
                            }
                            
                            // Side nav menu
                            if let navArray = dataDict["navigation"] as? NSArray {
                                for menuDict in navArray as! [NSDictionary] {
                                    let _ = Parser.menuForDictionary(menuDict)
                                    //                                    print(menu?.displayName)
                                    //                                    print(menu?.subMenus)
                                }
                            }
                            
                            // Card config
                            if let cardConfigDict = dataDict["cardConfig"] as? NSDictionary {
                                if let cardsArray = cardConfigDict["cards"] as? NSArray {
                                    for cardDict in cardsArray as! [NSDictionary] {
                                        let cardConfig = Parser.CardConfigForDictionary(cardDict)
                                        let cardSubType = CardSubtype(value: cardConfig?.subType)
                                    }
                                }
                                
                                if let cherryArray = cardConfigDict["types"] as? NSArray{
                                    for cherry in cherryArray{
                                        
                                        
                                        let cherryName = cherry["name"]
                                        
                                        switch cherryName! as! String{
                                            
                                        case "Champion Score Card":
                                            
                                            var rolesDict = [NSMutableDictionary]()
                                            if let userRole = cherry["roles"] as? NSArray {
                                                print(userRole)
                                                for item in userRole { // loop through data items
                                                    print(item)
                                                    
                                                    let role = NSMutableDictionary()
                                                    role.setValue(item["name"], forKey: "name")
                                                    role.setValue(item["roleText"], forKey: "roleText")
                                                    let roleVal = item["region"];
                                                    if !(roleVal is NSNull) {
                                                        role.setValue(item["region"], forKey: "region")
                                                    }else{
                                                        role.setValue(UserDefaults.userRegion(), forKey: "region")
                                                        
                                                    }
                                                    rolesDict.append(role)
                                                }
                                            }
                                            
                                            self.cherryRoles.setValue(rolesDict, forKey: "Champion Score Card")
                                            
                                            
                                            break
                                            
                                            
                                            
                                        case "Performance Management System":
                                            
                                            var rolesDict = [NSMutableDictionary]()
                                            if let userRole = cherry["roles"] as? NSArray {
                                                print(userRole)
                                                for item in userRole { // loop through data items
                                                    print(item)
                                                    
                                                    let role = NSMutableDictionary()
                                                    role.setValue(item["name"], forKey: "name")
                                                    role.setValue(item["displayName"], forKey: "displayName")
                                                    let hrFunc = item["hrFunction"]
                                                    if !(hrFunc is NSNull) {
                                                        role.setValue(item["hrFunction"], forKey: "hrFunction")
                                                    }
                                                    
                                                    let roleVal = item["region"];
                                                    if !(roleVal is NSNull) {
                                                        role.setValue(item["region"], forKey: "region")
                                                    }else{
                                                        role.setValue(UserDefaults.userRegion(), forKey: "region")
                                                        
                                                    }
                                                    rolesDict.append(role)
                                                }
                                            }
                                            
                                            
                                            
                                            self.cherryRoles.setValue(rolesDict, forKey: "Performance Management System")
                                            break
                                            
                                        case "Recruitment":
                                            var rolesDict = [NSMutableDictionary]()
                                            if let userRole = cherry["roles"] as? NSArray {
                                                print(userRole)
                                                for item in userRole { // loop through data items
                                                    print(item)
                                                    
                                                    let role = NSMutableDictionary()
                                                    role.setValue(item["name"], forKey: "name")
                                                    let hrFunc = item["hrFunction"]
                                                    if !(hrFunc is NSNull) {
                                                        role.setValue(item["hrFunction"], forKey: "hrFunction")
                                                    }
                                                    role.setValue(item["roleText"], forKey: "roleText")
                                                    let roleVal = item["region"];
                                                    if !(roleVal is NSNull) {
                                                        role.setValue(item["region"], forKey: "region")
                                                    }else{
                                                        role.setValue(UserDefaults.userRegion(), forKey: "region")
                                                        
                                                    }
                                                    rolesDict.append(role)
                                                }
                                            }
                                            
                                            self.cherryRoles.setValue(rolesDict, forKey: "Recruitment")
                                            
                                            break
                                            
                                        case "Learning Management System":
                                            break
                                        case "On Boarding":
                                            
                                            var rolesDict = [NSMutableDictionary]()
                                            if let userRole = cherry["roles"] as? NSArray {
                                                print(userRole)
                                                for item in userRole { // loop through data items
                                                    print(item)
                                                    
                                                    let role = NSMutableDictionary()
                                                    role.setValue(item["name"], forKey: "name")
                                                    role.setValue(item["displayName"], forKey: "displayName")
                                                    let hrFunc = item["hrFunction"]
                                                    if !(hrFunc is NSNull) {
                                                        role.setValue(item["hrFunction"], forKey: "hrFunction")
                                                    }
                                                    
                                                    let roleVal = item["region"];
                                                    if !(roleVal is NSNull) {
                                                        role.setValue(item["region"], forKey: "region")
                                                    }else{
                                                        role.setValue(UserDefaults.userRegion(), forKey: "region")
                                                        
                                                    }
                                                    rolesDict.append(role)
                                                }
                                            }
                                            
                                            
                                            
                                            self.cherryRoles.setValue(rolesDict, forKey: "On Boarding")
                                            break
                                            
                                        case "Development Conversations":
                                            
                                            var rolesDict = [NSMutableDictionary]()
                                            if let userRole = cherry["roles"] as? NSArray {
                                                print(userRole)
                                                for item in userRole { // loop through data items
                                                    print(item)
                                                    
                                                    if !(item["roleText"] as! String == "manager") {
                                                        
                                                        let role = NSMutableDictionary()
                                                        role.setValue(item["name"], forKey: "name")
                                                        let hrFunc = item["hrFunction"]
                                                        if !(hrFunc is NSNull ) {//|| hrFunc == "Manager"
                                                            role.setValue(item["hrFunction"], forKey: "hrFunction")
                                                        }
                                                        role.setValue(item["roleText"], forKey: "roleText")
                                                        let roleVal = item["region"];
                                                        if !(roleVal is NSNull) {
                                                            role.setValue(item["region"], forKey: "region")
                                                        }else{
                                                            role.setValue(UserDefaults.userRegion(), forKey: "region")
                                                            
                                                        }
                                                        rolesDict.append(role)
                                                    }
                                                    
                                                }
                                            }
                                            
                                            self.cherryRoles.setValue(rolesDict, forKey: "Development Conversations")
                                        
                                        case "e-BAT" :
                                            var rolesDict = [NSMutableDictionary]()
                                            if let userRole = cherry["roles"] as? NSArray {
                                                print(userRole)
                                                for item in userRole { // loop through data items
                                                    print(item)
                                                    
                                                    if !(item["roleText"] as! String == "manager") {
                                                        
                                                        let role = NSMutableDictionary()
                                                        role.setValue(item["name"], forKey: "name")
                                                        let hrFunc = item["hrFunction"]
                                                        if !(hrFunc is NSNull ) {//|| hrFunc == "Manager"
                                                            role.setValue(item["hrFunction"], forKey: "hrFunction")
                                                        }
                                                        role.setValue(item["roleText"], forKey: "roleText")
                                                        let roleVal = item["region"];
                                                        if !(roleVal is NSNull) {
                                                            role.setValue(item["region"], forKey: "region")
                                                        }else{
                                                            role.setValue(UserDefaults.userRegion(), forKey: "region")
                                                            
                                                        }
                                                        rolesDict.append(role)
                                                    }
                                                    
                                                }
                                            }
                                            
                                            self.cherryRoles.setValue(rolesDict, forKey: "e-BAT")
                                            
                                        default:
                                            break
                                        }
                                        
                                        
                                        
                                    }
                                    UserDefaults.setUserRole(self.cherryRoles)
                                    
                                }
                                
                                
                                
                                
                                
                            }
                            
                            //Filters
                            if let unwrappedDataDict = dataDict["filters"] as? [NSDictionary] {
                                Parser.filtersForDictionaryArray(unwrappedDataDict)
                            }
                            else{
                                print("Filters: casting to Dictionary Array failed")
                            }
                            
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            do {
                                try appDelegate.managedObjectContext.save()
                                UserDefaults.setIsConfigurationDownloaded(true)
                            } catch let error {
                                print("Coredata error: \(error)")
                            }
                            
                            //                            self.launchTabBar()
                        }
                    }
                    else if status?.lowercaseString == kServerKeyFailure {
                        var message = jsonDict[kServerKeyMessage] as? String
                        if response.response?.statusCode == ErrorCode.Forbidden.rawValue {
                            message = "Invalid credentials"
                        }
                        else if message == nil {
                            message = "An error occured"
                        }
                        #function
                        
                        let alertController = UIAlertController.init(title: NSLocalizedString("errorOccured", comment: ""), message:message , preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title:  NSLocalizedString("okActionTitle", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        
                        if let senderController =  getTopViewController(){
                            senderController.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                }
                
            case .Failure(let error):
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Seesion Expired"
                }
                
            }
        }
    }

}
