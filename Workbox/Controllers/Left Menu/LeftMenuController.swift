//
//  LeftMenuController.swift
//  Workbox
//
//  Created by Ratan D K on 16/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import UIKit
import CoreData

protocol LeftMenuControllerDelegate {
    func logoutHandler()
    func menuSelected(menu: Menu, subMenu:SubMenu?)
    func peopleSelected()
}

class LeftMenuController: UIViewController {
    
    var delegate:LeftMenuControllerDelegate?
    
    let kPredefinedMenus = 2
    let kImageWidth :CGFloat = 100
    let kImageHeight :CGFloat = 100
    let kPadding :CGFloat = 50
    let kPaddingRight :CGFloat = 25
    var profileName : String?
    var profileEmail : String?
    let user = User()
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var leftMenuHeaderView: UIView!
    @IBOutlet var profileImageView : UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet weak var menuContainerXConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var VersionNumberLabel: UILabel!
    
    var menuItems: [Menu]?
    var currentMenu: Menu?
    var currentSubmenu: SubMenu?
    var sideMenuIcons = ["tasks","senttasks","completedtasks"]
    
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuContainerView.layer.shadowOpacity = 0.8
        menuContainerXConstraint.constant = -menuContainerView.frame.width
        
        createUser()
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        tableView.backgroundColor = UIColor.tableViewBackGroundColor()
        
        formatHeader()
        addTapRecognizer()
        VersionNumberLabel.text = VersionNumberLabel.text! + " - " + String(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadItemsFromDB()
        formatHeader()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.menuContainerXConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:LOAD DATA
    func loadItemsFromDB() {
        
        let window:UIWindow? = (UIApplication.sharedApplication().delegate?.window)!
        let firstController = (window?.rootViewController) as! FirstViewController
        let menuContainer = firstController.childViewControllers.first as! AppContainer
        let tabController = menuContainer.childViewControllers.first as! UITabBarController
        print(tabController.selectedIndex)
        let tabIDs = [TabID.Inbox.rawValue, TabID.Reports.rawValue, TabID.Cherries.rawValue]
        let selectedTabID = tabIDs[tabController.selectedIndex]
        
        let fetchRequest = NSFetchRequest(entityName:String(Menu))
        print(String(selectedTabID))
        let predicate = NSPredicate(format: "tabId = %@", argumentArray: [String(selectedTabID)])
        fetchRequest.predicate = predicate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var result: NSArray?
        do {
            result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        // Delete object if already exists and create a new one
        if result?.count > 0 {
            //            let object: NSManagedObject = result?.firstObject as! Menu
            menuItems = NSArray.init(array: result!) as? [Menu]
        }
    }
    
    //MARK: - Actions
    
    func addTapRecognizer(){
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(LeftMenuController.profileImageTapped(_:)))
        profileImageView.userInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func profileImageTapped (img : AnyObject){
        
        //                let profileViewController = UIStoryboard.profileStoryboard().instantiateViewControllerWithIdentifier(String(ProfileViewController)) as! ProfileViewController
        guard let unwrappedUser = UserDefaults.loggedInUser() else{
            return
        }
        
        let   profileViewController = ProfileViewController.profileDetailViewControllerForUser(unwrappedUser)
        profileViewController.isEditable = true
        profileViewController.profileLogoutHandler = {() -> Void in
            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                self.delegate?.logoutHandler()
            })
        }
        presentViewController(profileViewController, animated: true, completion: nil)
    }
    
    @IBAction func dismissTapped(sender: AnyObject) {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.menuContainerXConstraint.constant = -self.menuContainerView.frame.width
            self.view.layoutIfNeeded()
            }, completion: {finished in
                self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
    
    //    @IBAction func settingsButtonPressed(sender: AnyObject) {
    //        let settingsViewController = UIStoryboard.profileStoryboard().instantiateViewControllerWithIdentifier(String(SettingsViewController)) as! SettingsViewController
    //        let nc = UINavigationController.init(rootViewController: settingsViewController)
    //        settingsViewController.settingsLogoutHandler = { () -> Void in
    //            self.dismissViewControllerAnimated(false, completion: { () -> Void in
    //                self.delegate?.logoutHandler()
    //            })
    //        }
    //        presentViewController(nc, animated: true, completion: nil)
    //    }
    
    
    //MARK: - Function to format header view
    
    func formatHeader(){
        nameLabel.text = user.displayName
        nameLabel.textColor = UIColor.blackColor()
        emailLabel.text = user.email
        emailLabel.textColor = UIColor.blackColor()
        
        // Adding blur effect to background image
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light) //Adding blur to the background image
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = leftMenuHeaderView.bounds
        backgroundImageView.clipsToBounds = true
        backgroundImageView.addSubview(blurEffectView)
        
        //Adding gradient to background view
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = backgroundImageView.bounds
        gradient.colors = [UIColor.clearColor().CGColor,UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        backgroundImageView.layer.insertSublayer(gradient, atIndex: 0)
        
        //Replacing above implementation as we need to use image with size
        let avatarThumbnailImageUrl : NSURL?
        if let avatarString = UserDefaults.loggedInUser()?.avatarURLString {
            
            let urlString = ConstantServer.imageRelativeUrl + avatarString
             avatarThumbnailImageUrl = NSURL(string: urlString)
        }
        else
        {
            avatarThumbnailImageUrl = nil
        }
        profileImageView.setImageWithOptionalUrl(avatarThumbnailImageUrl, placeholderImage:  AssetImage.placeholderProfileIcon.image)
        backgroundImageView.setImageWithOptionalUrl(avatarThumbnailImageUrl, placeholderImage:  AssetImage.placeholderProfileIcon.image)
        
        
        profileImageView.layer.borderWidth = 2.0
        profileImageView.layer.borderColor = UIColor.tableViewBackGroundColor().CGColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2.0
        profileImageView.clipsToBounds = true
    }
    
    //MARK: - Create User
    
    func createUser(){
        user.displayName = UserDefaults.loggedInUser()?.displayName
        user.email = UserDefaults.loggedInUser()?.email
        //        user.avatarURL = ""
        //        profileImageUrl = UserDefaults.loggedInUser()?.avatarURL
    }
    
    //Function to size the label according to text
    func rectForText(text: String, font: UIFont, maxSize: CGSize) -> CGSize {
        let attrString = NSAttributedString.init(string: text, attributes: [NSFontAttributeName:font])
        let rect = attrString.boundingRectWithSize(maxSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        let size = CGSizeMake(rect.size.width, rect.size.height)
        return size
    }
}

//MARK: - TableView

extension LeftMenuController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //        if let unwrapped = menuItems {
        //            return unwrapped.count + kPredefinedMenus
        //        }
        //        else {
        //            return kPredefinedMenus
        //        }
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        guard let unwrappedMenuItems = menuItems where unwrappedMenuItems.count > 0 else {
        //            return 1
        //        }
        //
        //        var rowCount = 0
        //        if section < unwrappedMenuItems.count {
        //            if let menu:Menu = unwrappedMenuItems[section] {
        //                if let subMenus = menu.subMenus where subMenus.count > 0 {
        //                    rowCount = subMenus.count
        //                }
        //                else {
        //                    rowCount = 1
        //                }
        //            }
        //            return rowCount
        //        }
        //        else {
        //            return 1
        //        }
        return 1
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRectMake(0,0,tableView.frame.size.width,20)) //set these values as necessary
        returnedView.backgroundColor = UIColor.tableViewBackGroundColor()
        
        
        
        return returnedView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //        var lastSection : Int = kPredefinedMenus - 1
        //        if menuItems != nil {
        //            lastSection += menuItems!.count
        //        }
        
        if indexPath.section == 1 {
            let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = "LOGOUT"
            cell.textLabel?.font = UIFont.systemFontOfSize(15)
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.backgroundColor = UIColor.navBarColor()
            cell.selectionStyle = .None
            
            //            cell.textLabel?.frame = CGRect(x: cell.frame.size.width/2 - 32 - kpaddingRight  , y: 0, width: 64, height: cell.frame.size.height)
            return cell
        }
        else  {
            let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = "All"
            //            cell.imageView?.image = AssetImage.people.image
            cell.textLabel?.font = UIFont.systemFontOfSize(15)
            cell.selectionStyle = .None
            cell.backgroundColor = UIColor.tableViewCellBackGroundColor()
            return cell
        }
        //        else {
        //            let aCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as!  LeftMenuCell
        //            var labelName = kEmptyString
        //            var iconName : String?
        //
        //            if let unwrappedMenuItems = menuItems where unwrappedMenuItems.count > 0 && indexPath.section < unwrappedMenuItems.count {
        //                if let menu:Menu = unwrappedMenuItems[indexPath.section] {
        //                    if let subMenus = menu.subMenus where subMenus.count > 0 {
        //                        let subMenu = subMenus[indexPath.row] as! SubMenu
        //                        if subMenu.displayName?.characters.count > 0 {
        //                            labelName = (subMenu.displayName != nil) ? subMenu.displayName! : subMenu.id!
        //                            iconName = subMenu.imageName
        //                        }
        //
        //                        if subMenu.id == currentSubmenu?.id {
        //                            aCell.contentView.backgroundColor = UIColor.init(white: 0.9, alpha: 1.0)
        //                        }
        //                        else {
        //                            aCell.contentView.backgroundColor = nil
        //                        }
        //                    }
        //                    else {
        //                        labelName = (menu.displayName != nil) ? menu.displayName! : menu.id!
        //                        iconName = menu.imageName
        //
        //                        if menu.id == currentMenu?.id {
        //                            aCell.contentView.backgroundColor = UIColor.init(white: 0.9, alpha: 1.0)
        //                        }
        //                        else {
        //                            aCell.contentView.backgroundColor = nil
        //                        }
        //                    }
        //                }
        //            }
        //            iconName = sideMenuIcons[indexPath.row]
        //            aCell.updateLeftMenuCell(iconName:iconName, labelName:labelName)
        //            return aCell
        //        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var lastSection : Int = kPredefinedMenus - 1
        if menuItems != nil {
            lastSection += menuItems!.count
        }
        
        if indexPath.section == 1 {
            
            let alertController = UIAlertController.init(title: "Confirm Logout", message: "Log out of the app?", preferredStyle: UIAlertControllerStyle.Alert)
            let noAction = UIAlertAction.init(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
            let yesAction = UIAlertAction.init(title: "Yes", style: UIAlertActionStyle.Destructive, handler: { (alert: UIAlertAction!) -> Void in
                self.dismissViewControllerAnimated(false, completion: nil)
                self.delegate?.logoutHandler()
            })
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
        else if indexPath.section == lastSection - 1 {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.menuContainerXConstraint.constant = -self.menuContainerView.frame.width
                self.view.layoutIfNeeded()
                }, completion: {finished in
                    self.dismissViewControllerAnimated(false, completion: nil)
                    // self.delegate?.peopleSelected()
            })
        }
        else {
            currentMenu = menuItems![indexPath.section]
            if let subMenus = currentMenu!.subMenus where subMenus.count > 0 {
                if let submenu = subMenus[indexPath.row] as? SubMenu {
                    currentSubmenu = submenu
                }
            }
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.menuContainerXConstraint.constant = -self.menuContainerView.frame.width
                self.view.layoutIfNeeded()
                }, completion: {finished in
                    self.dismissViewControllerAnimated(false, completion: nil)
                    self.delegate?.menuSelected(self.currentMenu!, subMenu: self.currentSubmenu)
            })
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let unwrappedMenuItems = menuItems {
            if section < unwrappedMenuItems.count {
                if let menu = unwrappedMenuItems[section] as Menu? {
                    if menu.subMenus?.count > 0 {
                        return menu.displayName!.capitalizedString
                    }
                    else {
                        return nil
                    }
                }
            }
        }
        return nil
    }
    
}
