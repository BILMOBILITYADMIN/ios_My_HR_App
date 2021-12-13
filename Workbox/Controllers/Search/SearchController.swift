//
//  SearchController.swift
//  Workbox
//
//  Created by Chetan Anand on 05/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit


protocol addColaboratorDelegate {
    func addCollaborator(collaborator:User)
}
class SearchController: UITableViewController {
    
    var users = [User]()
    var shouldAddCollaborator : Bool?
    var delegate : addColaboratorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: String(SearchResultCell), bundle: nil)
        // Required if our subclasses are to use `dequeueReusableCellWithIdentifier(_:forIndexPath:)`.
        self.tableView.registerNib(nib, forCellReuseIdentifier: String(SearchResultCell))
        self.tableView.estimatedRowHeight = 33
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.backgroundColor = UIColor.tableViewBackGroundColor()
        self.tableView.separatorColor = UIColor.clearColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.users.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(SearchResultCell)) as! SearchResultCell
        cell.updateCellData(users[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Set up the detail view controller to show.
        if shouldAddCollaborator == true {
            print("colaborator Added")
            delegate?.addCollaborator(users[indexPath.row])
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else{
        let profileDetailViewController = ProfileViewController.profileDetailViewControllerForUser(users[indexPath.row])
        self.presentViewController(profileDetailViewController, animated: true, completion: nil)
        }
    }
}
