//
//  EditPersonalInfoCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 10/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

//Delagate method for cell
protocol EditPersonalInfoCellDelegate{
    func getTextFieldData(index: Int, enteredText: String)
}


class EditPersonalInfoCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var useGPSButton: UIButton!
    @IBOutlet weak var maritalStatusLabel: UILabel!
    @IBOutlet weak var editInfoimageView: UIImageView!
    @IBOutlet weak var editInfoTextField: UITextField!
  
    var delegate = EditPersonalInfoCellDelegate?()
    var index = NSIndexPath?()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        useGPSButton?.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func createCellAtIndex(index: Int, userModel : User) {
       
        editInfoimageView.image = UIImage(named: "ProfileImage")
        if ( index == 0)
          {
              editInfoimageView.image = AssetImage.maritalstatus.image
            maritalStatusLabel.text = userModel.maritalStatus
            if (maritalStatusLabel.text == nil) {
                maritalStatusLabel.text = "Marital Status"
                maritalStatusLabel.textColor = UIColor(red: 199/255.0, green: 199/255.0, blue: 205/255.0, alpha: 1.0)
            }
            
            else {
                maritalStatusLabel.textColor = UIColor.darkGrayColor()
            }
            maritalStatusLabel.font = UIFont.systemFontOfSize(14)
           }
            
        else {
            editInfoTextField.tag = index
                switch index {
                case 1:
                    editInfoimageView.image = AssetImage.phone.image
                        editInfoTextField.text = userModel.phoneNo
                        editInfoTextField.keyboardType = .PhonePad
                    if ( editInfoTextField.text == "") {
                            editInfoTextField.placeholder = "Phone No"
                        }
                case 2:
                    editInfoimageView.image = AssetImage.email.image
                        editInfoTextField.text = userModel.email
                        editInfoTextField.textColor = ConstantColor.CWLightGray
                        editInfoTextField.userInteractionEnabled = false
                        editInfoTextField.keyboardType = .EmailAddress
                    if ( editInfoTextField.text == "") {
                            editInfoTextField.placeholder = "Email ID"
                        }
                default:
                    editInfoimageView.image = AssetImage.location.image
                    editInfoTextField.text = userModel.location
                         useGPSButton.hidden = false
                    if ( editInfoTextField.text == "") {
                            editInfoTextField.placeholder = "Location"
                        }
            }
            editInfoTextField.addTarget(self, action: #selector(EditPersonalInfoCell.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        }
    }

    //Action for text field
    func textFieldDidChange(textField : UITextField) {
        delegate?.getTextFieldData(textField.tag, enteredText: textField.text!)
    }
}
