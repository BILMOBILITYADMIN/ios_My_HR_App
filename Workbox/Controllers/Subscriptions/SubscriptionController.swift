//
//  SubscriptionController.swift
//  Workbox
//
//  Created by Anagha Ajith on 20/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire
import BRYXBanner

class SubscriptionController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var kDropDownButtonTag = 1000
    var collapsedSection = [Int]()
    var subscriptionArray = [Subscription]()
    var typeArray = [String]()
    var subscriptionDict = [String : AnyObject]()
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createNavBar()
        downloadSubscription()
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Create Navigation bar
    func createNavBar() {
        
        self.navigationController?.setupNavigationBar()
        navigationItem.title = "Subscriptions"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(SubscriptionController.saveButtonPressed(_:)))
    }
    
    
    //MARK: - Update Subscription network call
    func saveButtonPressed(sender : UIBarButtonItem) {
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
        var updatedSubscriptionDict = Dictionary<String,AnyObject>()
        let subsArray = NSMutableArray()
        
        for i in 0..<typeArray.count{
            if let filteredSubscriptionArray = subscriptionDict[typeArray[i]] as? [Subscription] {
                for i in 0..<filteredSubscriptionArray.count{
                    var subDict = Dictionary<String,AnyObject>()
                    
                    subDict["type"] = filteredSubscriptionArray[i].type
                    subDict["subtype"] = filteredSubscriptionArray[i].subtype
                    subDict["mandatory"] = filteredSubscriptionArray[i].mandatory
                    subDict["subscribed"] = filteredSubscriptionArray[i].subscribed
                    subsArray.addObject(subDict)
                    
                }
                
            }
            
        }
        
        updatedSubscriptionDict["subscriptions"] = subsArray
        
        //Update Subscription network call
        Alamofire.request(Router.UpdateSubscription(subscriptionDict: updatedSubscriptionDict)).responseJSON { response in
            
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else {
                    print("Error Occured: JSON Without success")
                    return
                }
                
                LoadingController.instance.hideLoadingView()
                
                let banner = Banner(title: "Subscription", subtitle: "Subscriptions Updated", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                
//                self.dismissViewControllerAnimated(false, completion: nil)
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Session Expired"
                    NSLog(message)
                }
                let alertController = UIAlertController.init(title: kEmptyString, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    
    //MARK: - Download Subscription
    func downloadSubscription() {
        
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
        
        Alamofire.request(Router.GetSubscription()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else {
                    print("Error Occured: JSON Without success")
                    return
                }
                
                LoadingController.instance.hideLoadingView()
                
                if let dataDict = jsonData.valueForKey("data") as? [NSDictionary]  {
                    var subArray = [Subscription]()
                    if let dataArray = dataDict as NSArray? {
                        for data in dataArray as! [NSDictionary] {
                            if let subParsed = Parser.subscriptionParsed(data){
                                subArray.append(subParsed)
                            }
                        }
                        self.subscriptionArray = subArray
                    }
                }
                self.filterToDictionary()
                self.tableView.reloadData()
                
                if self.subscriptionArray.isEmpty == true {
                    
                    let messageLabel = UILabel(frame: CGRectMake(0,self.view.frame.height/2 - 64,self.view.frame.width, 40))
                    messageLabel.textAlignment = NSTextAlignment.Center
                    messageLabel.textColor = UIColor.grayColor()
                    messageLabel.font = UIFont.boldSystemFontOfSize(18)
                    messageLabel.text = "No Subscriptions"
                    
                    self.tableView.separatorColor = UIColor.clearColor()
                    self.tableView.userInteractionEnabled = false
                    self.tableView.addSubview(messageLabel)
                }
                
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Session Expired"
                    NSLog(message)
                }
                let alertController = UIAlertController.init(title: kEmptyString, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    
    //MARK: Filter to dictionary with subtypes as key
    func filterToDictionary(){
        
        let subArray = subscriptionArray as NSArray
        typeArray = subArray.valueForKeyPath("@distinctUnionOfObjects.type") as! [String]
        
        var aSubcriptionArray = [Subscription]()
        
        for i in 0..<typeArray.count {
            aSubcriptionArray.removeAll()
            
            for data in subscriptionArray {
                if let type = data.type {
                    if typeArray[i] == type {
                        aSubcriptionArray.append(data)
                    }
                }
            }
            subscriptionDict[typeArray[i]] = aSubcriptionArray
        }
    }
    
    
    func indexPathsForSectionWithNumberOfRows( section: Int, noOfRows: Int) -> [NSIndexPath] {
        
        var indexPaths = [NSIndexPath]()
        indexPaths.removeAll()
        var i = 0
        
        while (i < noOfRows){
            let indexPath = NSIndexPath(forRow: i, inSection: section)
            indexPaths.append(indexPath)
            i += 1
        }
        return indexPaths
    }
    
}


//MARK: - Extensions
extension SubscriptionController : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return typeArray.count
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if collapsedSection.contains(section) == true{
            return 0
        }
        else{
            if let count = subscriptionDict[typeArray[section]]?.count{
                return count
            }
            else{
                print("Tasks not present/Invalid Submit")
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String("SubscriptionCell"), forIndexPath: indexPath) as! SubscriptionCell
        let cellData = subscriptionDict[typeArray[indexPath.section]] as! [Subscription]
        
        if let mandatorySubscription = cellData[indexPath.row].mandatory {
            if mandatorySubscription == true {
                cell.selectionStyle = .None
                cell.userInteractionEnabled = false
            }
        }
        
        cell.createCell(cellData[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let sectionData = subscriptionDict[typeArray[indexPath.section]]! as! [Subscription]
        
        if let isSubscribed = sectionData[indexPath.row].subscribed {
            if isSubscribed == true {
                
                sectionData[indexPath.row].subscribed = false
            }
            else {
                sectionData[indexPath.row].subscribed = true
            }
        }
        
        tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionView: UIView?
        let dropDownButton = UIButton()
        
        dropDownButton.tag = kDropDownButtonTag
        dropDownButton.frame = CGRectMake(tableView.frame.size.width - 30, 10 , 20, 20 )
        dropDownButton.setImage(AssetImage.arrow.image, forState: UIControlState.Normal)
        dropDownButton.userInteractionEnabled = false
        
        
        let typeLabel = UILabel.init(frame: CGRectMake(8, 10 , tableView.frame.size.width/2 - 20 , 15))
        typeLabel.text = typeArray[section].captilizedEachWordString
        typeLabel.font = UIFont.systemFontOfSize(16)
        typeLabel.textColor = UIColor.darkGrayColor()
        
        sectionView = UIView.init(frame:CGRectMake(0, 0, tableView.frame.size.width, 44))
        sectionView?.addSubview(typeLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TSApprovalDetailController.sectionTapped(_:)))
        sectionView!.addGestureRecognizer(tapGesture)
        sectionView?.backgroundColor = UIColor.sectionBackGroundColor()
        sectionView?.tag = section
        sectionView?.addSubview(dropDownButton)
        return sectionView
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func sectionTapped(sender:UITapGestureRecognizer){
        
        tableView.beginUpdates()
        
        guard let section = sender.view?.tag else{
            print("Section ERROR")
            return
        }
        
        let shouldCollapse : Bool = !collapsedSection.contains(section)
        
        if let button = sender.view?.viewWithTag(kDropDownButtonTag) {
            
            if shouldCollapse {
                
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    button.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI))
                })
            }
            else {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    button.transform = CGAffineTransformMakeRotation(CGFloat(0))
                })
            }
        }
        
        let sectionData = subscriptionDict[typeArray[section]]!
        if (shouldCollapse) {
            
            let numOfRows = sectionData.count
            let  indexPaths = indexPathsForSectionWithNumberOfRows(section, noOfRows: numOfRows)
            
            collapsedSection.append(section)
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
        }
        else {
            let numOfRows = sectionData.count
            let  indexPaths = indexPathsForSectionWithNumberOfRows(section, noOfRows: numOfRows)
            collapsedSection.removeAtIndex((collapsedSection.indexOf(section))!)
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
        }
        tableView.endUpdates()
    }
    
}







