//
//  ProfileViewController.swift
//  Workbox
//
//  Created by Anagha Ajith on 11/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import EZLoadingActivity


class ProfileViewController: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate{
    
    var profileLogoutHandler:(() -> Void)!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var navigationBarTitle: UILabel!
    @IBOutlet var navigationBarView: UIView!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var tabTopView: UIView!
    @IBOutlet weak var userLastName: UILabel!
    @IBOutlet weak var userFirstName: UILabel!
    
    @IBOutlet weak var profileImageEditButton: UIButton!
    var kheaderViewHeight: CGFloat = 328
    var isEditable : Bool = false
    var pickedProfileImage: UIImage!
    let imagePickerController = UIImagePickerController()
    var isLoading = false
    var user =  User?()
    var experiences = [UserExperience]()
    var certificates = [UserCertification]()
    var isActivityButtonPressed : Bool = false
    var topLineView = UIView()
    var bottomLineView = UIView()
    let profileTopButton = UIButton()
    let activityLogTopButton = UIButton()
    let profileBottomButton = UIButton()
    let activityLogBottomButton = UIButton()
    let tabBottomView = UIView()
    let tabBottomPaddingView = UIView()
    var activityLogs = [ActivityLog]()
    var sectionMonthInString = [String]()
    var sectionMonth = [NSDate]()
    var sectionDate = [String]()
    let gradient = CAGradientLayer()
    var activityLogDict = [NSDate: AnyObject]()
    var collapsedSection = [Int]()
    var presentDate = NSDate()
    var currentDate = NSDate()
    let calendar = NSCalendar.currentCalendar()
    var startOfMonthInString = String()
    var endOfMonthInString = String()
    var joinDate = NSDate()
    var scrollOffset = CGFloat()
    var rowHeight = CGFloat()
    var rowHeightArray = [CGFloat]()
    var tappedSectionIndex = Int()
    var userDictionary = Dictionary<String,AnyObject>()
   
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadUser()
        kheaderViewHeight = self.view.bounds.width
        
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.contentInset = UIEdgeInsets(top: kheaderViewHeight, left: 0, bottom:0, right:0)
        tableView.contentOffset = CGPoint(x: 0, y: -kheaderViewHeight)
        tableView.addSubview(headerView)
        tableView.backgroundColor = UIColor.tableViewBackGroundColor()
        
        profileImageEditButton.addTarget(self, action: #selector(ProfileViewController.profileImageViewTapped(_:)), forControlEvents: .TouchUpInside)
        profileImageEditButton.setImage(AssetImage.edit.image.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
        profileImageEditButton.tintColor = UIColor.whiteColor()
        if isEditable == false {
            profileImageEditButton.hidden = true
        }
    
        
      //  let backgroundImageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.showUserProfileImage(_:)))
      //  backgroundImageViewTapGesture.numberOfTapsRequired = 1
      //  backgroundImageView.addGestureRecognizer(backgroundImageViewTapGesture)
       // backgroundImageView.userInteractionEnabled = true
        createBottomTabWithNoActivityLog()
        updateHeaderData()
        updateHeaderView()

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    class func profileDetailViewControllerForUser(user: User) -> ProfileViewController {
        let profileViewController = UIStoryboard.profileStoryboard().instantiateViewControllerWithIdentifier(String(self)) as! ProfileViewController
        profileViewController.user = user
        return profileViewController
    }
    
    //MARK: - Create top and bottom bars fpr Activity Log and Profile
    func createGradient() {
        gradient.frame = backgroundImageView.frame
        let color0 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor
        let color1 = UIColor.clearColor().CGColor
        let color2 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor
        gradient.colors = [color0, color1, color1, color1, color2]
        gradient.locations = [0.0 , 0.3, 0.5, 0.6, 1.0]
        backgroundImageView.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    func createBottomBarPaddingView() {
        tabBottomPaddingView.frame = CGRect(x: 0, y: headerView.frame.size.height - 20 , width: self.view.bounds.width, height: 40)
        tabBottomPaddingView.backgroundColor  = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        headerView.addSubview(tabBottomPaddingView)
    }

    func createBottomTabWithNoActivityLog() {
        profileBottomButton.frame =  CGRect (x: 5, y: -7, width: self.view.frame.size.width, height: 30)
        profileBottomButton.setTitle("PROFILE", forState: .Normal)
        profileBottomButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
        
        tabBottomView.frame = CGRect(x: 0, y: 0 , width: self.view.bounds.width, height: 35)
        tabTopView.hidden = true
        tableView.addSubview(tabBottomView)
        tabBottomView.addSubview(profileBottomButton)
    }
    
    func profileBottomPressed(sender : UIButton) {
        profileTopButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
        profileBottomButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
        activityLogTopButton.titleLabel?.font = UIFont.systemFontOfSize(13)
        activityLogBottomButton.titleLabel?.font = UIFont.systemFontOfSize(13)
        
        topLineView.frame = CGRect(x: 0, y: tabTopView.frame.size.height - 3, width: self.view.frame.size.width/2, height: 3)
        bottomLineView.frame = CGRect(x: 0, y: tabBottomView.frame.size.height - 3, width: self.view.frame.size.width/2, height: 3)
        
        isActivityButtonPressed = false
        tableView.reloadData()
    }
    
    func updateALL(){
        formatHeader()
        tableView.reloadData()
        self.updateHeaderData()
        self.formatNavigationBar()
    }
    
    
    //MARK: - Update headerview on scroll
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -kheaderViewHeight, width: self.view.frame.width, height: kheaderViewHeight)
        if tableView.contentOffset.y < -kheaderViewHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        headerView.frame = headerRect
        createBottomBarPaddingView()
    }
    
    
    //MARK: - Formatting header and navigation view
    func formatNavigationBar() {
        if let unwrappedUsername = user?.displayName{
            navigationBarTitle.text = unwrappedUsername.capitalizedString
        }
    }
    
    func updateHeaderData() {
        let avatarThumbnailImageUrl : NSURL?
        if let avatarString = user?.avatarURLString {
            
            let urlString = ConstantServer.imageRelativeUrl + avatarString
            avatarThumbnailImageUrl = NSURL(string: urlString)
        }
        else
        {
            avatarThumbnailImageUrl = nil
        }

        backgroundImageView.setImageWithOptionalUrl(avatarThumbnailImageUrl, placeholderImage:  AssetImage.placeholderProfileIcon.image)

        backgroundImageView.clipsToBounds = true
        
        
        if let unwrappedFirstName = user?.firstName{
            userFirstName.text = unwrappedFirstName.capitalizedString
        }
        
        if let unwrappedLastName = user?.lastName{
            userLastName.text = unwrappedLastName.capitalizedString
        }
        userFirstName.font = UIFont.systemFontOfSize(22)
        userLastName.font = UIFont.systemFontOfSize(22)
    }
    
    func showUserProfileImage(sender:UITapGestureRecognizer){
       // var photoArray = [Photo]()
         let urlString = ConstantServer.imageRelativeUrl + (user?.avatarURLString)!
        
        let photo = Photo(urlString: urlString, image: backgroundImageView.image!, captionString:"")
        
      //  ImageViewer.sharedInstance.showMultiImageViewer(backgroundImageView.image!, index: 0, collectionOfImages: photoArray, viewToOriginate: backgroundImageView)
        ImageViewer.sharedInstance.showSingleImageViewer(backgroundImageView.image!, imageToShow: photo, viewToOriginate: backgroundImageView)
    }
    
    func formatHeader() {
        updateHeaderData()
        updateHeaderView()
        imagePickerController.delegate = self
    }
    
    
    func profileImageViewTapped(sender:UITapGestureRecognizer) {
        let alertController = UIAlertController(title : "Update Photo", message :  nil, preferredStyle : .ActionSheet)
        
        let uploadAction = UIAlertAction(title : "Upload from Gallery", style : .Default,
                                         handler : { (action) -> Void in
                                            self.imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                                            self.imagePickerController.allowsEditing = true
                                            self.presentViewController(self.imagePickerController, animated : true, completion : nil)
        })
        let cameraAction = UIAlertAction(title : "Upload from Camera", style : .Default,
                                         handler : { (action) -> Void in
                                            self.imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                                            self.imagePickerController.allowsEditing = true
                                            self.presentViewController(self.imagePickerController, animated : true, completion : nil)
        })
        
        
        let deleteImage = UIAlertAction(title: "Delete profile image", style: .Destructive, handler: { (action) -> Void in
            self.pickedProfileImage = nil
            self.updateUserWithService(self.user!)
        })
        
        let cancelAction = UIAlertAction(title : "Cancel", style : .Cancel,
                                         handler : { (action) -> Void in
                                            print("Cancel Button Pressed")
        })
        alertController.addAction(uploadAction)
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        alertController.addAction(deleteImage)
        presentViewController(alertController, animated : true, completion : nil)
    }
    
    @IBAction func settingsIconPressed(sender: AnyObject) {
        let settingsViewController = UIStoryboard.profileStoryboard().instantiateViewControllerWithIdentifier(String(SettingsViewController)) as! SettingsViewController
        let nc = UINavigationController.init(rootViewController: settingsViewController)
        
        settingsViewController.settingsLogoutHandler = {() -> Void in
            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                if self.profileLogoutHandler != nil {
                    self.profileLogoutHandler()
                }
            })
        }
        presentViewController(nc, animated: true, completion: nil)
        
    }
    
    //MARK: - Dismiss Profile view controller

    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateUserWithService(user:User){
        ///files/avatar/f9888d4d08513559ff4f06aac4c1516ad931c10d2f7b575d599263966a56b1f4.jpg
        //        EZLoadingActivity.show("Loading", disableUI: true)
       // LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
       // var userDictionary = Dictionary<String,AnyObject>()
        userDictionary.updateValue(user.firstName!, forKey: "firstName")
        userDictionary["firstName"] = user.firstName
        userDictionary["lastName"] = user.lastName
        userDictionary["designation"] = user.designation
        
//        var imageString = ""
//        if let profileImage = compressedDataForImage(pickedProfileImage){
//            imageString = Helper.base64ForImage(profileImage)!
//        }
//        else{
//            imageString = Helper.base64ForImage(AssetImage.placeholderProfileIcon.image)!
//            // Server not sending response as per dictionary
//            
//        }
//        let utf8str = imageString.dataUsingEncoding(NSUTF8StringEncoding)
        userDictionary["avatar"] = user.avatarURLString
        var personalInformationDictionary = Dictionary<String,AnyObject>()
        personalInformationDictionary["maritalStatus"] = user.maritalStatus
        personalInformationDictionary["mobile"] = user.phoneNo
        personalInformationDictionary["email"] = user.email
        personalInformationDictionary["location"] = user.location
        userDictionary["personalInformation"] = personalInformationDictionary
        
        let experienceDictArray = NSMutableArray()
        if let experiences = user.experiences{
            for experience in experiences{
                var experienceDictionary = Dictionary<String,AnyObject>()
                experienceDictionary["designation"] = experience.designation
                experienceDictionary["companyName"] = experience.companyName
                
                var dateDictionary =  Dictionary<String,AnyObject>()
                dateDictionary["from"] = Helper.stringForDate(experience.fromDate, format: "MMM yyyy")
                dateDictionary["to"] = Helper.stringForDate(experience.toDate, format: "MMM yyyy")
                experienceDictionary["date"] = dateDictionary
                
                experienceDictionary["website"] = experience.websiteUrl
                experienceDictArray.addObject(experienceDictionary)
            }
        }
        userDictionary["experience"] = experienceDictArray
        
        let certificationsDictArray = NSMutableArray()
        if let certifications = user.certifications{
            for certificate in certifications{
                var certificationDictionary = Dictionary<String,AnyObject>()
                certificationDictionary["name"] = certificate.certificationTitle
                certificationDictionary["institution"] = certificate.instituteName
                certificationDictionary["date"] = Helper.stringForDate(certificate.certificationDate, format: "MMM yyyy")
                certificationsDictArray.addObject(certificationDictionary)
            }
        }
        userDictionary["certifications"] = certificationsDictArray
        
        Alamofire.request(Router.UpdateUserProfile(userId: user.id!, profileDict: userDictionary)).responseJSON { response in
            //            EZLoadingActivity.hide()
            LoadingController.instance.hideLoadingView()
            
            switch response.result {
                
            case .Success(let JSON):
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard let status = jsonData[kServerKeyStatus] as? String where status.lowercaseString == kServerKeySuccess else{
                    var message = jsonData[kServerKeyMessage] as? String
                    if response.response?.statusCode == ErrorCode.Forbidden.rawValue {
                        message = "Invalid credentials"
                    }
                    else if message == nil {
                        message = "An error occured"
                    }
                    
                    let alertController = UIAlertController.init(title: kEmptyString, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    print("Error Occured: JSON Without success")
                    return
                }
                
                guard let jsonDataDictionary = jsonData.valueForKey(kServerKeyData) as? NSDictionary else{
                    print("Cannot cast JSON to Dictionary: \(jsonData)")
                    return
                }
                
                self.user = User(JSON: jsonDataDictionary)
                UserDefaults.setLoggedInUserDict(jsonDataDictionary)
                self.updateALL()
                ActionController.instance.cardViewController?.clearAndReloadTableviewData()
                print("Response User Dictionary\(jsonDataDictionary)")
                
                
                
            case .Failure(let error):
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Invalid credentials"
                }
                let alertController = UIAlertController.init(title: kEmptyString, message:message , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }


    func updateOnScroll(scrollOffset : CGFloat ) {
        let alphaCalculated = (scrollOffset / 80)
        navigationBarView.backgroundColor = UIColor.navBarColor().colorWithAlphaComponent(alphaCalculated + 0.1)
        navigationBarTitle.textColor = UIColor.whiteColor().colorWithAlphaComponent(alphaCalculated + 0.1)
        
        bottomLineView.backgroundColor = UIColor.navBarColor().colorWithAlphaComponent(-alphaCalculated + 0.8)
        tabBottomView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        profileBottomButton.setTitleColor(UIColor.navBarColor().colorWithAlphaComponent(-alphaCalculated + 0.8), forState: .Normal)
    }
    
}


//MARK: Extensions

extension ProfileViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
            switch section{
            case 0 : return 3
//            case 1: return user?.officialInformation?.count ?? 1
            case 1: return 4
            default:return 1
                }
            }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
            guard let unwrappedUser = user else{
                let personalInfoCell = tableView.dequeueReusableCellWithIdentifier("PersonalInfoCell", forIndexPath: indexPath) as! PersonalInfoCell
                return personalInfoCell
            }
        
        let personalInfoCell = tableView.dequeueReusableCellWithIdentifier("PersonalInfoCell", forIndexPath: indexPath) as! PersonalInfoCell
       personalInfoCell.backgroundColor = UIColor.tableViewBackGroundColor()
        
        let profileTypeAray = ["First Name", "Last Name", "EmailID"]
        
        switch indexPath.section {
            
        case 0:
                 personalInfoCell.createCellImageView(indexPath.row, count: 4)
            switch indexPath.row {
            case 0 : personalInfoCell.updateCellData(user?.firstName, profileType: profileTypeAray[indexPath.row])
            case 1 : personalInfoCell.updateCellData(user?.lastName, profileType: profileTypeAray[indexPath.row])
            case 2 : personalInfoCell.updateCellData(user?.email, profileType: profileTypeAray[indexPath.row])
            default: personalInfoCell.updateCellData(user?.role, profileType: profileTypeAray[indexPath.row])
            }
            return personalInfoCell
        
        case 1:
            
                if let userInfo = user?.officialInformation {
                    if let allKeys = user?.officialInformation?.allKeys as? [String] {
                    
                var requiredFields = [String]()
                requiredFields.append((user?.officialInformation?["sapId"])! as? String ?? "")
                requiredFields.append((user?.officialInformation?["id"])! as? String ?? "")
                requiredFields.append((user?.officialInformation?["designation"])! as? String ?? "")
                requiredFields.append((user?.officialInformation?["department"])! as? String ?? "")
                let itemCount = userInfo.count
                var allKeysArray = [String]()
                        allKeysArray.append("SAP ID")
                        allKeysArray.append("EMPLOYEE ID")
                        allKeysArray.append("DESIGNATION")
                        allKeysArray.append("DEPARTMENT")
                personalInfoCell.createCellImageView(indexPath.row, count: itemCount)
//                        for item in allKeys {
//                            let str : String = Helper.insertSpace(NSMutableString(string: item))
//                            allKeysArray.append(str)
//                        }
                        
                let profileType = allKeys[indexPath.row]
                        
                        personalInfoCell.updateCellData(requiredFields[indexPath.row], profileType: allKeysArray[indexPath.row].captilizedEachWordString)
                    }
                }
                return personalInfoCell
                
                 default:
                let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
                return cell
            }
        }
    }

extension ProfileViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44))
        //sectionHeaderView.backgroundColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1.0)
            sectionHeaderView.backgroundColor = UIColor.tableViewBackGroundColor()
            let sectionHeader = UILabel(frame: CGRect(x: 20, y: 3, width: 300, height: 44))
            sectionHeader.font = UIFont.systemFontOfSize(13)
            sectionHeader.textColor = UIColor.blackColor()
            
            let headerImage = UIImageView(frame: CGRect(x: 0, y: 0, width: sectionHeaderView.frame.size.width, height: sectionHeaderView.frame.size.height ))
            
            var imageName = AssetImage.Slice1.image
            
            let myInsets : UIEdgeInsets = UIEdgeInsetsMake(16,16 ,16,16 )
            imageName = imageName.resizableImageWithCapInsets(myInsets)
            headerImage.image = imageName
            
            let editButtonHeight:CGFloat = 30
            let editButtonWidth:CGFloat = 45
            
            let editButton = UIButton()
            editButton.addTarget(self, action:#selector(ProfileViewController.editButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            editButton.frame = CGRectMake(tableView.frame.size.width - editButtonWidth, 8,editButtonWidth, editButtonHeight)
            editButton.setImage(AssetImage.edit.image.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
            editButton.tintColor = UIColor.navBarColor()
            
            let lineView = UIView(frame: CGRect(x: 15, y: 44, width: sectionHeaderView.frame.size.width -  30, height: 1))
            lineView.backgroundColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1.0)
            headerImage.addSubview(lineView)
            switch section{
            case 0:
                sectionHeader.text = "BASIC INFO"
                editButton.tag = section
            case 1:
                sectionHeader.text = "OFFICIAL INFO"
                editButton.tag = section
            default:
                sectionHeader.text = "TITLE"
            }
            sectionHeaderView.addSubview(headerImage)
            sectionHeaderView.addSubview(sectionHeader)
            sectionHeaderView.addSubview(lineView)
            sectionHeaderView.addSubview(editButton)
            if isEditable == false{
                editButton.hidden = true
            }
            editButton.hidden = true
        
            return sectionHeaderView
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return 44.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
        
    }
}


extension ProfileViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView()
        scrollOffset = scrollView.contentOffset.y + 150
        updateOnScroll(scrollOffset)
    }
}

extension ProfileViewController {
    
    func downloadUser(){
        
        guard let unwrappedUserID = self.user?.id else{
            return
        }
        if(!isLoading){
            isLoading = true
            //            EZLoadingActivity.show("Loading", disableUI: true)
            LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
            
            Alamofire.request(Router.GetUserProfile(userId: unwrappedUserID)).responseJSON { response in
                //                EZLoadingActivity.hide()
                LoadingController.instance.hideLoadingView()
                
                switch response.result {
                case .Success(let JSON):
                    guard let jsonData = JSON as? NSDictionary else{
                        print("Incorrect JSON from server : \(JSON)")
                        return
                    }
                    guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                        var message = jsonData[kServerKeyMessage]?.lowercaseString
                        
                        let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(okAction)
                        
                        if let senderController =   getTopViewController(){
                            senderController.presentViewController(alertController, animated: true, completion: nil)
                        }
                        print("Error Occured: JSON Without success")
                        return
                    }
                    
                    guard let jsonDataDictionary = jsonData.valueForKey("data") as? NSDictionary else{
                        print("Cannot cast JSON to Dictionary: \(JSON)")
                        return
                    }
                    self.user = User(JSON: jsonDataDictionary)
                    if let unwrappedDownloadedUser = self.user{
                        if unwrappedDownloadedUser.id == UserDefaults.loggedInUser()!.id {
                            UserDefaults.setLoggedInUserDict(jsonDataDictionary)
                        }
                    }
                    
                    self.tableView.reloadData()
                    self.updateALL()
                    
                    //                    EZLoadingActivity.hide()
                    LoadingController.instance.hideLoadingView()
                    
                    self.isLoading = false
                    
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    var message = error.localizedDescription
                    if error.code == 403 {
                        message = "Session Expired"
                    }
                    let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }
            }
            
        }
    }


    func editButtonPressed(sender:UIButton){
        //        pickedProfileImage = profileImageView.image
        let alertController = UIAlertController(title: "Alert", message: "Can not Edit, Data Empty", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
        })
        
        alertController.addAction(ok)
        
        
        switch(sender.tag){
        case 0:   let editPersonalInfoController = UIStoryboard.profileStoryboard().instantiateViewControllerWithIdentifier(String(EditPersonalInfoController)) as! EditPersonalInfoController
        
        if (user?.id != nil){
            
            editPersonalInfoController.user = self.user!
            let nc = UINavigationController.init(rootViewController: editPersonalInfoController)
            editPersonalInfoController.editPersonalInfoCompletionHandler = {(copyPersonalInfo:User)-> Void in
                self.user = copyPersonalInfo
                self.updateUserWithService(self.user!)
                self.tableView.reloadData()
            }
            
            presentViewController(nc, animated: true, completion: nil)
            print("editPersonalController")
        }
        else{
            presentViewController(alertController, animated: true, completion: nil)
            }
        default : print("No info")
    }

}
}

//MARK:- Image Orientation fix

extension UIImage {
    
    func fixOrientation() -> UIImage {
        
        // No-op if the orientation is already correct
        if ( self.imageOrientation == UIImageOrientation.Up ) {
            return self;
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        if ( self.imageOrientation == UIImageOrientation.Down || self.imageOrientation == UIImageOrientation.DownMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        }
        
        if ( self.imageOrientation == UIImageOrientation.Left || self.imageOrientation == UIImageOrientation.LeftMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        }
        
        if ( self.imageOrientation == UIImageOrientation.Right || self.imageOrientation == UIImageOrientation.RightMirrored ) {
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform,  CGFloat(-M_PI_2));
        }
        
        if ( self.imageOrientation == UIImageOrientation.UpMirrored || self.imageOrientation == UIImageOrientation.DownMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        }
        
        if ( self.imageOrientation == UIImageOrientation.LeftMirrored || self.imageOrientation == UIImageOrientation.RightMirrored ) {
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContextRef = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height),
                                                      CGImageGetBitsPerComponent(self.CGImage), 0,
                                                      CGImageGetColorSpace(self.CGImage),
                                                      CGImageGetBitmapInfo(self.CGImage).rawValue)!;
        
        CGContextConcatCTM(ctx, transform)
        
        if ( self.imageOrientation == UIImageOrientation.Left ||
            self.imageOrientation == UIImageOrientation.LeftMirrored ||
            self.imageOrientation == UIImageOrientation.Right ||
            self.imageOrientation == UIImageOrientation.RightMirrored ) {
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage)
        } else {
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage)
        }
        
        // And now we just create a new UIImage from the drawing context and return it
        return UIImage(CGImage: CGBitmapContextCreateImage(ctx)!)
    }
}

// MARK: - ImagePicker Delegates
extension ProfileViewController: UIImagePickerControllerDelegate,UIGestureRecognizerDelegate{
    
    func imagePickerController(picker : UIImagePickerController, didFinishPickingMediaWithInfo info : [String : AnyObject]) {
        LoadingController.instance.showLoadingWithUserInteractionForSender(self)
        pickedProfileImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        
        if let profileImage = compressedDataForImage(pickedProfileImage){
            let imageData:NSData = UIImagePNGRepresentation(profileImage.fixOrientation())!
            
            let strBase64:String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            self.user?.avatarURLString = strBase64
            //            imageString = Helper.base64ForImage(profileImage)!
                    }
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.updateUserWithService(self.user!)
        }
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}
