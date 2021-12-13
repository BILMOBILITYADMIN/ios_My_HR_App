//
//  EditCertificateController.swift
//  Workbox
//
//  Created by Pavan Gopal on 09/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class EditCertificateController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var certificateControllerCompletionHandler:((copyCertificate:[UserCertification]) -> Void)!

    var certificates = [UserCertification]()
    var certificatesCopyArray = [UserCertification]()
    
    var currentIndex: Int = 0
    
    var datePickerView: UIDatePicker?
    var isCertificateFieldEmpty = false
    var isChanged = false
    var datePickerHeight:CGFloat = 200
    var delegate : AddCertificateControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
        createCertificatiosCopy()
        setupNavigationBar()
        createDatePicker()
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createCertificatiosCopy(){
        
        for certificate in certificates{
            var newCertificate = UserCertification()
            newCertificate?.certificationTitle = certificate.certificationTitle
            newCertificate?.instituteName = certificate.instituteName
            newCertificate?.certificationDate = certificate.certificationDate
            certificatesCopyArray.append(newCertificate!)
        }
        
    }
    
    
    func setupNavigationBar() {
        self.navigationController?.setupNavigationBar()
        
    }
    
    func registerForKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector : #selector(EditCertificateController.keyboardWillShow(_:)), name : UIKeyboardWillShowNotification, object: nil)
        
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
    
    func createDatePicker()
    {
        datePickerView = UIDatePicker(frame: CGRectMake(0, self.view.frame.size.height - datePickerHeight, self.view.frame.size.width, datePickerHeight))
        datePickerView!.datePickerMode = UIDatePickerMode.Date
        datePickerView!.backgroundColor = UIColor.whiteColor()
        datePickerView!.addTarget(self, action: #selector(EditCertificateController.datePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        self.view.addSubview(datePickerView!)
        datePickerView?.hidden = true
        
    }
    
}

extension EditCertificateController : UITableViewDataSource,UITableViewDelegate,EditCertificateCellDelegate {
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if certificatesCopyArray.count > 0 {
            return certificatesCopyArray.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("certificateCell", forIndexPath: indexPath) as! EditCertificateCell
        if certificatesCopyArray.count > 0 {
            cell.updateCertificateCell(certificatesCopyArray[indexPath.row],indexPath:indexPath)
            cell.delegate = self
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            updateUserCertifications(indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.reloadData()
        }
    }
    
    func updateUserCertifications(indexPath:NSIndexPath){
        certificatesCopyArray.removeAtIndex(indexPath.row)
    }
    
    func datePicker(indexPath: NSIndexPath,certificateName:String?,institutionName:String?,isLabelTapped:Bool?) {
        isChanged = true
        currentIndex = indexPath.row
        if isLabelTapped == true{
            datePickerView!.setDate(certificatesCopyArray[currentIndex].certificationDate ?? NSDate(), animated: true)
            
            datePickerView?.hidden = false
            
            let contentInset:UIEdgeInsets = UIEdgeInsetsMake(0, 0, (datePickerView?.frame.size.height)!, 0)
            
            self.tableView.contentInset = contentInset
            self.tableView.scrollIndicatorInsets = contentInset
            
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
        
         var certificate = certificatesCopyArray[currentIndex]
        
            certificate.certificationTitle = certificateName
            certificate.instituteName = institutionName
            certificatesCopyArray[currentIndex] = certificate
        
    }
    
    
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
         var certificate = certificatesCopyArray[currentIndex]
            certificate.certificationDate = sender.date
            certificatesCopyArray[currentIndex] = certificate
            
            tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: currentIndex, inSection: 0)], withRowAnimation: .None)
        
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        if datePickerView?.hidden == false {
            datePickerView!.hidden = true
        }
        
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height , 0, 0, 0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
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
            print("dissmissing the Controller")
        }
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        
        checkForEmptyFields()
        
        if isCertificateFieldEmpty == true{
            let alertController = UIAlertController(title: "Cannot Save Empty Entry For a Certificate", message: "Please Enter all the fields For a Certificate", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style:.Cancel ,
                handler:{ (action) -> Void in
            })
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        else{
            if certificateControllerCompletionHandler != nil{
                self.certificateControllerCompletionHandler(copyCertificate: certificatesCopyArray)
            }
            dismissViewControllerAnimated(true, completion: nil)
            print("dismissing the present controller")
        }
    }
    
    func checkForEmptyFields() {
        isCertificateFieldEmpty = false
        
            for certificate in certificatesCopyArray {
                
                if Helper.lengthOfStringWithoutSpace(certificate.certificationTitle) == 0 || Helper.lengthOfStringWithoutSpace(Helper.stringForDate(certificate.certificationDate, format: "dd MMM yyyy")) == 0 || Helper.lengthOfStringWithoutSpace(certificate.instituteName) == 0 {
                    print(certificate)
                    isCertificateFieldEmpty = true
                    break
                }
            }
        
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        
        let addCertificateController = UIStoryboard.profileStoryboard().instantiateViewControllerWithIdentifier(String(AddCertificateController)) as! AddCertificateController
        
        addCertificateController.delegate = delegate
        
        let nc = UINavigationController.init(rootViewController: addCertificateController)
        
        presentViewController(nc, animated: true, completion: nil)
    }
}