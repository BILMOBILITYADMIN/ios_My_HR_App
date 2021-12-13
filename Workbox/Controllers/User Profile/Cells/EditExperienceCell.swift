//
//  EditExperienceCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 14/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

protocol  EditExperienceCellDelegate {
    func datePicker(index:NSIndexPath,companyName:String?,designation:String?,websiteUrl:String?,isFromLabelTapped:Bool?,isToLabelTapped:Bool?)
}

class EditExperienceCell: UITableViewCell {
    
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var websiteLinkTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var companyNameTextField: UITextField!
    
    var delegate : EditExperienceCellDelegate?
    var index : NSIndexPath?
    var companyName : String?
    var designation : String?
    var websiteUrl : String?
    var isFromLabelTapped = false
    var isToLabelTapped = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextField.addTarget(self, action: #selector(EditExperienceCell.updateExperienceTitle(_:)), forControlEvents:UIControlEvents.EditingChanged)
        
        companyNameTextField.addTarget(self, action: #selector(EditExperienceCell.updateCompanyName(_:)), forControlEvents:UIControlEvents.EditingChanged)
         websiteLinkTextField.addTarget(self, action: #selector(EditExperienceCell.updateWebSiteLink(_:)), forControlEvents:UIControlEvents.EditingChanged)
        fromDateLabel.userInteractionEnabled = true
        toDateLabel.userInteractionEnabled = true
        
        let FROMtapGesture = UITapGestureRecognizer(target: self, action: #selector(EditExperienceCell.fromLabelTapped(_:)))
        fromDateLabel.addGestureRecognizer(FROMtapGesture)
         let TOtapGesture = UITapGestureRecognizer(target: self, action: #selector(EditExperienceCell.toLabelTapped(_:)))
        toDateLabel.addGestureRecognizer(TOtapGesture)
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateExperienceCell(experience:UserExperience,indexPath:NSIndexPath){
        
        designation = experience.designation
        companyName = experience.companyName
        websiteUrl = experience.websiteUrl
        
        index = indexPath
        
        
        titleTextField.text = experience.designation
        companyNameTextField.text = experience.companyName
        websiteLinkTextField.text = experience.websiteUrl
        
        fromDateLabel.text = Helper.stringForDate(experience.fromDate, format: "MMMM-yyyy")
        toDateLabel.text = Helper.stringForDate(experience.toDate, format: "MMMM-yyyy")
        
    }
    func fromLabelTapped(sender:UITapGestureRecognizer){
        isFromLabelTapped = true
        isToLabelTapped = false
        websiteLinkTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        companyNameTextField.resignFirstResponder()
        
        delegate?.datePicker(index!,companyName:companyName,designation:designation,websiteUrl:websiteUrl,isFromLabelTapped:isFromLabelTapped,isToLabelTapped:isToLabelTapped)
    }
    
    func toLabelTapped(sender:UITapGestureRecognizer){
        isToLabelTapped = true
        isFromLabelTapped = false
        websiteLinkTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        companyNameTextField.resignFirstResponder()
        
        delegate?.datePicker(index!,companyName:companyName,designation:designation,websiteUrl:websiteUrl,isFromLabelTapped:isFromLabelTapped,isToLabelTapped:isToLabelTapped)
    }
    
    func updateExperienceTitle(textField: UITextField){
        isFromLabelTapped = false
        isToLabelTapped = false
        designation = textField.text!
        delegate?.datePicker(index!,companyName:companyName,designation:designation,websiteUrl:websiteUrl,isFromLabelTapped:isFromLabelTapped,isToLabelTapped:isToLabelTapped)
        
    }
    
    func updateCompanyName(textField: UITextField){
        isFromLabelTapped = false
        isToLabelTapped = false
        companyName = textField.text!
        delegate?.datePicker(index!,companyName:companyName,designation:designation,websiteUrl:websiteUrl,isFromLabelTapped:isFromLabelTapped,isToLabelTapped:isToLabelTapped)
    }
    
    func updateWebSiteLink(textField:UITextField){
        isFromLabelTapped = false
        isToLabelTapped = false
        websiteUrl = textField.text
        delegate?.datePicker(index!,companyName:companyName,designation:designation,websiteUrl:websiteUrl,isFromLabelTapped:isFromLabelTapped,isToLabelTapped:isToLabelTapped)
    }
    
}
