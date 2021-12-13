//
//  AddExperienceCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 14/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
protocol  AddExperienceCellDelegate {
    func updateExperience(companyName:String?,websiteUrl:String?,designation:String?,isFromLabelTapped:Bool?,isToLabelTapped:Bool?)
}

class AddExperienceCell: UITableViewCell {

    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var websiteLinkTextField: UITextField!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    
    var delegate : AddExperienceCellDelegate?
    var companyName : String?
    var designation : String?
    var websiteUrl : String?
    var isFromLabelTapped = false
    var isToLabelTapped = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextField.addTarget(self, action: #selector(AddExperienceCell.updateExperienceTitle(_:)), forControlEvents:UIControlEvents.EditingChanged)
        
        companyNameTextField.addTarget(self, action: #selector(AddExperienceCell.updateCompanyName(_:)), forControlEvents:UIControlEvents.EditingChanged)
        websiteLinkTextField.addTarget(self, action: #selector(AddExperienceCell.updateWebSiteLink(_:)), forControlEvents:UIControlEvents.EditingChanged)
        fromDateLabel.userInteractionEnabled = true
        toDateLabel.userInteractionEnabled = true
        
        let FROMtapGesture = UITapGestureRecognizer(target: self, action: #selector(AddExperienceCell.fromLabelTapped(_:)))
        fromDateLabel.addGestureRecognizer(FROMtapGesture)
        let TOtapGesture = UITapGestureRecognizer(target: self, action: #selector(AddExperienceCell.toLabelTapped(_:)))
        toDateLabel.addGestureRecognizer(TOtapGesture)

        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    
    
    func updateExperienceCell(experience:UserExperience){
        
        designation = experience.designation
        companyName = experience.companyName
        websiteUrl = experience.websiteUrl
        
        
        titleTextField.text = experience.designation
        companyNameTextField.text = experience.companyName
        websiteLinkTextField.text = experience.websiteUrl
        
        
        if let experienceFromDate = experience.fromDate {
            fromDateLabel.textColor = UIColor.darkGrayColor()
            fromDateLabel.text = Helper.stringForDate(experienceFromDate, format: "MMMM yyyy")
        }
        else {
            fromDateLabel.text = "Date"
            fromDateLabel.textColor = UIColor.lightGrayColor()
        }
        
        if let experienceToDate = experience.toDate {
            toDateLabel.textColor = UIColor.darkGrayColor()
            toDateLabel.text = Helper.stringForDate(experienceToDate, format: "MMMM yyyy")
        }
        else {
            toDateLabel.text = "Date"
            toDateLabel.textColor = UIColor.lightGrayColor()
        }
        
    }
    
    func fromLabelTapped(sender:UITapGestureRecognizer){
        isFromLabelTapped = true
        isToLabelTapped = false
        websiteLinkTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        companyNameTextField.resignFirstResponder()
 delegate?.updateExperience(companyName, websiteUrl: websiteUrl, designation: designation, isFromLabelTapped: isFromLabelTapped,isToLabelTapped:isToLabelTapped)
 
    }
    
    func toLabelTapped(sender:UITapGestureRecognizer){
        isToLabelTapped = true
        isFromLabelTapped = false
        websiteLinkTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        companyNameTextField.resignFirstResponder()
        delegate?.updateExperience(companyName, websiteUrl: websiteUrl, designation: designation, isFromLabelTapped: isFromLabelTapped,isToLabelTapped:isToLabelTapped)
    }
    
    func updateExperienceTitle(textField: UITextField){
        isFromLabelTapped = false
        isToLabelTapped = false
        designation = textField.text!
        delegate?.updateExperience(companyName, websiteUrl: websiteUrl, designation: designation, isFromLabelTapped: isFromLabelTapped,isToLabelTapped:isToLabelTapped)
       
        
    }
    
    func updateCompanyName(textField: UITextField){
        isFromLabelTapped = false
        isToLabelTapped = false
        companyName = textField.text!
        delegate?.updateExperience(companyName, websiteUrl: websiteUrl, designation: designation, isFromLabelTapped: isFromLabelTapped,isToLabelTapped:isToLabelTapped)
       
    }
    
    func updateWebSiteLink(textField:UITextField){
        isFromLabelTapped = false
        isToLabelTapped = false
        websiteUrl = textField.text
        delegate?.updateExperience(companyName, websiteUrl: websiteUrl, designation: designation, isFromLabelTapped: isFromLabelTapped,isToLabelTapped:isToLabelTapped)
    }
}
