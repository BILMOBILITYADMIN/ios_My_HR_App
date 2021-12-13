//
//  EditCertificateCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 09/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

//MARK:-Delegate

protocol  EditCertificateCellDelegate {
    func datePicker(index:NSIndexPath,certificateName:String?,institutionName:String?,isLabelTapped:Bool?)
}

class EditCertificateCell: UITableViewCell {
    
   //MARK:- Outlets and Variables
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var institutionTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    var delegate : EditCertificateCellDelegate?
    var index : NSIndexPath?
    var institutionName : String?
    var certificateName : String?
    var isLabelTapped = false
  
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameTextField.addTarget(self, action: #selector(EditCertificateCell.updateCertificateName(_:)), forControlEvents:UIControlEvents.EditingChanged)
        
        institutionTextField.addTarget(self, action: #selector(EditCertificateCell.updateinstitutionNameTextField(_:)), forControlEvents:UIControlEvents.EditingChanged)
        dateLabel.userInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditCertificateCell.labelTapped(_:)))
        dateLabel.addGestureRecognizer(tapGesture)

        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCertificateCell(certificate: UserCertification,indexPath: NSIndexPath){
        
        institutionName = certificate.instituteName!
        certificateName = certificate.certificationTitle!
        
        index = indexPath
        
        institutionTextField.text = certificate.instituteName
        nameTextField.text = certificate.certificationTitle
        dateLabel.text = Helper.stringForDate(certificate.certificationDate, format: "dd MMM yyyy")
      
        
    }
    
    func labelTapped(sender:UITapGestureRecognizer){
        isLabelTapped = true
        institutionTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        delegate?.datePicker(index!,certificateName:certificateName,institutionName:institutionName,isLabelTapped:isLabelTapped)
    }
    
    func updateCertificateName(textField: UITextField){
         isLabelTapped = false
        certificateName = textField.text!
         delegate?.datePicker(index!,certificateName:certificateName,institutionName:institutionName,isLabelTapped:isLabelTapped)
        
    }
    
    func updateinstitutionNameTextField(textField: UITextField){
         isLabelTapped = false
        institutionName = textField.text!
        delegate?.datePicker(index!,certificateName:certificateName,institutionName:institutionName,isLabelTapped:isLabelTapped)
    }
}
