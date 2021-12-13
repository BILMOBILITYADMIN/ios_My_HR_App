//
//  AddCertificateCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 09/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

protocol  AddCertificateCellDelegate {
    
    func updateCertificate(certificateName:String?,institutionName:String?,isLabelTapped:Bool?)
}


class AddCertificateCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var institutionNameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    var delegate : AddCertificateCellDelegate?
    var institutionName: String?
    var certificateName: String?
    var isLabelTapped: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameTextField.addTarget(self, action: #selector(AddCertificateCell.updateCertificateName(_:)), forControlEvents:UIControlEvents.EditingChanged)
        institutionNameTextField.addTarget(self, action: #selector(AddCertificateCell.updateinstitutionNameTextField(_:)), forControlEvents:UIControlEvents.EditingChanged)
        
        dateLabel.userInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddCertificateCell.labelTapped))
        dateLabel.addGestureRecognizer(tapGesture)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCertificateCell(certificate:UserCertification){
        
        certificateName = certificate.certificationTitle
        institutionName = certificate.instituteName
        
        if let certificationDate = certificate.certificationDate {
            dateLabel.textColor = UIColor.darkGrayColor()
            dateLabel.text = Helper.stringForDate(certificationDate, format: "dd MMM yyyy")
        }
        else {
            dateLabel.text = "Date"
            dateLabel.textColor = UIColor.lightGrayColor()
        }
        
        nameTextField.text = certificate.certificationTitle
        institutionNameTextField.text = certificate.instituteName
    }
    
    func updateCertificateName(textField: UITextField){
        certificateName = textField.text!
        isLabelTapped = false
        delegate?.updateCertificate(certificateName,institutionName:institutionName,isLabelTapped:isLabelTapped)
    }
    
    func updateinstitutionNameTextField(textField: UITextField){
        institutionName = textField.text!
        
        isLabelTapped = false
        delegate?.updateCertificate(certificateName,institutionName:institutionName,isLabelTapped:isLabelTapped)
    }
    
    func labelTapped(){
        isLabelTapped = true
        institutionNameTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        delegate?.updateCertificate(certificateName,institutionName:institutionName,isLabelTapped:isLabelTapped)
    }
}
