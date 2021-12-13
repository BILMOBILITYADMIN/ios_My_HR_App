//
//  GroupCreateController.swift
//  Workbox
//
//  Created by Pavan Gopal on 12/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire
import BRYXBanner

//MARK: - DELEGATE DECLARATIONS

protocol  GroupCreateControllerDelegate {
    func updateModelWithData(group:Group,modelChanged:Bool)
    
}

class GroupCreateController: UIViewController {
    
    //MARK: - OUTLETS
    
    @IBOutlet weak var membersCountLabel: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - VARIABLES
    var pickedProfileImage: UIImage!
    var group : Group?
    var requestSearch: Alamofire.Request?

    
    var filteredUsers = [User]()
    var users = [User]()
    var selectedMembers = [User]()
    var deletedGroupMembers = [User]()
    var searchState:Bool = false
    let imagePickerController = UIImagePickerController()
    var delegate : GroupCreateControllerDelegate?
    var saveAction : String?
    
    //    MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        membersCountLabel.text = String(selectedMembers.count) + " Members"
        setUpGroupImage()
        searchTextField.delegate = self
        searchTextField.borderStyle = UITextBorderStyle.None
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        if let group1 = group{
            reloadControllerWithPreviousData(group1)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        groupNameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadControllerWithPreviousData(group1:Group) {
        
        if let imageName = group1.imageName {
            groupImageView.image = UIImage(named: imageName)
        }
        groupNameTextField.text = group1.name
        selectedMembers = group1.members!
        membersCountLabel.text = String(group1.members!.count) + " members"

        tableView.delegate = self
        tableView.dataSource = self
        tableView.setEditing(true, animated: true)
        print(group1.members)
        
    }
    
    func setupNavigationBar() {
        self.navigationController?.setupNavigationBar()
    }
    
    func setUpGroupImage(){
        imagePickerController.delegate = self
        groupImageView.image = UIImage(named: "groups_icon")
        groupImageView.layer.cornerRadius = (groupImageView?.frame.size.width)! / 2
        groupImageView.clipsToBounds = true
        
        let groupImageViewtapRecognizer = UITapGestureRecognizer(target: self, action: #selector(GroupCreateController.groupImageViewTapped(_:)))
        self.groupImageView.addGestureRecognizer(groupImageViewtapRecognizer)
    }
    
    @IBAction func textFieldEditingChanged(sender: AnyObject) {
        
//        let textField = sender as! UITextField
        searchState = true
        filteredUsers.removeAll(keepCapacity: false)
        let searchText = sender.text!.lowercaseString
        downloadAndDisplaySearchedUser(searchText)
        
        if sender.text == ""{
            searchState = false
            tableView.reloadData()
        }
        
    }
}

//MARK: - EXTENTIONS

extension GroupCreateController: UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate{
    
    //MARK: - TABLEVIEW DATASOURCE
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchState == true {
            return filteredUsers.count
        }
        else {
            return selectedMembers.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId", forIndexPath: indexPath) as! GroupCreateCell
        if searchState == true{
            tableView.setEditing(false, animated: true)
            cell.updateCell(filteredUsers[indexPath.row])
        }
        else {
            
            tableView.setEditing(true, animated: true)
            if selectedMembers.count > 0{
            cell.updateCell(selectedMembers[indexPath.row])
            }
            
        }
        
        return cell
        
    }
    
    //MARK: - TABLEVIEW DELEGATE
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchState == true{
            searchTextField.resignFirstResponder()
            searchState = false
            selectedMembers.append(filteredUsers[indexPath.row])
            membersCountLabel.text = String(selectedMembers.count) + " Members"

//            deleteFromUsersArray(indexPath)
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
//            addToUsersArray(indexPath)
            deletedGroupMembers.append(selectedMembers[indexPath.row])
            if group?.groupId != nil {
            saveAction = "DeleteUser"
            }
            selectedMembers.removeAtIndex(indexPath.row)
            membersCountLabel.text = String(selectedMembers.count) + " Members"

            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    //MARK: - ACTIONS
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        
        if Helper.lengthOfStringWithoutSpace(groupNameTextField.text!) == 0 {
            let alertController = UIAlertController(title: "Fill all fields", message: "Please Enter the Group Name", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style:.Default ,
                handler:{ (action) -> Void in
            })
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        else{

            if let unwrappedSaveAction = saveAction{
                switch (unwrappedSaveAction){
                case "CreateGroup": createGroupAndServiceCall()
                break;
                case "EditGroup": updateGroupServiceCall()
                break;
                case "DeleteUser" : removeGroupMemberServiceCall(deletedGroupMembers)
                break;
                default : break;
                
            }
            }
            
        }
    }
    
    
    func changeArrayValues(){
        if self.selectedMembers.count > 0{
            
            var resultArray = [User]()
            resultArray.removeAll(keepCapacity: false)
            for i in 0..<self.selectedMembers.count{
                let searchText = self.selectedMembers[i].displayName?.lowercaseString
                
                resultArray = filteredUsers.filter({$0.displayName?.lowercaseString.rangeOfString(searchText!) != nil})
                
                if resultArray.count > 0 {
                    filteredUsers.removeAtIndex(filteredUsers.indexOf({$0.displayName?.lowercaseString.rangeOfString(searchText!) != nil})!)
                }
            }
            for i in 0..<self.selectedMembers.count{
                let searchText = self.selectedMembers[i].displayName?.lowercaseString
                
                resultArray = filteredUsers.filter({$0.displayName?.lowercaseString.rangeOfString(searchText!) != nil})
                
                if resultArray.count > 0 {
                    filteredUsers.removeAtIndex(filteredUsers.indexOf({$0.displayName?.lowercaseString.rangeOfString(searchText!) != nil})!)
                }
            }
            
           
        }
        else{
            var resultArray = [User]()
            resultArray.removeAll(keepCapacity: false)
            for i in 0..<self.selectedMembers.count{
                let searchText = self.selectedMembers[i].displayName?.lowercaseString
                
                resultArray = filteredUsers.filter({$0.displayName?.lowercaseString.rangeOfString(searchText!) != nil})
                
                if resultArray.count > 0 {
                    filteredUsers.removeAtIndex(filteredUsers.indexOf({$0.displayName?.lowercaseString.rangeOfString(searchText!) != nil})!)
                }
            }
            
        }
    }
    
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: - IMAGEPICKER DELEGATE METHODS
    func imagePickerController(picker : UIImagePickerController, didFinishPickingMediaWithInfo info : [String : AnyObject]) {
        pickedProfileImage = (info[UIImagePickerControllerEditedImage] as? UIImage)!
        print(pickedProfileImage)
        
        groupImageView.image = pickedProfileImage
        groupImageView.layer.cornerRadius = (groupImageView?.frame.size.width)! / 2
        groupImageView.clipsToBounds = true
        groupImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    func groupImageViewTapped(gestureRecognizer: UIGestureRecognizer){
        
        let alertController = UIAlertController(title : "UIActionSheet", message :  "UIActionSheet", preferredStyle : .ActionSheet)
        
        let uploadAction = UIAlertAction(title : "Upload from Gallery", style : .Default,
            handler : { (action) -> Void in
                self.imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.imagePickerController.allowsEditing = true
                self.presentViewController(self.imagePickerController, animated : true, completion : nil)
        })
        let cameraAction = UIAlertAction(title : "Upload from Camera", style : .Default,
            handler : { (action) -> Void in
                self.imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                self.imagePickerController.allowsEditing = true
                self.presentViewController(self.imagePickerController, animated : true, completion : nil)
        })
        let cancelAction = UIAlertAction(title : "Cancel", style : .Cancel,
            handler : { (action) -> Void in
                print("Cancel Button Pressed")
        })
        alertController.addAction(uploadAction)
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        presentViewController(alertController, animated : true, completion : nil)
    }
    
    
    //MARK: - TEXTFEILD DELEGATE METHODS
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchState = false
        searchTextField.resignFirstResponder()
        
        tableView.reloadData()
        return true
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
                self.users = jsonDataDictionaryArray.flatMap{ User(dictionaryData: $0)}

                self.filteredUsers = self.users.filter({$0.displayName?.lowercaseString.rangeOfString(searchString) != nil})
                self.changeArrayValues()
                self.tableView.reloadData()
                
            case .Failure(let error):
             
                print("Request failed with error: \(error)")
                
            }
        }
    }
    
    func createGroupAndServiceCall(){
        var groupDictionary = Dictionary<String,AnyObject>()
        groupDictionary["name"] = groupNameTextField.text
        
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
        var selectedMembersIdArray = [String]()
        for member in selectedMembers{
            if let memberId = member.id{
                selectedMembersIdArray.append(memberId)
            }
        }
        groupDictionary["users"] = selectedMembersIdArray
        
        Alamofire.request(Router.GroupCreation(groupDictionary: groupDictionary)).responseJSON { response in
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
                
                guard let jsonDataDict = jsonData["data"] as? NSDictionary else{
                    print("couldnt get data dictionary")
                    return
                }
                let modifiedGroup = Group(JSON: jsonDataDict)

                
                let banner = Banner(title: "Notification", subtitle: "Succesfully added users", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                
                self.delegate?.updateModelWithData(modifiedGroup,modelChanged:true)
                self.dismissViewControllerAnimated(true, completion: nil)

                
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
    

    
    func removeGroupMemberServiceCall(removeGroupMember:[User]){
        
        var userIdString = String()
        var userIDArray = [String]()
        for member in removeGroupMember{
            if let memberId = member.id{
                userIDArray.append(memberId)

            }
        }
        userIdString = userIDArray.joinWithSeparator(",")
        guard let groupId = group?.groupId else{
            print("group Id not present for this group")
            return
        }
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: false)

        Alamofire.request(Router.GroupRemoveUsers(groupId: groupId, usersIdArrayString: userIdString)).responseJSON { response in
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
                
                let modifiedGroup = Group()
                
                modifiedGroup.name = self.groupNameTextField.text
                modifiedGroup.members = self.selectedMembers
                modifiedGroup.imageName = self.group?.imageName
                modifiedGroup.type = "\(GroupType.Custom)"
                modifiedGroup.groupId = self.group?.groupId
                
                
                self.delegate?.updateModelWithData(modifiedGroup,modelChanged:true)
                self.dismissViewControllerAnimated(true, completion: nil)

                
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
    
    
    func updateGroupServiceCall(){
        var groupNameDictionary = Dictionary<String,AnyObject>()
        if group?.name !=  groupNameTextField.text{
            groupNameDictionary["name"] = groupNameTextField.text
        }
        
        var selectedMembersIdArray = [String]()
        for member in selectedMembers{
            if let memberId = member.id{
                selectedMembersIdArray.append(memberId)
            }
        }
        groupNameDictionary["users"] = selectedMembersIdArray
        
        guard let groupId = group?.groupId else{
            print("group Id not present for this group")
            return
        }
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: false)

        
        Alamofire.request(Router.GroupUpdate(groupId: groupId, groupDictionary: groupNameDictionary)).responseJSON { response in
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
                
                let banner = Banner(title: "Notification", subtitle: "Succesfully updated group", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                
                let modifiedGroup = Group()
                
                modifiedGroup.name = self.groupNameTextField.text
                modifiedGroup.members = self.selectedMembers
                modifiedGroup.imageName = self.group?.imageName
                modifiedGroup.type = "\(GroupType.Custom)"
                modifiedGroup.groupId = self.group?.groupId
                
                self.dismissViewControllerAnimated(true, completion: nil)

                self.delegate?.updateModelWithData(modifiedGroup,modelChanged:true)
                
                
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