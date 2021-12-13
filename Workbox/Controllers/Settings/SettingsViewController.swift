//
//  SettingsViewController.swift
//  Workbox
//
//  Created by Anagha Ajith on 21/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var settingsLogoutHandler:(() -> Void)!

    
    var rowElements = ["Subscription","Dashboard","App Version"]
    var kPredefinedSections:Int = 2
    @IBOutlet weak var tableView: UITableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.sectionBackGroundColor()
        setupNavigationBar()
        tableView.tableFooterView = UIView(frame: CGRectZero)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupNavigationBar() {
        self.navigationController?.setupNavigationBar()
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

//MARK: - Extensions

extension SettingsViewController: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return rowElements.count + 1
        }else{
            return 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return kPredefinedSections
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if indexPath.row == 0{
                let settingsCell = tableView.dequeueReusableCellWithIdentifier("SettingsCell", forIndexPath: indexPath) as! SettingsCell
                settingsCell.settingsLabel.text = "Passcode/Touch Id"
                return settingsCell
            }else{
                let settingsDisclosureCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SettingDisclosureCell
                settingsDisclosureCell.settingsDetailLabel.text = ""
                settingsDisclosureCell.settingsTitleLabel.text = rowElements[indexPath.row - 1]
                if indexPath.row == 3{
                    let infoDict:NSDictionary = NSBundle.mainBundle().infoDictionary!
                    let appVersion = infoDict.valueForKey("CFBundleShortVersionString") as? String
                    settingsDisclosureCell.settingsDetailLabel?.text = appVersion
                    settingsDisclosureCell.accessoryType = .None
                }
                else{
                    settingsDisclosureCell.accessoryType = .DisclosureIndicator
                }
                return settingsDisclosureCell
            }
        }
        else{
                let logoutCell = tableView.dequeueReusableCellWithIdentifier("logoutCell", forIndexPath: indexPath)
                    return logoutCell
                }
        }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let  lastSection:Int = kPredefinedSections - 1
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 1 :
                let subscriptionController = UIStoryboard.othersStoryboard().instantiateViewControllerWithIdentifier(String(SubscriptionController)) as! SubscriptionController
                navigationController?.pushViewController(subscriptionController, animated: true)
                
            case 2 :                 let dashboardController = UIStoryboard.DashboardStoryboard().instantiateViewControllerWithIdentifier(String(DashboardController)) as! DashboardController
            self.navigationController?.pushViewController(dashboardController, animated: true)
                
                
            default:
                print("Wrong selection")
            }
            
        }
        else if indexPath.section == lastSection && indexPath.row == 0{
            
                let alertController = UIAlertController.init(title: "Confirm Logout", message: "Log out of the app?", preferredStyle: UIAlertControllerStyle.Alert)
                let noAction = UIAlertAction.init(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
                let yesAction = UIAlertAction.init(title: "Yes", style: UIAlertActionStyle.Destructive, handler: { (alert: UIAlertAction!) -> Void in
                    if self.settingsLogoutHandler != nil {
                        self.settingsLogoutHandler()
                    }
                })
                alertController.addAction(noAction)
                alertController.addAction(yesAction)
                presentViewController(alertController, animated: true, completion: nil)
            
        }
    }
    
}
