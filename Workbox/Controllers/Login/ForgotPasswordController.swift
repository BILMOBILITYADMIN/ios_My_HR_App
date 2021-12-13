//
//  ForgotPasswordController.swift
//  Workbox
//
//  Created by Pavan Gopal on 21/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity

class ForgotPasswordController: UIViewController {
    
    var forgotPasswordHandler:(() -> Void)!
    
    //MARK:- OUTLETS
    
    @IBOutlet weak var emailIdTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textFieldBackgroundView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK:-  VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addRoundCornerAndShadow(4.0, shadowOpacityToApply: 0.3)
        emailIdTextField.becomeFirstResponder()
    }
    
    //MARK:- HELPER METHODS
    func addRoundCornerAndShadow(cornerRadiusToApply: CGFloat, shadowOpacityToApply: Float){
        
        let loginViewlayer = contentView.layer
        loginViewlayer.masksToBounds = false
        loginViewlayer.cornerRadius = cornerRadiusToApply
        loginViewlayer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: cornerRadiusToApply).CGPath
        loginViewlayer.shadowOffset = CGSizeZero
        loginViewlayer.shadowOpacity = shadowOpacityToApply
        
        let path = UIBezierPath(roundedRect: sendButton.bounds, byRoundingCorners: [.BottomLeft,.BottomRight], cornerRadii: CGSizeMake(cornerRadiusToApply, cornerRadiusToApply))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.CGPath
        sendButton.layer.mask = maskLayer
    }
    
    func registerForKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector : #selector(ForgotPasswordController.keyboardWillShow(_:)), name : UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector : #selector(ForgotPasswordController.keyboardWillHide(_:)), name : UIKeyboardWillHideNotification, object: nil)
        automaticallyAdjustsScrollViewInsets = false
        
    }
    
    func keyboardWillShow(notification : NSNotification){
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        let messageLabelFrame:CGRect = self.messageLabel.frame
        
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
        scrollView.scrollRectToVisible(messageLabelFrame, animated: true)
    }
    
    func keyboardWillHide(notification : NSNotification){
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
    }
    
    //MARK:- ACTIONS
    @IBAction func sendTapped(sender: UIButton) {
        if Helper.lengthOfStringWithoutSpace(emailIdTextField.text) > 0 {
//            EZLoadingActivity.show("Loading", disableUI: true)
            LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)

            Alamofire.request(Router.ForgotPassword(email: emailIdTextField.text!)).responseJSON { response in
//                EZLoadingActivity.hide()
                LoadingController.instance.hideLoadingView()

                
                switch response.result {
                    
                case .Success(let JSON):
                    
                    if let jsonDict = JSON as? NSDictionary {
                        let status = jsonDict[kServerKeyStatus]
                        let version = jsonDict["statusCode"] as? Float
                        if version == 426{
                            let alert = UIAlertController(title: "Update available", message: "Download", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            // add the actions (buttons)
                            alert.addAction(UIAlertAction(title: "Update", style: .Default, handler: { action in
                                print("Click of Update")
                                UIApplication.sharedApplication().openURL(NSURL(string: kUpdateURL)!)
                                
                            }))
                            
                        }
                        if status?.lowercaseString == kServerKeySuccess {
                            
                            let alertController = UIAlertController.init(title: kEmptyString, message: "Password reset instructions have been sent to your email.", preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler:{(alert: UIAlertAction!) in if self.forgotPasswordHandler != nil {
                                self.forgotPasswordHandler()
                                }
                            })
                            alertController.addAction(okAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                        else if status?.lowercaseString == kServerKeyFailure {
                            var message = jsonDict[kServerKeyMessage] as? String
                            if message == nil {
                                message = "An error occured"
                            }
                            
                            let alertController = UIAlertController.init(title: kEmptyString, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                            alertController.addAction(okAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                    
                case .Failure(let error):
                    var message = error.localizedDescription
                    
                    if error.code == 3840 && response.response?.statusCode == 400 {
                        message = "Invalid email"
                    }
                    
                    let alertController = UIAlertController.init(title: kEmptyString, message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
        else {
            let alertView = UIAlertController.init(title: nil, message: "Invalid Email", preferredStyle: .Alert)
            let okAction = UIAlertAction.init(title: "OK", style: .Default, handler: nil)
            alertView.addAction(okAction)
            presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    @IBAction func backTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
