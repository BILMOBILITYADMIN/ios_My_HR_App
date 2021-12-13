//
//  EditPersonalInfoController.swift
//  Workbox
//
//  Created by Anagha Ajith on 10/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity

class EditPersonalInfoController: UIViewController, EditPersonalInfoCellDelegate {
    
    var editPersonalInfoCompletionHandler:((copyPersonalInfo:User) -> Void)!

    var pickerView = UIPickerView()
    var user = User()
    var userCopy = User()
    var isChanged = false
    let numberOfRows:Int = 4
    let pickerOptions = ["Married", "Unmarried", "Divorced", "Widowed"]
    let pickerHeight : CGFloat = 170
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        createUserCopy()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditPersonalInfoController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditPersonalInfoController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        pickerView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: view.frame.size.width, height: pickerHeight)
        self.view.addSubview(self.pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        createNavBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createUserCopy(){
        userCopy.id = user.id
        userCopy.firstName = user.firstName
        userCopy.lastName = user.lastName
        userCopy.location = user.location
        userCopy.maritalStatus = user.maritalStatus
        userCopy.phoneNo = user.phoneNo
        userCopy.username = user.username
        userCopy.avatarURLString = user.avatarURLString
        userCopy.designation = user.designation
        userCopy.displayName = user.displayName
        userCopy.email = user.email
        userCopy.employeeId = user.employeeId
        
        var experiencesCopyArray = [UserExperience]()
        if let experiences = user.experiences{
            for experience in experiences{
                var newExperience = UserExperience()
                newExperience?.companyImageName = experience.companyImageName
                newExperience?.companyName = experience.companyName
                newExperience?.designation = experience.designation
                newExperience?.websiteUrl = experience.websiteUrl
                newExperience?.fromDate = experience.fromDate
                newExperience?.toDate = experience.toDate
                experiencesCopyArray.append(newExperience!)
            }
            userCopy.experiences = experiencesCopyArray
        }
        var certificatesCopyArray = [UserCertification]()
        if let certificates = user.certifications{
            for certificate in certificates{
                var newCertificate = UserCertification()
                newCertificate?.certificationTitle = certificate.certificationTitle
                newCertificate?.instituteName = certificate.instituteName
                newCertificate?.certificationDate = certificate.certificationDate
                certificatesCopyArray.append(newCertificate!)
            }
            userCopy.certifications = certificatesCopyArray
        }
    }
    
    //MARK : - Delegate method definition
    func getTextFieldData(index: Int, enteredText: String) {
        isChanged = true
        switch index {
        case 1: userCopy.phoneNo = enteredText
        case 2: userCopy.email = enteredText
        default: userCopy.location = enteredText
        }
    }
    //Formatting navigation bar
    
    func createNavBar() {
        navigationController?.navigationBar.topItem?.title = "Personal Info"
        self.navigationController?.setupNavigationBar()
        
        let leftButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(EditPersonalInfoController.cancelButtonPressed(_:)))
        let rightButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditPersonalInfoController.saveButtonPressed(_:)))
        
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    /*func serverData() -> Dictionary<String, AnyObject> {
        var userDict: Dictionary<String, AnyObject> = Dictionary()
        
        userDict["hi"] = ["fdg"].
        
        return userDict
    }*/
    
    
    //MARK: - Actions
    
    func keyboardWillShow(sender: NSNotification) {
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(sender: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
    
    //Button action for Save
    func saveButtonPressed(sender: UIBarButtonItem) {
        
        if Helper.lengthOfStringWithoutSpace(userCopy.phoneNo) != 10 {
            let alertController = UIAlertController(title: "Invalid entry", message: "Please enter valid phone number", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style:.Cancel ,
                                         handler:{ (action) -> Void in
            })
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
            
        }
        
        else {
        
        dismissViewControllerAnimated(true, completion: nil)
        
        if Helper.lengthOfStringWithoutSpace(userCopy.maritalStatus) > 0 && Helper.lengthOfStringWithoutSpace(userCopy.phoneNo) == 10  && Helper.lengthOfStringWithoutSpace(userCopy.location) > 0 && Helper.lengthOfStringWithoutSpace(userCopy.email) > 0  {

            if editPersonalInfoCompletionHandler != nil{
                self.editPersonalInfoCompletionHandler(copyPersonalInfo: userCopy)
            }
//                updateUserWithService()
            
        }
        else{
            let alertController = UIAlertController(title: "Cannot Save Empty Entry", message: "Please Enter all the fields", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style:.Cancel ,
                handler:{ (action) -> Void in
            })
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
        }
    }
    
    //Button action for Cancel
    func cancelButtonPressed(sender: UIBarButtonItem) {
        
        if isChanged == true{
            let alertController = UIAlertController(title: "Confirm Navigation", message: "All the changes will be discarded \n Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
            
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
                
            })
            
            alertController.addAction(ok)
            alertController.addAction(cancel)
            presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

//MARK: - Extensions
extension EditPersonalInfoController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let editInfoCell1  = tableView.dequeueReusableCellWithIdentifier("EditPersonalInfoCell1", forIndexPath: indexPath)  as! EditPersonalInfoCell
            editInfoCell1.delegate = self
            editInfoCell1.createCellAtIndex(indexPath.row, userModel : userCopy)
            editInfoCell1.selectionStyle = UITableViewCellSelectionStyle.None
            return editInfoCell1
        }
            
        else {
            let editInfoCell2 = tableView.dequeueReusableCellWithIdentifier("EditPersonalInfoCell2", forIndexPath: indexPath) as! EditPersonalInfoCell
            editInfoCell2.selectionStyle = UITableViewCellSelectionStyle.None
            editInfoCell2.createCellAtIndex(indexPath.row, userModel: userCopy)
            editInfoCell2.delegate = self
            return editInfoCell2
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0 {
            isChanged = true
            // To animate the picker view appearance
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                
                var pickerFrame = self.pickerView.frame
                pickerFrame.origin.y = self.view.frame.size.height - pickerFrame.size.height
                self.pickerView.frame = pickerFrame
                }, completion: { finished in
            })
            pickerView.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
            
            // Dismiss keyboard when picker is in view
            for i in 0 ..< numberOfRows {
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath.init(forRow: i, inSection: 0))
                for subView in (cell?.contentView.subviews)! {
                    if subView is UITextField {
                        subView.resignFirstResponder()
                    }
                }
            }
        }
    }
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        if pickerView.hidden == false {
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                
                var pickerFrame = self.pickerView.frame
                pickerFrame.origin.y = self.view.frame.size.height + pickerFrame.size.height
                self.pickerView.frame = pickerFrame
                }, completion: { finished in
            })
        }
    }
}

extension EditPersonalInfoController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        userCopy.maritalStatus = pickerOptions[row]
        tableView.reloadData()
    }
}


