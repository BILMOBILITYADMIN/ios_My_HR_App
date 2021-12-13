//
//  ConfigureController.swift
//  Workbox
//
//  Created by Ratan D K on 11/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import EZLoadingActivity
import Alamofire

class ConfigureController: UIViewController {
    
    var configureCompletionHandler:(() -> Void)!
    
    //MARK:-  OUTLETS
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textFieldBackgroundView: UIView!
    @IBOutlet weak var joinCherryWorkButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var configurationTextField: UITextField!
    
    //MARK:- VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUptextField()
        registerForKeyboardNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = true
        addRoundCornerAndShadow(4.0, shadowOpacityToApply: 0.3)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UI METHODS
    
    func setUptextField() {
        configurationTextField.borderStyle = UITextBorderStyle.None
        checkButton.setImage(AssetImage.ConfigureButton.image, forState: .Normal)
    }
    
    func addRoundCornerAndShadow(cornerRadiusToApply: CGFloat, shadowOpacityToApply: Float){
        let loginViewlayer = textFieldBackgroundView.layer
        loginViewlayer.masksToBounds = false
        loginViewlayer.cornerRadius = cornerRadiusToApply
        loginViewlayer.shadowPath = UIBezierPath(roundedRect: textFieldBackgroundView.bounds, cornerRadius: cornerRadiusToApply).CGPath
        loginViewlayer.shadowOffset = CGSizeZero
        loginViewlayer.shadowOpacity = shadowOpacityToApply
        
        let path = UIBezierPath(roundedRect: configurationTextField.bounds, byRoundingCorners: [.BottomLeft,.BottomRight], cornerRadii: CGSizeMake(cornerRadiusToApply, cornerRadiusToApply))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.CGPath
        configurationTextField.layer.mask = maskLayer
    }
    
    
    // MARK: - KEYBOARD HANDLING
    
    func registerForKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector : #selector(ConfigureController.keyboardWillShow(_:)), name : UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector : #selector(ConfigureController.keyboardWillHide(_:)), name : UIKeyboardWillHideNotification, object: nil)
        automaticallyAdjustsScrollViewInsets = false
        
    }
    
    func keyboardWillShow(notification : NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        let joinCherryWorkButtonFrame:CGRect = self.joinCherryWorkButton.frame
        
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
        scrollView.scrollRectToVisible(joinCherryWorkButtonFrame, animated: true)
        
    }
    
    func keyboardWillHide(notification : NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        scrollView.scrollIndicatorInsets = contentInsets
        scrollView.contentInset = contentInsets
    }
    
    
    // MARK: - ACTIONS
    
    @IBAction func configureTapped(sender: AnyObject) {
        if Helper.lengthOfStringWithoutSpace(configurationTextField.text) > 0 && Helper.isValidEmail(configurationTextField.text!) {
//            EZLoadingActivity.show("Loading", disableUI: true)
            LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)

            Alamofire.request(Router.ConfigureURL(urlString: configurationTextField.text!)).responseJSON { response in
//                EZLoadingActivity.hide()
                LoadingController.instance.hideLoadingView()

                
                switch response.result {
                    
                case .Success(let JSON):
                    print(JSON)
                    if let jsonDict = JSON as? NSDictionary {
                        let status = jsonDict[kServerKeyStatus]
                        
                        if status?.lowercaseString == kServerKeySuccess {
                            UserDefaults.setIsConfigured(true)
                            
                            if let data = jsonDict["data"], let imageName = data["logo"] as? String? {
                                UserDefaults.setCompanyLogoImageName(imageName)
                            }
                            
                            if self.configureCompletionHandler != nil {
                                self.configureCompletionHandler()
                            }
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
                    
                    if error.code == 3840 && response.response?.statusCode == 400 || (error.code == 403) {
                        message = "Invalid Credentials"
                    }
                    
                    let alertController = UIAlertController.init(title: kEmptyString, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
        else {
            let alertController = UIAlertController.init(title: kEmptyString, message: "Enter a valid email", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func joinCherryworkTapped(sender: AnyObject) {
        
        var title = kEmptyString
        var message = kEmptyString
        
        if Helper.lengthOfStringWithoutSpace(configurationTextField.text) > 0 && Helper.isValidEmail(configurationTextField.text!) {
            title = "Join Us"
            message = "An email has been sent to you with instructions to join us."
        }
        else {
            message = "Enter a valid email"
        }
        
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}
