//
//  TSInfoController.swift
//  Workbox
//
//  Created by Pavan Gopal on 15/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class TSInfoController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var kDropdownButtonTag = 1000
    
    var collapsedSection = [Int]()
    var timesheets = [TSInfo]()
    var alloactedProjects: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        createData()
        setTableViewHeaderView("AllocatedProject(3)")
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createData(){
        
        for _ in 0  ..< 3  {
        let timesheet = TSInfo()
        timesheet?.activity = "E6-1"
        timesheet?.network = "000000323232"
        timesheet?.hoursPerDay = "8.3"
           timesheet?.projectName = "RWBSE-0529-001-001"
        timesheet?.fromDate = NSDate.init()
            timesheets.append(timesheet!)
        }
        
    }
    
    
    func setupNavigationBar() {
        self.navigationController?.setupNavigationBar()
    }
    
    func setTableViewHeaderView(string:String){
        let headerView = UIView.init(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
        let labelView = UILabel.init(frame: CGRectMake(8, 0 , tableView.frame.size.width, 30))
        labelView.text = string
        labelView.textColor = UIColor.darkGrayColor()
        headerView.addSubview(labelView)
        tableView.tableHeaderView = headerView
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension TSInfoController:UITableViewDataSource,UITableViewDelegate{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return timesheets.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if collapsedSection.contains(section) == true{
            return 0
        }
        else {
            return 4
        }
    }
    
    func indexPathsForSectionWithNumberOfRows(section :Int , numberOfRows :Int) -> [NSIndexPath]{
        
        var indexPaths = [NSIndexPath]()
        indexPaths.removeAll()

        var i = 0
        while(i < numberOfRows){
            let indexPath = NSIndexPath(forRow: i, inSection: section)
            
            indexPaths.append(indexPath)
            i += 1
        }
        return indexPaths
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("TimeSheetInfoCell", forIndexPath: indexPath)
        let timesheet = timesheets[indexPath.section]
        cell.textLabel?.font = UIFont.systemFontOfSize(14)
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(14)
        switch(indexPath.row){
            
        case 0 :   cell.textLabel?.text = "Network"
        cell.detailTextLabel?.text = timesheet.network
        case 1:   cell.textLabel?.text = "Activity"
        cell.detailTextLabel?.text = timesheet.activity
        case 2:   cell.textLabel?.text = "Hours per day"
        cell.detailTextLabel?.text = timesheet.hoursPerDay
        case 3:   cell.textLabel?.text = "Period"
        cell.detailTextLabel?.text = Helper.stringForDate(timesheet.fromDate, format: "dd MMM")
        default : break
            
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionView : UIView?
        let dropDownButton = UIButton()
        
        dropDownButton.tag = kDropdownButtonTag
        dropDownButton.frame = CGRectMake(tableView.frame.size.width - 40, 0, 40, 40)
        dropDownButton.setImage(AssetImage.arrow.image, forState: UIControlState.Normal)
        dropDownButton.userInteractionEnabled = false
        
        let labelView = UILabel.init(frame: CGRectMake(8, 10 , tableView.frame.size.width, 30))
       
        labelView.text = timesheets[section].projectName
        labelView.textColor = UIColor.navBarColor()
        
         sectionView = UIView.init(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        
        sectionView?.addSubview(labelView)

       
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TSInfoController.sectionTapped(_:)))
        sectionView!.addGestureRecognizer(tapGesture)
        sectionView?.backgroundColor = UIColor.whiteColor()
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
        
        if let button = sender.view?.viewWithTag(kDropdownButtonTag) {
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
        
        if (shouldCollapse) {
            let numOfRows = 4
            let  indexPaths = indexPathsForSectionWithNumberOfRows(section, numberOfRows: numOfRows)
            
            collapsedSection.append(section)
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
        }
        else {
            let numOfRows = 4
            let  indexPaths = indexPathsForSectionWithNumberOfRows(section, numberOfRows: numOfRows)
            collapsedSection.removeAtIndex((collapsedSection.indexOf(section))!)
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
        }
        tableView.endUpdates()
    }
}
