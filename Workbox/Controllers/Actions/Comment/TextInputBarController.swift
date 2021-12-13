//
//  TextInputBarController.swift
//  Workbox
//
//  Created by Chetan Anand on 15/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import ALTextInputBar

class TextInputBarController: UIViewController {

    let textInputView = CWTextInputView()
    var actionProperty : ActionProperty?
    var isAttachmentEnabled : Bool = true
    
    // This is how we attach the input bar to the keyboard
    override var inputAccessoryView: UIView? {
        get {
            return textInputView
        }
    }
    
    // This is also required
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TextInputBarController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        //        textInputView.actionProperty = actionProperty
        textInputView.textView.becomeFirstResponder()
        
        guard let unwrappedActionType = actionProperty?.actionType else{
            return
        }
        
        //Set textview placeholder with action
        if unwrappedActionType == CardAction.Comment{
            textInputView.addAction(actionProperty, placeholderText: "Write your comment...", leftViewEnabled: true, textBarEnabled: true)
        }
        else if unwrappedActionType == CardAction.Reject{
            textInputView.addAction(actionProperty, placeholderText: "Write reason for rejection...", leftViewEnabled: false, textBarEnabled: true)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        textInputView.textView.becomeFirstResponder()
        
        UIView.animateWithDuration(0.8, delay: 0, options:[UIViewAnimationOptions.CurveEaseOut], animations: {
            self.view.backgroundColor = UIColor(red: 0 , green: 0, blue: 0, alpha: 0.7)
            }, completion:nil)
        
        //{(Bool) in self.cl()}
    }
        func dismissKeyboard() {
        textInputView.textView.resignFirstResponder()
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
   }
