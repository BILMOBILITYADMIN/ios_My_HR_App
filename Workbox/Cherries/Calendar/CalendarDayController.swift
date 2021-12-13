//
//  CalendarDayController.swift
//  Workbox
//
//  Created by Anagha Ajith on 09/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire


class CalendarDayController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
     var calendarDay = [Calendar]()
    var daysInDateFormat = [NSDate]()
    var currentMonth = NSDate()
    var teamCalendar = [Calendar]()
    var startDate : NSDate?
    var endDate : NSDate?
    let calendar = NSCalendar.currentCalendar()
    var presentDate : NSDate?
    var teamCalendarDict = [String:AnyObject]()
    var selectedDay = NSDate()
    var dateKeyArray = [NSDate]()
    var calendarMonthController : CalendarMonthController?
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createNavBar()
        // Do any additional setup after loading the view.
        tableView.backgroundColor = UIColor.whiteColor()
        presentDate = startOfMonth()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startOfMonth() -> NSDate? {
        
        let calendar = NSCalendar.currentCalendar()
        if let minusOneMonthDate = dateByAddingMonths(-1) {
            let minusOneMonthDateComponents = calendar.components([.Year, .Month], fromDate: minusOneMonthDate)
            let startOfMonth = calendar.dateFromComponents(minusOneMonthDateComponents)
            
            return startOfMonth
        }
        return nil
    }
    
    func dateByAddingMonths(monthsToAdd: Int) -> NSDate? {
        
        let calendar = NSCalendar.currentCalendar()
        let months = NSDateComponents()
        months.month = monthsToAdd
        
        return calendar.dateByAddingComponents(months, toDate: selectedDay, options: [])
    }
    
    func currentMonthLoop(dict : [Calendar]){
        for i in 0..<dateKeyArray.count {
            if let date = dict[i].fromDate{
                let month = Helper.stringForDate(date, format: "MM")
                let currentDateInString = Helper.stringForDate(currentMonth, format: "MM")
                if currentDateInString != month {
                    teamCalendar[i].isFirstDay = true
                    currentMonth = date
                }
                else {
                    teamCalendar[i].isFirstDay = false
                }
                
            }
        }
    }
    
    func createNavBar() {
        let aCurrentMonth = NSDate()
        navigationItem.title = Helper.stringForDate(aCurrentMonth, format: "MMM yyyy")
        
        self.navigationController?.setupNavigationBar()
        let dismissItem = UIBarButtonItem.init(image: AssetImage.cross.image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CalendarDayController.showSideMenu))
        
        let monthViewItem = UIBarButtonItem.init(image: AssetImage.calendarMonth.image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CalendarDayController.showMonthView))
        let weekViewItem = UIBarButtonItem.init(image: AssetImage.calendarWeek.image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CalendarDayController.showWeekView))
        navigationItem.rightBarButtonItems = [weekViewItem,monthViewItem]
        navigationItem.leftBarButtonItem = dismissItem
    }
    
    func showMonthView() {
         dismissViewControllerAnimated(false, completion: nil)
        if let presentingVC = calendarMonthController {
            presentingVC.status = ViewStatus.MonthView.rawValue
             presentingVC.createNavBar()
            presentingVC.showMonthView()
        }
       
        
    }
    
    func showWeekView() {
        if let presentingVC = calendarMonthController {
              presentingVC.status = ViewStatus.WeekView.rawValue
            presentingVC.createNavBar()
            presentingVC.showWeekView()
        }
      
         dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    func showSideMenu() {
        
        dismissViewControllerAnimated(true, completion: nil)
        presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func usersForDate(queryDate : NSDate) -> [Calendar]{
        var filteredTeamCalender = [Calendar]()
        for item in teamCalendar {
            //            NSDate().dateByAddingTimeInterval(NSTimeInterval(NSNumber))
            if let fromDate = item.fromDate, let toDate = item.toDate {
                if (queryDate.compare(fromDate) == .OrderedDescending || queryDate.compare(fromDate) == .OrderedSame) && (queryDate.compare(toDate) == .OrderedAscending || queryDate.compare(fromDate) == .OrderedSame) {
                    filteredTeamCalender.append(item)
                }
            }
        }
        return filteredTeamCalender
        
    }

    func downloadTeamCalendar() {
        
        let startDateInString = Helper.stringForDate(startDate, format: ConstantDate.tzDateFormat)
        let endDateInstring = Helper.stringForDate(endDate, format: ConstantDate.tzDateFormat)
        
        Alamofire.request(Router.TeamCalendar(from: startDateInString , to: endDateInstring, fromSession: 1, toSession: 2)).responseJSON {response in
            
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                
                guard let jsonData = JSON as? [NSDictionary] else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                
                if let dataDict = jsonData as [NSDictionary]? {
                    var calendarArray = [Calendar]()
                    if let dataArray = dataDict as NSArray? {
                        
                        for data in dataArray as! [NSDictionary] {
                            
                            if let teamCalendarParsed = Parser.teamCalendar(data) {
                                
                                calendarArray.append(teamCalendarParsed)
                            }
                        }
                    }
                    self.teamCalendar = calendarArray
                }
                self.tableView.reloadData()
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
}

extension CalendarDayController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String("DayCell"), forIndexPath: indexPath) as! DayCell
       cell.createCell()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        print(teamCalendar[section].isFirstDay)
//        if let aFirstDay = teamCalendar[section].isFirstDay {
//            
//            if aFirstDay == true {
//                return 40.0
//            }
//            else {
//                return 15.0
//            }
//        }
//        
//        return 1.0
//        
//    }
    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if let aFirstDay = teamCalendar[section].isFirstDay {
//            if aFirstDay == true {
//                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
//                let headerLabel = UILabel(frame: CGRect(x: 50, y: 5, width: headerView.frame.size.width, height: headerView.frame.size.height))
//                
//                if let date = teamCalendar[section].fromDate {
//                    let sectionHeader = Helper.stringForDate(date, format: "MMM yyyy")
//                    headerLabel.text = sectionHeader
//                }
//                headerLabel.font = UIFont.systemFontOfSize(15)
//                headerLabel.textColor = UIColor.darkGrayColor()
//                tableView.addSubview(headerView)
//                headerView.addSubview(headerLabel)
//                print(headerView.frame)
//                return headerView
//            }
//            else {
//                
//                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 15))
//                headerView.backgroundColor = UIColor.whiteColor()
//                return headerView
//            }
//        }
//        return view
//    }
}
