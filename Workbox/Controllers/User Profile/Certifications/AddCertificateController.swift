//
//  AddCertificateController.swift
//  Workbox
//
//  Created by Pavan Gopal on 09/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

protocol  AddCertificateControllerDelegate {
    
    func addCertificateToUserCertifications(certificate:UserCertification)
}

class AddCertificateController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var certificate = UserCertification()
    var delegate : AddCertificateControllerDelegate?
    var isDateSelected = false
    var datePickerView: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        createDatePicker()
       
        // Do any additional setup after loading the view.
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
        
        datePickerView!.addTarget(self, action: #selector(AddCertificateController.datePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        datePickerView?.hidden = true
    }
}

extension AddCertificateController : UITableViewDataSource,UITableViewDelegate,AddCertificateCellDelegate{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("certificateCell", forIndexPath: indexPath) as! AddCertificateCell
        
        cell.delegate = self
        cell.updateCertificateCell(certificate!)
        return cell
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        if Helper.lengthOfStringWithoutSpace(certificate?.certificationTitle) != 0 || Helper.lengthOfStringWithoutSpace(Helper.stringForDate(certificate?.certificationDate, format: "dd MMM yyyy")) != 0 || Helper.lengthOfStringWithoutSpace(certificate?.instituteName) != 0 {
            
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
    
    func updateCertificate(certificateName: String?, institutionName: String?,isLabelTapped:Bool?) {
        
        certificate?.instituteName = institutionName
        certificate?.certificationTitle = certificateName
        
        if isLabelTapped == true {
            datePickerView?.hidden = false
            certificate?.certificationDate = datePickerView?.date
              tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: 0)], withRowAnimation: .None)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        
        if datePickerView?.hidden == false{
            datePickerView!.hidden = true
        }
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        certificate?.certificationDate = sender.date
        
        tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: 0)], withRowAnimation: .None)
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if (((certificate?.certificationDate) != nil) && (Helper.lengthOfStringWithoutSpace(certificate?.instituteName) > 0) && (Helper.lengthOfStringWithoutSpace(certificate?.certificationTitle) > 0)){
            delegate?.addCertificateToUserCertifications(certificate!)
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
            let okAction = UIAlertAction(title:  NSLocalizedString("okActionTitle", comment: ""), style:.Cancel ,
                handler:{ (action) -> Void in
            })
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
}