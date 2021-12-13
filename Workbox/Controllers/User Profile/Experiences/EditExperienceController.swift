//
//  EditExperienceController.swift
//  Workbox
//
//  Created by Pavan Gopal on 14/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class EditExperienceController: UIViewController {
    
    var editExperienceCompletionHandler:((copyExperiences:[UserExperience]) -> Void)!
    
    @IBOutlet weak var tableView: UITableView!
    var experiences = [UserExperience]()
    var experiencesCopyArray = [UserExperience]()
    var currentIndex: Int = 0
    var datePickerView: UIDatePicker?
    var isExperienceFieldEmpty = false
    var isChanged = false
    let datePickerHeight:CGFloat = 200
    var  toLabel = false
    var fromLabel = false
    var delegate : AddExperienceControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        createDatePicker()
        createExperiencesCopy()
        registerForKeyboardNotifications()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func setupNavigationBar() {
        self.navigationController?.setupNavigationBar()
        
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        let addExperienceController = UIStoryboard.profileStoryboard().instantiateViewControllerWithIdentifier(String(AddExperienceController)) as! AddExperienceController
        
        let nc = UINavigationController.init(rootViewController: addExperienceController)
        addExperienceController.delegate = delegate
        presentViewController(nc, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        
        if isChanged == true{
            let alertController = UIAlertController(title: "Confirm Navigation", message: "All the changes will be discarded.\n Are you Sure?", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style:.Default ,
                handler:{ (action) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                    print("dismissing the controller")
            })
            let cancelAction = UIAlertAction(title: "Cancel", style:.Cancel ,
                handler:{ (action) -> Void in
            })
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        else{
            dismissViewControllerAnimated(true, completion: nil)
            print("dismissing the Controller")
        }
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
  
        
        checkForEmptyFields()
        
        if isExperienceFieldEmpty == true{
            let alertController = UIAlertController(title: "Cannot save empty entry for a Certificate", message: "Please enter all the fields for a Certificate", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style:.Cancel ,
                handler:{ (action) -> Void in
            })
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        else{
            if editExperienceCompletionHandler != nil{
                self.editExperienceCompletionHandler(copyExperiences: experiencesCopyArray)
            }
            
            dismissViewControllerAnimated(true, completion: nil)
            print("dismissing the present controller")
        }
    }
    
    func createExperiencesCopy(){
        
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
        
    }
    
    func checkForEmptyFields() {
        
        isExperienceFieldEmpty = false

            for experience in experiencesCopyArray {
                
                if Helper.lengthOfStringWithoutSpace(experience.websiteUrl) == 0 || Helper.lengthOfStringWithoutSpace(Helper.stringForDate(experience.fromDate, format: "MMMM-yyyy")) == 0 || Helper.lengthOfStringWithoutSpace(Helper.stringForDate(experience.toDate, format: "MMMM-yyyy")) == 0 || Helper.lengthOfStringWithoutSpace(experience.companyName) == 0 || Helper.lengthOfStringWithoutSpace(experience.designation) == 0  {
                    
                    isExperienceFieldEmpty = true
                    break
                }
            
        }
    }
    
    func registerForKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector : #selector(EditExperienceController.keyboardWillShow(_:)), name : UIKeyboardWillShowNotification, object: nil)
        
        automaticallyAdjustsScrollViewInsets = true
        
    }
    
    func keyboardWillShow(notification : NSNotification){
        datePickerView?.hidden = true
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        var contentInset:UIEdgeInsets = self.tableView.contentInset
        
        contentInset.bottom = keyboardFrame.size.height
        self.tableView.contentInset = contentInset
        self.tableView.scrollIndicatorInsets = contentInset
    }
    
}

extension EditExperienceController : UITableViewDataSource,UITableViewDelegate,EditExperienceCellDelegate{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if experiencesCopyArray.count > 0{
            return experiencesCopyArray.count
        }
        else{
            return 0 
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ExperienceCell", forIndexPath: indexPath) as! EditExperienceCell

            cell.updateExperienceCell(experiencesCopyArray[indexPath.row], indexPath: indexPath)
            cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete{
            updateUserExperience(indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.reloadData()
        }
        
    }
    
    func updateUserExperience(indexPath:NSIndexPath){
        
        experiencesCopyArray.removeAtIndex(indexPath.row)
        
    }
    
    func datePicker(index:NSIndexPath,companyName:String?,designation:String?,websiteUrl:String?,isFromLabelTapped:Bool?,isToLabelTapped:Bool?){
        
        isChanged = true
        currentIndex = index.row
        
        if isFromLabelTapped == true{
            
            fromLabel = true
            
            toLabel = false
            datePickerView!.setDate(experiencesCopyArray[currentIndex].fromDate ?? NSDate(), animated: true)
            
            datePickerView?.hidden = false
            
            let contentInset:UIEdgeInsets = UIEdgeInsetsMake(0, 0, (datePickerView?.frame.size.height)!, 0)
            
            self.tableView.contentInset = contentInset
            self.tableView.scrollIndicatorInsets = contentInset
            
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
        else   if isToLabelTapped == true{
            
            toLabel = true
            
            fromLabel = false
                        datePickerView!.setDate(experiencesCopyArray[currentIndex].toDate ?? NSDate(), animated: true)
            
            datePickerView?.hidden = false
            
            let contentInset:UIEdgeInsets = UIEdgeInsetsMake(0, 0, (datePickerView?.frame.size.height)!, 0)
            
            self.tableView.contentInset = contentInset
            self.tableView.scrollIndicatorInsets = contentInset
            
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
        else{
        var experience = experiencesCopyArray[currentIndex]
        
//        if experience.toDate?.compare(experience.fromDate!) == .OrderedDescending || experience.fromDate?.compare(experience.toDate!) == .OrderedSame {
        
            experience.designation = designation
            experience.companyName = companyName
            experience.websiteUrl = websiteUrl
//
           experiencesCopyArray[currentIndex] = experience
//        }
        
//        else {
//            
//            let alertController = UIAlertController.init(title: "Invalid date", message:"Enter valid information" , preferredStyle: UIAlertControllerStyle.Alert)
//            let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
//            alertController.addAction(okAction)
//            self.presentViewController(alertController, animated: true, completion: nil)
//        }
        }
//
    }
    
    
    func datePickerValueChanged(sender:UIDatePicker) {
        var experience = experiencesCopyArray[currentIndex]
        
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM-yyyy"
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        experiencesCopyArray[currentIndex] = experience
        if fromLabel == true{
            experience.fromDate = sender.date
            experiencesCopyArray[currentIndex] = experience
            
            if experience.toDate?.compare(experience.fromDate!) == .OrderedAscending  {
                let alertController = UIAlertController.init(title: "Invalid date", message:"Invalid start date" , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else {
              tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: currentIndex, inSection: 0)], withRowAnimation: .None)
            }
        }
        else if toLabel == true{
            
            experience.toDate = sender.date
            experiencesCopyArray[currentIndex] = experience

            if experience.toDate?.compare(experience.fromDate!) == .OrderedAscending {
                let alertController = UIAlertController.init(title: "Invalid date", message:"Invalid end date" , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else {
                 tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: currentIndex, inSection: 0)], withRowAnimation: .None)
            }
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        if datePickerView?.hidden == false {
            datePickerView!.hidden = true
        }
        
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height , 0, 0, 0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
    
    func createDatePicker()
    {
        datePickerView = UIDatePicker(frame: CGRectMake(0, self.view.frame.size.height - datePickerHeight, self.view.frame.size.width, datePickerHeight))
        datePickerView!.datePickerMode = UIDatePickerMode.Date
      
        datePickerView!.backgroundColor = UIColor.whiteColor()
        datePickerView!.addTarget(self, action: #selector(EditExperienceController.datePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        self.view.addSubview(datePickerView!)
        datePickerView?.hidden = true
        
    }
}

    