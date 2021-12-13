//
//  CreateFeedTaskController.swift
//  Workbox
//
//  Created by Anagha Ajith on 18/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire


class CreateFeedTaskController: UIViewController {

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    let kTextViewHeight : CGFloat = 30
    let kLineHeight : CGFloat = 1
    let kLeftPadding :CGFloat = 8
    let kRightPadding :CGFloat = 16
    var keyboardHeight : CGFloat?
    var textInputView = CWTextInputView()
    var type : CardType?
    var attachedImages : [UIImage]?
    var isEdited : Int = 0
    var cardViewController: CardViewController?
    override func viewDidLoad() {
        
        super.viewDidLoad()
      
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector : #selector(CreateFeedTaskController.keyboardWillShow(_:)), name : UIKeyboardWillShowNotification, object: nil)
        
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.frame = CGRectMake(kLeftPadding, 110, ConstantUI.screenWidth - kRightPadding, kTextViewHeight)
        lineView.frame = CGRectMake(kLeftPadding, 150, ConstantUI.screenWidth - kRightPadding/2 , kLineHeight)
        titleTextField.becomeFirstResponder()
        addAttachToolBar()
        descriptionTextView.textColor = UIColor.lightGrayColor()
        descriptionTextView.text = "Description"
        descriptionTextView.delegate = self
        textInputView.addAction(nil, placeholderText: "", leftViewEnabled: true, textBarEnabled: false)
    }

    override func viewWillAppear(animated: Bool) {
        titleTextField.becomeFirstResponder()
        createNavBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
     
    }
    
    //MARK: - Attach Tool Bar for attach
    func addAttachToolBar() {
        descriptionTextView.inputAccessoryView = textInputView
        titleTextField.inputAccessoryView = textInputView
    }

    //MARK: - Creating navigation bar
    func createNavBar() {
        
        self.navigationController?.setupNavigationBar()
        if var creationType = type?.rawValue {
            if (creationType == "feeds") {
                creationType = String(creationType.characters.dropLast())
                
            }
            
           navigationController?.navigationBar.topItem?.title = "Create \(creationType.capitalizedString)"
        }
        let cancelButton = UIBarButtonItem(title: "Cancel", style:   UIBarButtonItemStyle.Plain, target: self, action: #selector(CreateFeedTaskController.cancelButtonPressed(_:)))
        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CreateFeedTaskController.nextButtonPressed(_:)))        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = nextButton
    }
    
    //MARK: - Next button action
    func nextButtonPressed(sender: UIBarButtonItem) {
        if (Helper.lengthOfStringWithoutSpace(titleTextField.text) == 0) || (isEdited == 0 || Helper.lengthOfStringWithoutSpace(descriptionTextView.text) == 0) {
            
            let alertController = UIAlertController(title: NSLocalizedString("takePhotoActionTitle", comment: ""), message: NSLocalizedString("enterAllFieldsMessage", comment: ""), preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("okActionTitle", comment: ""), style: .Cancel, handler: { (action) -> Void in })
            
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            let searchController = UIStoryboard.AutoResizing().instantiateViewControllerWithIdentifier(String(SearchUserController)) as! SearchUserController
            let nc = UINavigationController(rootViewController: searchController)
            if let creationType = type {
                searchController.type = creationType
            }
            searchController.titleText = titleTextField.text
            searchController.descriptionText = descriptionTextView.text
            searchController.attachedImages = textInputView.attachments
            searchController.delegate = self
            
            if let unwrappedSenderViewController = cardViewController {
                searchController.cardViewController = unwrappedSenderViewController
            }
            presentViewController(nc, animated: true, completion: nil)
        }
    }
    
    //MARK: - Cancel button action
    
    func cancelButtonPressed(sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("confirmationMessage", comment: "") , preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("okActionTitle", comment: ""), style: .Default, handler: { (action) -> Void in
        self.dismissViewControllerAnimated(true, completion: nil)
        
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .Cancel, handler: { (action) -> Void in
         
        })
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
        
       
        
    }

    //MARK: - Keyboard will show function
    func keyboardWillShow(notification : NSNotification){
//       textInputView.textView.userInteractionEnabled = false
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        keyboardHeight = keyboardFrame.height

    }
}

//MARK: Extensions
extension CreateFeedTaskController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        titleTextField.resignFirstResponder()
        let fixedWidth = descriptionTextView.frame.size.width
        descriptionTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = descriptionTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = descriptionTextView.frame
        let height1 = self.view.frame.size.height - keyboardHeight! - 130
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height:min( height1,newSize.height))
        descriptionTextView.frame = newFrame
        lineView.frame.origin.y = newFrame.origin.y + newFrame.height
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Description" {
            isEdited = 1
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            isEdited = 0
            textView.text = "Description"
            textView.textColor = UIColor.lightGrayColor()
        }
        
        descriptionTextView.text = textView.text
        textView.resignFirstResponder()
    }
}


extension CreateFeedTaskController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        titleTextField.text = textField.text
        textField.resignFirstResponder()
    }
}

extension CreateFeedTaskController: CreateFeedTaskSuccessDelegate {
    
    func createFeedTaskSuccess() {
        dismissViewControllerAnimated(false, completion: nil)
    }
}



