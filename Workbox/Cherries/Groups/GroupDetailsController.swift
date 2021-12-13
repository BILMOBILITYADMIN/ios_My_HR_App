//
//  GroupDetailsTableViewController.swift
//  Workbox
//
//  Created by Pavan Gopal on 11/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

//MARK: - DELEGATE DECLARATIONS
protocol  GroupDetailsControllerDelegate {
    func updateGroupControllerWithData(group:Group,indexSelected : NSIndexPath)
    
}

class GroupDetailsController: UITableViewController,GroupCreateControllerDelegate {
    
    //MARK: - VARIABLES
    
    var systemGroup = Group()
    var customGroup = Group()
    var groupName: String?
    var indexSelected : NSIndexPath?
    var delegate : GroupDetailsControllerDelegate?
    
    //MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if indexSelected?.section == 0 {
            self.navigationItem.rightBarButtonItem = nil
        }
        tableView.tableFooterView = UIView.init(frame: CGRectZero)

        navigationItem.title = (groupName != nil) ? groupName : kEmptyString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if let systemRowCount = systemGroup.members?.count {
            return systemRowCount
        }
        else if let customRowCount = customGroup.members?.count {
            return customRowCount
        }
        else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupDetailCell", forIndexPath: indexPath) as! GroupDetailCell
        if indexSelected?.section == 0 {
            cell.updateCell (indexPath, group :systemGroup)
        }
        else if indexSelected?.section == 1 {
            cell.updateCell (indexPath, group :customGroup)
        }
        return cell
    }
    
    //MARK: - HELPER METHODS
    
    func updateModelWithData(group:Group,modelChanged:Bool) {
        customGroup = group
        navigationItem.title = (group.name != nil) ? group.name : kEmptyString
        if modelChanged == true{
            delegate?.updateGroupControllerWithData(customGroup, indexSelected: indexSelected!)
        }
        tableView.reloadData()
    }
    
    //MARK: - ACTIONS
    
    @IBAction func editButtonPressed(sender: AnyObject) {
        let groupsCreateController = UIStoryboard.groupsStoryboard().instantiateViewControllerWithIdentifier(String(GroupCreateController)) as! GroupCreateController
        
        groupsCreateController.group = customGroup
        groupsCreateController.saveAction = "EditGroup"
        groupsCreateController.delegate = self
        
        let navigationController = UINavigationController.init(rootViewController: groupsCreateController)
        presentViewController(navigationController, animated:true, completion:nil)
    }
}
