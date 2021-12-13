//
//  LoginController.swift
//  Workbox
//
//  Created by Ratan D K on 07/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity
import CoreLocation
import CoreTelephony
import Kingfisher

class LoginController: UIViewController {
    
    var loginCompletionHandler:(() -> Void)!
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var companyImageView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    
    var regionName: String?
    var rollesDict = [NSMutableDictionary]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        applyUIProperties()
        versionLabel.text = "v" + String((NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"])!)
    }
    
    func applyUIProperties() {
        usernameField.borderStyle = UITextBorderStyle.None
        passwordField.borderStyle = UITextBorderStyle.None
        
        if let companyLogoName = UserDefaults.companyLogoImageName() where companyLogoName.characters.count > 0 {
            companyImageView.kf_setImageWithURL(Helper.nsurlFromStringWithImageSize(companyLogoName, imageSize: ImageSizeConstant.Medium)!)
        }
    }
    
    func registerForKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector : #selector(LoginController.keyboardWillShow(_:)), name : UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector : #selector(LoginController.keyboardWillHide(_:)), name : UIKeyboardWillHideNotification, object: nil)
        automaticallyAdjustsScrollViewInsets = false
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = true
        addRoundCornerAndShadow(4.0, shadowOpacityToApply: 0.3)
        usernameField.becomeFirstResponder()
    }
    
    func keyboardWillShow(notification : NSNotification){
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        let errorLabelFrame:CGRect = self.errorLabel.frame
        
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
        scrollView.scrollRectToVisible(errorLabelFrame, animated: true)
    }
    
    func keyboardWillHide(notification : NSNotification){
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Add round corner and Shadow to view and Login button
    func addRoundCornerAndShadow(cornerRadiusToApply: CGFloat, shadowOpacityToApply: Float){
        let loginViewlayer = loginView.layer
        loginViewlayer.masksToBounds = false
        loginViewlayer.cornerRadius = cornerRadiusToApply
        loginViewlayer.shadowPath = UIBezierPath(roundedRect: loginView.bounds, cornerRadius: cornerRadiusToApply).CGPath
        loginViewlayer.shadowOffset = CGSizeZero
        loginViewlayer.shadowOpacity = shadowOpacityToApply
        
        let path = UIBezierPath(roundedRect: loginButton.bounds, byRoundingCorners: [.BottomLeft,.BottomRight], cornerRadii: CGSizeMake(cornerRadiusToApply, cornerRadiusToApply))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.CGPath
        loginButton.layer.mask = maskLayer
    }
    
    
    // MARK: - Actions
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        if usernameField.text?.characters.count > 0 && passwordField.text?.characters.count > 0 {
            //            EZLoadingActivity.show("Loading", disableUI: true)
            LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
            
            Alamofire.request(Router.LoginUser(username: usernameField.text!, password: passwordField.text!)).responseJSON { response in
                //                EZLoadingActivity.hide()
                LoadingController.instance.hideLoadingView()
                
                self.getDeviceInfo()
                
                switch response.result {
                case .Success(let JSON):
                    print(JSON)
                    
                    if let jsonDict = JSON as? NSDictionary {
                        let status = jsonDict[kServerKeyStatus]
                        
                        if status?.lowercaseString == kServerKeySuccess {
                            if let dataDict = jsonDict[kServerKeyData] as? NSDictionary {
                                
                                let accessToken = dataDict["token"] as? String
                                UserDefaults.setAccessToken(accessToken)
                                
                                
                                if let name = dataDict["displayName"] as? String {
                                    UserDefaults.setLoggedInName(name)
                                }
                                if let officialInformation = dataDict["officialInformation"] as? NSDictionary {
                                    self.regionName = officialInformation["region"] as? String
                                    UserDefaults.setUserRegion(self.regionName)
                                    if let position = officialInformation.valueForKey("position") as? String{
                                        UserDefaults.setPosition(position)
                                    }
                                    if let id = officialInformation.valueForKey("id") as? String{
                                        UserDefaults.setId(id)
                                    }
                                    
                                }
                                if let leaveRoles = dataDict["leaveRoles"] as? NSArray{
                                    if let role = leaveRoles[0] as? NSDictionary{
                                        let leaveroles: NSMutableDictionary = NSMutableDictionary()
                                        leaveroles.setValue(role.valueForKey("name"), forKey: "name")
                                        leaveroles.setValue(role.valueForKey("roleText"), forKey: "roleText")
//                                        leaveroles.setValue(role.valueForKey("region"), forKey: "region")
                                        UserDefaults.setLeaveroles(leaveroles)
                                    }
                                    
                                }
                                if let cscReports = dataDict["cscReportsTo"] as? NSDictionary{
                                    UserDefaults.setManagerInfo(cscReports)
                                    
                                }
                      
                                print(jsonDict)
                                if let userRole = dataDict["roles"] as? NSArray {
                                    print(userRole)
//                                    let role = NSMutableDictionary()
//                                    for item in userRole { // loop through data items
//                                        print(item)
//                                        let role = NSMutableDictionary()
//                                        role.setValue(item["name"], forKey: "name")
//                                        let roleVal = item["region"];
//                                        if !(roleVal is NSNull) {
//                                            role.setValue(item["region"], forKey: "region")
//                                        }else{
//                                            role.setValue(self.regionName, forKey: "region")
//                                            
//                                        }
//                                        role.setValue("false", forKey: "selected")
//                                        self.rollesDict.append(role)
//                                    }
//                                    UserDefaults.setUserRole(role)
                                    
                                }
                                
                                if let userId = dataDict["_id"] as? String {
                                    UserDefaults.setUserId(userId)
                                }
                                let email = dataDict["email"] as? String
                                UserDefaults.setLoggedInEmail(email)
                                print(jsonDict)
                                let version = jsonDict["statusCode"] as? Float
                                if version == 426{
                                    let alert = UIAlertController(title: "Update available", message: "Download", preferredStyle: UIAlertControllerStyle.Alert)
                                    
                                    // add the actions (buttons)
                                    alert.addAction(UIAlertAction(title: "Update", style: .Default, handler: { action in
                                        print("Click of Update")
                                        UIApplication.sharedApplication().openURL(NSURL(string: kUpdateURL)!)
                                        
                                    }))
                                    
                                }
                                UserDefaults.setLoggedInUserDict(dataDict)
                                
                                if self.loginCompletionHandler != nil {
                                    self.loginCompletionHandler()
                                }
                                //                                self.downloadConfiguration()
                            }
                        }
                        else if status?.lowercaseString == kServerKeyFailure {
                            var message = jsonDict[kServerKeyMessage] as? String
                            if response.response?.statusCode == ErrorCode.Forbidden.rawValue {
                                message = "Invalid Credentials"
                            }
                            else if message == nil {
                                message = "An error occured"
                            }
                            
                            self.errorLabel.text = message
                            
                            let alertController = UIAlertController.init(title: kEmptyString, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                            alertController.addAction(okAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                    
                case .Failure(let error):
                    var message = error.localizedDescription
                    
                    if error.code == 3840 && response.response?.statusCode == 400 {
                        message = "Invalid Credentials"
                    }
                    
                    let alertController = UIAlertController.init(title: kEmptyString, message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
        else {
            errorLabel.text = "Enter Username and Password"
            
            let alertController = UIAlertController.init(title: kEmptyString, message: errorLabel.text, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func forgotPasswordTapped(sender: AnyObject) {
        let forgotPasswordController = UIStoryboard.loginStoryboard().instantiateViewControllerWithIdentifier(String(ForgotPasswordController)) as! ForgotPasswordController
        forgotPasswordController.forgotPasswordHandler = {() -> Void in
            self.navigationController?.popViewControllerAnimated(false)
        }
        navigationController?.pushViewController(forgotPasswordController, animated: true)
    }
    
    func getDeviceInfo() {
        getCurrentLocation()
        getMobileOperatorInformation()
        getAppVersion()
    }
}


extension LoginController{
    func getCurrentLocation(){
        
        self.locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
            print(CLLocationManager.locationServicesEnabled())
        }
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        switch CLLocationManager.authorizationStatus() {
            //        case .AuthorizedAlways: print("Came here")
        //            // ...
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
        case .AuthorizedWhenInUse, .Restricted, .Denied, .AuthorizedAlways:
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to be notified about current location, please open this app's settings and set location access to 'Always'.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    func getMobileOperatorInformation()
    {
        // Setup the Network Info and create a CTCarrier object
        //        let networkInfo = CTTelephonyNetworkInfo()
        //        let carrier = networkInfo.subscriberCellularProvider
    }
    
    
    func getAppVersion() {
        
        let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        
        if let version = nsObject
        {
            print("\(version)")
            
        }
    }
    
}


extension LoginController: CLLocationManagerDelegate{
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks,error)-> Void in
            if error != nil{
                print("error" + (error?.localizedDescription)!)
                return
            }
            if placemarks?.count > 0{
                let pm = placemarks![0]
                self.dispayLocationInfo(pm)
            }
        })
    }
    
    func dispayLocationInfo(placemark:CLPlacemark)
    {
        self.locationManager.stopUpdatingLocation()
        //        print(placemark.location)
        //        print(placemark.postalCode)
        //        print(placemark.administrativeArea)
        //        print(placemark.country)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error:" + error.localizedDescription)
    }
}

extension LoginController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        loginButtonTapped(loginButton)
        return true
    }
}
