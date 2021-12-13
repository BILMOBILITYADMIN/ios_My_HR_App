//
//  CollaboratorController.swift
//  Workbox
//
//  Created by Pavan Gopal on 04/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import MessageUI
import Alamofire
import BRYXBanner

class CollaboratorController: UIViewController,MFMailComposeViewControllerDelegate,addCollaboratorControllerDelegate {

    
    var deleteCollaboratorWorkItemCompletionHandler:(() -> Void)!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var exitToolbarButton: UIBarButtonItem!
    
    var collaboratorObject  = Collaborators()
    var searchController: UISearchController!
    var resultsTableController: SearchController!
    var removedCollaborators = [User]()
    var creatorIndex : Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setSearchController()
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        if collaboratorObject.createdBy?.id == UserDefaults.loggedInUser()?.id{
            exitToolbarButton.enabled = false
        }
        else{
            exitToolbarButton.enabled = true
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavigationBar() {
       self.navigationController?.setupNavigationBar()
        let closeButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(CollaboratorController.closeMA(_:)))
          let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(CollaboratorController.saveButtonPressed(_:)))
        navigationItem.rightBarButtonItem = closeButton
        navigationItem.leftBarButtonItem = saveButton
        navigationItem.leftBarButtonItem?.enabled = false
    }
    
    func closeMA(sender:UIBarButtonItem){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveButtonPressed(sender:UIBarButtonItem){
        var userIdString = String()
        var userIDArray = [String]()
        for member in removedCollaborators{
            if let memberId = member.id{
                userIDArray.append(memberId)
                
            }
            
        }
        userIdString = userIDArray.joinWithSeparator(",")
     removeCollaboratorsMemberServiceCall(userIdString)
        
    }
    
    func setSearchController(){
        resultsTableController = SearchController()
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = true // default is YES
        searchController.searchBar.delegate = self    // so we can monitor text changes + others
        /*
         Search is now just presenting a view controller. As such, normal view controller
         presentation semantics apply. Namely that presentation will walk up the view controller
         hierarchy until it finds the root view controller or one that defines a presentation context.
         */
        definesPresentationContext = true
        self.tableView.contentOffset = CGPointMake(0, self.searchController.searchBar.bounds.size.height);
    }
    
    func addCollaboratorToCard(collaborators:[User]){
        collaboratorObject.collaboratorsList.appendContentsOf(collaborators)
        tableView.reloadData()
    }
    
}

extension CollaboratorController:UITableViewDelegate,UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isWorkitemCreator(){
            return collaboratorObject.collaboratorsList.count + 1

        }
        else{
            return collaboratorObject.collaboratorsList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if isWorkitemCreator(){
            if indexPath.row == 0 {
                let addNewCollaboratorCell =
                    tableView.dequeueReusableCellWithIdentifier("addNewCollaborator", forIndexPath: indexPath)
                addNewCollaboratorCell.imageView?.userInteractionEnabled = false
                let tapgesture = UITapGestureRecognizer(target: self, action: #selector(addNewCollaborator(_:)))
                tapgesture.addTarget(self, action: #selector(addNewCollaborator(_:)))
                addNewCollaboratorCell.imageView?.addGestureRecognizer(tapgesture)
                return addNewCollaboratorCell
            }
            else{
                let collaboratorCell = tableView.dequeueReusableCellWithIdentifier(String(CollaboratorCell), forIndexPath: indexPath) as! CollaboratorCell
                if UserDefaults.loggedInUser()!.id == collaboratorObject.collaboratorsList[indexPath.row - 1].id {
                    creatorIndex = indexPath.row
                }
                collaboratorCell.updateCell(collaboratorObject.collaboratorsList[indexPath.row - 1])
                return collaboratorCell
            }
        }
        else{
        let collaboratorCell = tableView.dequeueReusableCellWithIdentifier(String(CollaboratorCell), forIndexPath: indexPath) as! CollaboratorCell
        collaboratorCell.updateCell(collaboratorObject.collaboratorsList[indexPath.row])
        return collaboratorCell
        }
    }
    
  
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isWorkitemCreator() {
            if indexPath.row == 0{
         // ADD NEW COLLABORATOR
            let addColaboratorController = UIStoryboard.collaboratorStoryboard().instantiateViewControllerWithIdentifier(String(AddCollaboratorController)) as! AddCollaboratorController
            addColaboratorController.delegate = self
            addColaboratorController.collaboratorsAlreadyAdded.appendContentsOf(collaboratorObject.collaboratorsList)
            addColaboratorController.workItemId = collaboratorObject.workItemId
           self.navigationController?.pushViewController(addColaboratorController, animated: true)
            }
            else{
                // Set up the detail view controller to show.
                let profileDetailViewController = ProfileViewController.profileDetailViewControllerForUser(collaboratorObject.collaboratorsList[indexPath.row - 1])
                self.presentViewController(profileDetailViewController, animated: true, completion: nil)
            }
            
        }
        else{
                // Set up the detail view controller to show.
                let profileDetailViewController = ProfileViewController.profileDetailViewControllerForUser(collaboratorObject.collaboratorsList[indexPath.row])
                self.presentViewController(profileDetailViewController, animated: true, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if isWorkitemCreator(){
            if  indexPath.row == 0 {
            return false
            }
            else{
                if creatorIndex == indexPath.row{
                    return false
                }
                else{
                return true
                }
            }
        }
        else{
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row > 0{
        if editingStyle == UITableViewCellEditingStyle.Delete{
            removedCollaborators.append(collaboratorObject.collaboratorsList[indexPath.row - 1])
            collaboratorObject.collaboratorsList.removeAtIndex(indexPath.row - 1)
            navigationItem.leftBarButtonItem?.enabled = true
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.reloadData()
        }
        }
    }
    
    func addNewCollaborator(sender:UITapGestureRecognizer){
        print("new collaborator added")
    }

    @IBAction func mailAllPressed(sender: AnyObject) {
        mailAction()
    }
    
    func isWorkitemCreator() -> Bool{
        if  UserDefaults.loggedInUser()?.id ==  collaboratorObject.createdBy?.id{
            return true
        }
        else{
            return false
        }
    }
    
    func mailAction() {
        if let topVC = getTopViewController(){
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                var emailIdArrays = [String]()
                for i in collaboratorObject.collaboratorsList{
                    if let emailId = i.email{
                    emailIdArrays.append(emailId)
                    }
                }
                
                if emailIdArrays.count > 0{
            
                        mail.setToRecipients(emailIdArrays)
                        topVC.presentViewController(mail, animated: true, completion: nil)
               
                }
                else{
                    // show failure alert
                    let alertController = UIAlertController.init(title: "Action not possible", message: "Email of the user not available", preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    topVC.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func hangoutsButtonPressed(sender: AnyObject) {
    UIApplication.sharedApplication().openURL(NSURL.init(string: "com.google.hangouts://")!)
    }
    
    @IBAction func exitButtonPressed(sender: AnyObject) {
        
        
        removeCollaboratorsMemberServiceCall((UserDefaults.loggedInUser()?.id)!)
        
    }
 
   
}

extension CollaboratorController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating{
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercaseString else{
            return
        }
        searchUser(searchText)
//        downloadAndDisplaySearchedUser(searchText)
    }
    
    func searchUser(searchText:String?){
        print(searchText)
        let resultsController = self.searchController.searchResultsController as! SearchController
        resultsController.users.removeAll()
        
        var resultArray = [User]()
        resultArray.removeAll(keepCapacity: false)
        resultArray = collaboratorObject.collaboratorsList.filter({$0.displayName?.lowercaseString.rangeOfString(searchText!) != nil})
        resultsController.users.appendContentsOf(resultArray)
        resultsController.tableView.reloadData()
        
    }
    
    func removeCollaboratorsMemberServiceCall(userIdString:String){
        
       
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: false)

        Alamofire.request(Router.DeleteCollaborator(workItemId: collaboratorObject.workItemId!, userIdsArray: userIdString)).responseJSON { response in
            //            EZLoadingActivity.hide()
            LoadingController.instance.hideLoadingView()
            
            switch response.result {
                
            case .Success(let JSON):
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard let status = jsonData[kServerKeyStatus] as? String where status.lowercaseString == kServerKeySuccess else{
                    var message = jsonData[kServerKeyMessage] as? String
                    if response.response?.statusCode == ErrorCode.Forbidden.rawValue {
                        message = "Invalid credentials"
                    }
                    else if message == nil {
                        message = "An error occured"
                    }
                    
                    let alertController = UIAlertController.init(title: kEmptyString, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    print("Error Occured: JSON Without success")
                    return
                }
                
                let banner = Banner(title: "Notification", subtitle: "Succesfully removed users", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                self.navigationItem.leftBarButtonItem?.enabled = false

                if userIdString == UserDefaults.loggedInUser()?.id{

                    if self.deleteCollaboratorWorkItemCompletionHandler != nil {
                        self.deleteCollaboratorWorkItemCompletionHandler()
                    }
                }
                
                ActionController.instance.updateCoredataWorkitem(self.collaboratorObject.workItemId!, senderViewController: self)
                
//                self.dismissViewControllerAnimated(false, completion: nil)

                
            case .Failure(let error):
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Invalid credentials"
                }
                let alertController = UIAlertController.init(title: kEmptyString, message:message , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
        }
    

    }
}

