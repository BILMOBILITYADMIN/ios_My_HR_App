    //
//  AddCollaboratorController.swift
//  Workbox
//
//  Created by Pavan Gopal on 06/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import  Alamofire
import BRYXBanner
    
protocol addCollaboratorControllerDelegate {
    func addCollaboratorToCard(collaorators:[User])
}
class AddCollaboratorController: UIViewController,addColaboratorDelegate {

    

    @IBOutlet weak var tableView: UITableView!
    
    var resultsTableController: SearchController!
    var searchController: UISearchController!
    var request: Alamofire.Request?
    var requestSearch: Alamofire.Request?
    var selectedCollaborator = [User]()
    var delegate : addCollaboratorControllerDelegate?
    var collaboratorsAlreadyAdded = [User]()
    var workItemId : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        setSearchController()
        tableView.tableFooterView = UIView.init(frame: CGRectZero)

        let saveBarItem =  UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(saveButtonPressed(_:)))
        navigationItem.rightBarButtonItem = saveBarItem
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchController.searchBar.text = nil
        searchController.searchBar.resignFirstResponder()

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
        definesPresentationContext = true
    }
    
    func addCollaborator(collaborator: User) {
        searchController.active = false
        selectedCollaborator.append(collaborator)
        tableView.reloadData()
    }
    
    func saveButtonPressed(sender:UINavigationItem){
        print("save Button Pressed")
        if selectedCollaborator.count > 0{
            addCollaboratorService()
        }
        else{
            let alertController = UIAlertController.init(title: "Action not possible", message: "Please select at least one collaborator", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

extension AddCollaboratorController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating{
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercaseString else{
            return
        }
        downloadAndDisplaySearchedUser(searchText)
    }
    

    
    func downloadAndDisplaySearchedUser(searchString : String) {
        requestSearch?.cancel()
        requestSearch =  Alamofire.request(Router.SearchUser(text: searchString)).responseJSON { response in
            
            switch response.result {
            case .Success(let JSON):
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{

                    print("Error Occured: JSON Without success")
                    return
                }
                
                guard let jsonDataDictionaryArray = jsonData.valueForKey("data") as? [NSDictionary] else{
                    print("Cannot cast JSON to Dictionary: \(JSON)")
                    return
                }
                
                var usersData = jsonDataDictionaryArray.flatMap{ User(dictionaryData: $0)}
                let resultsController = self.searchController.searchResultsController as! SearchController
                resultsController.delegate = self
                resultsController.shouldAddCollaborator = true
                resultsController.users.removeAll()
                if self.selectedCollaborator.count > 0{
                    
                    var resultArray = [User]()
                    resultArray.removeAll(keepCapacity: false)
                    for i in 0..<self.selectedCollaborator.count{
                    let searchText = self.selectedCollaborator[i].displayName?.lowercaseString
                    
                        resultArray = usersData.filter({$0.displayName?.lowercaseString.rangeOfString(searchText!) != nil})
                        
                    if resultArray.count > 0 {
                        usersData.removeAtIndex(usersData.indexOf({$0.displayName?.lowercaseString.rangeOfString(searchText!) != nil})!)
                    }
                }
                    for i in 0..<self.collaboratorsAlreadyAdded.count{
                        let searchText = self.collaboratorsAlreadyAdded[i].displayName?.lowercaseString
                        
                        resultArray = usersData.filter({$0.displayName?.lowercaseString.rangeOfString(searchText!) != nil})
                        
                        if resultArray.count > 0 {
                            usersData.removeAtIndex(usersData.indexOf({$0.displayName?.lowercaseString.rangeOfString(searchText!) != nil})!)
                        }
                    }
                
                    resultsController.users.appendContentsOf(usersData)
                    resultsController.tableView.reloadData()
                }
                else{
                    var resultArray = [User]()
                    resultArray.removeAll(keepCapacity: false)
                    for i in 0..<self.collaboratorsAlreadyAdded.count{
                        let searchText = self.collaboratorsAlreadyAdded[i].displayName?.lowercaseString
                        
                        resultArray = usersData.filter({$0.displayName?.lowercaseString.rangeOfString(searchText!) != nil})
                        
                        if resultArray.count > 0 {
                            usersData.removeAtIndex(usersData.indexOf({$0.displayName?.lowercaseString.rangeOfString(searchText!) != nil})!)
                        }
                    }
                    resultsController.users.appendContentsOf(usersData)
                    resultsController.tableView.reloadData()
                }
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                
            }
        }
    }
}

extension AddCollaboratorController:UITableViewDelegate,UITableViewDataSource{
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCollaborator.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
      let addCollaboratorCell = tableView.dequeueReusableCellWithIdentifier("addCollaboratorCell", forIndexPath: indexPath) as! AddCollaboratorCell
        addCollaboratorCell.nameLabel.text = selectedCollaborator[indexPath.row].displayName
        addCollaboratorCell.profilePicImageView.clipToCircularImageView()
        addCollaboratorCell.profilePicImageView.setImageWithOptionalUrl(selectedCollaborator[indexPath.row].avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.placeholderProfileIcon.image)

        
        return addCollaboratorCell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            selectedCollaborator.removeAtIndex(indexPath.row )
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
            print("collaborator selected")
        
        
       }
    
    func addCollaboratorService(){
        
        var collaboratorsIdsToBeAddedArray = [String]()
        for colaborator in selectedCollaborator{
            collaboratorsIdsToBeAddedArray.append(colaborator.id ?? "")
        }
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: false)
        
        Alamofire.request(Router.AddCollaborator(workItemId: workItemId!, userIdsArray: collaboratorsIdsToBeAddedArray)).responseJSON { response in
            LoadingController.instance.hideLoadingView()
            switch response.result {
            case .Success(let JSON):
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    var message = jsonData[kServerKeyMessage]?.lowercaseString
                    
                    let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    
                    if let senderController =  getTopViewController(){
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                    print("Error Occured: JSON Without success")
                    return
                }

                let banner = Banner(title: "Notification", subtitle: "Collaborators added successfully", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                self.delegate?.addCollaboratorToCard(self.selectedCollaborator)
                self.navigationController?.popViewControllerAnimated(true)
                
                ActionController.instance.updateCoredataWorkitem(self.workItemId!, senderViewController: nil)


                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                
            }
        }
    
    }

}


