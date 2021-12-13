//
//  AddExperienceController.swift
//  Workbox
//
//  Created by Pavan Gopal on 14/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

protocol  AddExperienceControllerDelegate {
    
    func addExperienceToUserExperience(experience:UserExperience)
}


class AddExperienceController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var datePickerView: UIDatePicker?
    var experience = UserExperience()
    var delegate : AddExperienceControllerDelegate?
    var isDateSelected = false
    var  toLabel = false
    var fromLabel = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        createDatePicker()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavigationBar() {
        self.navigationController?.setupNavigationBar()
    }
    
    func createDatePicker(){
        datePickerView = UIDatePicker.init(frame: CGRectMake(0, self.view.frame.size.height-200, self.view.frame.size.width, 200))
        self.view.addSubview(datePickerView!)
        datePickerView!.datePickerMode = UIDatePickerMode.Date
        
        datePickerView!.addTarget(self, action: #selector(AddExperienceController.datePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        datePickerView?.hidden = true
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        if Helper.lengthOfStringWithoutSpace(experience!.websiteUrl) > 0 || experience!.fromDate != nil  || experience!.toDate != nil || Helper.lengthOfStringWithoutSpace(experience!.companyName) > 0 || Helper.lengthOfStringWithoutSpace(experience!.designation) > 0 {
            
            let alertController = UIAlertController(title: NSLocalizedString("confirmNavigation", comment: ""), message: NSLocalizedString("confirmationMessage", comment: ""), preferredStyle: .Alert)
            let okAction = UIAlertAction(title: NSLocalizedString("okActionTitle", comment: ""), style:.Default ,
                                         handler:{ (action) -> Void in
                                            self.dismissViewControllerAnimated(true, completion: nil)
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style:.Cancel ,
                                             handler:{ (action) -> Void in
                                                
            })
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        else{
            dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if Helper.lengthOfStringWithoutSpace(experience!.websiteUrl) > 0 && Helper.lengthOfStringWithoutSpace(Helper.stringForDate(experience!.fromDate, format: "MMMM-yyyy")) > 0  && Helper.lengthOfStringWithoutSpace(Helper.stringForDate(experience!.toDate, format: "MMMM-yyyy")) > 0 && Helper.lengthOfStringWithoutSpace(experience!.companyName) > 0 && Helper.lengthOfStringWithoutSpace(experience!.designation) > 0 {
            
            delegate?.addExperienceToUserExperience(experience!)

            
            let present = self.presentingViewController
            if present is ProfileViewController{
                dismissViewControllerAnimated(true, completion: nil)

            }
            else{
            self.dismissViewControllerAnimated(false){
                present?.dismissViewControllerAnimated(true, completion: nil)
            }
            }
        }
        else{
            let alertController = UIAlertController(title: NSLocalizedString("cannotSaveEmptyEntry", comment: ""), message: NSLocalizedString("enterAllFieldsMessage", comment: "") , preferredStyle: .Alert)
            let okAction = UIAlertAction(title:  NSLocalizedString("okActionTitle", comment: ""), style:.Cancel ,handler:{ (action) -> Void in
            })
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

extension AddExperienceController : UITableViewDelegate,UITableViewDataSource,AddExperienceCellDelegate{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AddExperienceCell", forIndexPath: indexPath) as! AddExperienceCell
        cell.delegate = self
        cell.updateExperienceCell(experience!)
        
        return cell
    }
    
    func updateExperience(companyName: String?, websiteUrl: String?, designation: String?,isFromLabelTapped:Bool?, isToLabelTapped: Bool?) {
        
        if isFromLabelTapped == true {
            fromLabel = true
            toLabel = false
            datePickerView?.hidden = false
            experience?.fromDate = datePickerView?.date
            tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: 0)], withRowAnimation: .None)
        }
        else   if isToLabelTapped == true {
            datePickerView?.hidden = false
            fromLabel = false
            toLabel = true
            experience?.toDate = datePickerView?.date
            tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: 0)], withRowAnimation: .None)
        }
        
        experience?.companyName = companyName
        experience?.websiteUrl   = websiteUrl
        experience?.designation = designation
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        if datePickerView?.hidden == false{
            datePickerView!.hidden = true
        }
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM-yyyy"
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        if fromLabel == true{
            experience?.fromDate = sender.date
            if experience?.toDate?.compare(experience?.fromDate ?? NSDate()) == .OrderedAscending  {
                let alertController = UIAlertController.init(title: "Invalid date", message:"Invalid start date" , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else {
            tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: 0)], withRowAnimation: .None)
            }
        }
        else if toLabel == true{
            experience?.toDate = sender.date
            if experience?.toDate?.compare(experience?.fromDate ?? NSDate()) == .OrderedAscending  {
                let alertController = UIAlertController.init(title: "Invalid date", message:"Invalid end date" , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else {
            tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: 0)], withRowAnimation: .None)
            }
        }
    }
}
