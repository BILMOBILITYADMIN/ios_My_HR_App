//
//  GroupsTableViewController.swift
//  Workbox
//
//  Created by Pavan Gopal on 11/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity
import BRYXBanner

class GroupsController: UITableViewController,GroupCreateControllerDelegate,GroupDetailsControllerDelegate {
    
    //MARK: - VARIABLES
    
    var systemGroups = [Group]()
    var customGroups = [Group]()
    //MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        downloadGroups()
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - HELPER METHODS
    
    func updateGroupControllerWithData(group: Group,indexSelected : NSIndexPath) {
        customGroups[indexSelected.row] = group
        tableView.reloadData()
    }
    
    func updateModelWithData(group:Group,modelChanged:Bool) {
        
        customGroups.append(group)
        tableView.reloadData()
    }
    
    
    func setupNavigationBar() {
        self.navigationController?.setupNavigationBar()
        let addBarItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addButtonPressed(_:)))
        navigationItem.rightBarButtonItem = addBarItem
    }
    
    
    func addButtonPressed(sender:UIBarButtonItem){
        let groupsCreateController = UIStoryboard.groupsStoryboard().instantiateViewControllerWithIdentifier(String(GroupCreateController)) as! GroupCreateController
        
        groupsCreateController.delegate = self
        groupsCreateController.saveAction = "CreateGroup"
        let navigationController = UINavigationController.init(rootViewController: groupsCreateController)
        presentViewController(navigationController, animated:true, completion:nil)
        
    }
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return systemGroups.count
        }
        else if customGroups.count <= 0 {
            return 0
        }
        else{
            return customGroups.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableViewcell", forIndexPath: indexPath) as! GroupCell
        if indexPath.section == 0 {
            cell.updateCellWithGroup(systemGroups[indexPath.row])
        }
        else {
            cell.updateCellWithGroup(customGroups[indexPath.row])
        }
        return cell
    }
    
    
    //MARK: - TABLEVIEW DELEGATE METHODS
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "\(GroupType.System)"
        }
        else{
            return "\(GroupType.Custom)"
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        else {
            return true
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1{
            if editingStyle == UITableViewCellEditingStyle.Delete {
                deleteGroupServiceCall(customGroups[indexPath.row].groupId!)
                customGroups.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                downloadGroups()

            }
        }
    }
    
    // MARK: - Actions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "DetailGroup" {
            if let destinationViewController = segue.destinationViewController as? GroupDetailsController {
                let index = tableView.indexPathForSelectedRow
                if  index?.section == 0 {
                    destinationViewController.systemGroup = systemGroups[index!.row]
                    destinationViewController.groupName = systemGroups[index!.row].name
                    destinationViewController.indexSelected = index
                }
                else {
                    destinationViewController.customGroup = customGroups[index!.row]
                    destinationViewController.groupName = customGroups[index!.row].name
                    destinationViewController.indexSelected = index
                    destinationViewController.delegate = self
                    print(customGroups[index!.row])
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addGroupButtonTapped() {
        print("Add Button Pressed")
        let groupsCreateController = UIStoryboard.groupsStoryboard().instantiateViewControllerWithIdentifier(String(GroupCreateController)) as! GroupCreateController
        
        groupsCreateController.delegate = self
        let navigationController = UINavigationController.init(rootViewController: groupsCreateController)
        presentViewController(navigationController, animated:true, completion:nil)
    }
    
    //MARK:-SERVICE
    func downloadGroups() {
//        EZLoadingActivity.show("Loading", disableUI: true)
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)

        Alamofire.request(Router.GetGroups()).responseJSON { response in
//            EZLoadingActivity.hide()
            LoadingController.instance.hideLoadingView()

            
            switch response.result {
                
            case .Success(let JSON):
                if let jsonDict = JSON as? NSDictionary {
                    let status = jsonDict[kServerKeyStatus]
                    
                    if status?.lowercaseString == kServerKeySuccess {
                        var systemArray = [Group]()
                        var customArray = [Group]()
                        if let dataArray = jsonDict[kServerKeyData] as? NSArray {
                            for groupDict in dataArray as! [NSDictionary] {
                                if let group = Parser.groupForDict(groupDict) {
                                    if group.type == GroupType.System.rawValue {
                                        systemArray.append(group)
                                    }
                                    else {
                                        customArray.append(group)
                                    }
                                }
                            }
                        }
                        self.systemGroups = systemArray
                        self.customGroups = customArray
                        self.tableView.reloadData()
                    }
                    else if status?.lowercaseString == kServerKeyFailure {
                        var message = jsonDict[kServerKeyMessage] as? String
                        if response.response?.statusCode == ErrorCode.Forbidden.rawValue {
                            message = "Session Expired"
                        }
                        else if message == nil {
                            message = "An error occured"
                        }
                        
                        let alertController = UIAlertController.init(title: kEmptyString, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                
            case .Failure(let error):
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Session Expired"
                }
                let alertController = UIAlertController.init(title: kEmptyString, message:message , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func deleteGroupServiceCall(groupID:String){
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
        
        Alamofire.request(Router.DeleteGroup(groupId: groupID)).responseJSON { response in
            LoadingController.instance.hideLoadingView()
            
            
            switch response.result {
                
            case .Success(let JSON):
                if let jsonDict = JSON as? NSDictionary {
                    let status = jsonDict[kServerKeyStatus]
                    
                    if status?.lowercaseString == kServerKeySuccess {
                        let banner = Banner(title: "Notification", subtitle: "Successfully Deleted Group", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                        banner.dismissesOnTap = true
                        banner.show(duration: 3.0)
                    }
                        
                    else if status?.lowercaseString == kServerKeyFailure {
                        var message = jsonDict[kServerKeyMessage] as? String
                        if response.response?.statusCode == ErrorCode.Forbidden.rawValue {
                            message = "Session Expired"
                        }
                        else if message == nil {
                            message = "An error occured"
                        }
                        
                        let alertController = UIAlertController.init(title: kEmptyString, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                
            case .Failure(let error):
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Session Expired"
                }
                let alertController = UIAlertController.init(title: kEmptyString, message:message , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}
