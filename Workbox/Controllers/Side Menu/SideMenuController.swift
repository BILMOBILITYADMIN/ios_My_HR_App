//
//  SideMenuController.swift
//  Workbox
//
//  Created by Ratan D K on 07/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

protocol TSLeftMenuDelegate {
    func itemSelectedAtIndex(index: NSIndexPath)
}

class SideMenuController: UIViewController {
    
    var dismissControllerHandler:(() -> Void)!
    var delegate: TSLeftMenuDelegate?
    
    @IBOutlet weak var TSMenuHeaderView: UIView!
    @IBOutlet weak var menuContainerXConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var profileBackgroundView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    var items = [["e-Bat","Performance History"],["",""],["",""],["",""],["",""],["",""]]
    //var items = Array<String>(count: 5, repeatedValue: Array<String>(count: 6, repeatedValue: 0))
  //  var items:[[AnyObject]] = []
    var currentIndex:NSIndexPath = NSIndexPath()
    var selectedRowIndex = -1
    var sectionCount = 1
    var sectionHeader : [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // items.append([])
        view.backgroundColor = UIColor.tableViewBackGroundColor()
       // view.backgroundColor = UIColor.clearColor()
        view.opaque = false
        updateUI()
    }
    
    func updateUI() {
        menuContainerView.layer.shadowOpacity = 0.8
        self.menuContainerXConstraint.constant = -menuContainerView.frame.width
        
        
        // Adding blur effect to background image
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light) //Adding blur to the background image
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = TSMenuHeaderView.bounds
        profileBackgroundView.clipsToBounds = true
        profileBackgroundView.addSubview(blurEffectView)
        
        //Adding gradient to background view
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = profileBackgroundView.bounds
        gradient.colors = [UIColor.clearColor().CGColor,UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        profileBackgroundView.layer.insertSublayer(gradient, atIndex: 0)
        
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        profileImageView.clipsToBounds = true
        
        nameLabel.text = UserDefaults.loggedInUser()?.displayName
        emailLabel.text = UserDefaults.loggedInUser()?.email
        
        
        
        
    
        //Replacing above implementation as we need to use image with size
        let avatarThumbnailImageUrl : NSURL?
        if let avatarString = UserDefaults.loggedInUser()?.avatarURLString {
            
            let urlString = ConstantServer.imageRelativeUrl + avatarString
            avatarThumbnailImageUrl = NSURL(string: urlString)
        }
        else
        {
            avatarThumbnailImageUrl = nil
        }
        profileImageView.setImageWithOptionalUrl(avatarThumbnailImageUrl, placeholderImage:  AssetImage.placeholderProfileIcon.image)
        profileBackgroundView.setImageWithOptionalUrl(avatarThumbnailImageUrl, placeholderImage:  AssetImage.placeholderProfileIcon.image)
        
        
        
        
        
//        
//        profileImageView.setImageWithOptionalUrl(UserDefaults.loggedInUser()?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.placeholderProfileIcon.image)
//        profileBackgroundView.setImageWithOptionalUrl(UserDefaults.loggedInUser()?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.placeholderProfileIcon.image)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SideMenuController.profileImageTapped(_:)))
        profileImageView.userInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func profileImageTapped (img : AnyObject){
        
        //                let profileViewController = UIStoryboard.profileStoryboard().instantiateViewControllerWithIdentifier(String(ProfileViewController)) as! ProfileViewController
        guard let unwrappedUser = UserDefaults.loggedInUser() else{
            return
        }
        
        let   profileViewController = ProfileViewController.profileDetailViewControllerForUser(unwrappedUser)
        profileViewController.isEditable = true
        profileViewController.profileLogoutHandler = {() -> Void in
            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                
            })
        }
        presentViewController(profileViewController, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func dismissTapped(sender: AnyObject) {
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.menuContainerXConstraint.constant = -self.menuContainerView.frame.width
            self.view.layoutIfNeeded()
            }, completion: {finished in
                if self.dismissControllerHandler != nil {
                    self.dismissControllerHandler()
                }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.menuContainerXConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SideMenuController: UITableViewDataSource, UITableViewDelegate {
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        tableView.backgroundColor = UIColor.tableViewBackGroundColor()
        return sectionCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        print("items >>>>\(items)  \(items[section].count)")
        
        return items[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TSLeftMenuCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = items[indexPath.section][indexPath.row]
        cell.textLabel?.textColor = UIColor.darkGrayColor()
        cell.backgroundColor = UIColor.tableViewCellBackGroundColor()
        cell.accessoryType = (currentIndex == indexPath) ? .Checkmark : .None
        cell.textLabel?.font = (currentIndex == indexPath) ? UIFont.boldSystemFontOfSize(UIFont.systemFontSize()) : UIFont.systemFontOfSize(UIFont.systemFontSize())
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        currentIndex = indexPath
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.menuContainerXConstraint.constant = -self.menuContainerView.frame.width
            self.view.layoutIfNeeded()
            }, completion: {finished in
                self.delegate?.itemSelectedAtIndex(indexPath)
        })
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sectionCount == 1{
            return nil
        }else{
            return sectionHeader[section]
        }
    }
}
