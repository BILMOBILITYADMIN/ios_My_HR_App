//
//  CalendarMonthController.swift
//  Workbox
//
//  Created by Anagha Ajith on 11/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import CVCalendar
import Alamofire
//import CVCalenderMenuView

enum ViewStatus : Int {
    
    case DailyView
    case WeekView
    case MonthView

}


class CalendarMonthController: UIViewController {
    //    @IBOutlet weak var monthLabel: UINavigationItem!
    //    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    var eventView : UIView!
    var eventLabel : UILabel!
    //    var monthLabel = UILabel()
    var teamCalendar = [Calendar]()
    var shouldShowDaysOut = true
    var animationFinished = true
    var selectedDay:DayView!
    var isWeekView : Bool = false
    var startDate : NSDate?
    var endDate : NSDate?
    let calendar = NSCalendar.currentCalendar()
    let presentDate = NSDate()
    var currentDate : NSDate?
    var dateArray = [String]()
    var CVDateArray = [CVDate]()
    var navBarDate = NSDate()
    var teamCalendarDict = [String:AnyObject]()
    var dateKeyArray = [NSDate]()
    var status = Int()
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        status = ViewStatus.MonthView.rawValue
        createNavBar()
        currentDate = presentDate
        getFirstDateOfMonth(currentDate!)
        downloadTeamCalendar()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
    
    func startOfMonth() -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        if let minusOneMonthDate = dateByAddingMonths(-1) {
            let minusOneMonthDateComponents = calendar.components([.Year, .Month], fromDate: minusOneMonthDate)
            print(minusOneMonthDate)
            let startOfMonth = calendar.dateFromComponents(minusOneMonthDateComponents)
            
            return startOfMonth
        }
        return nil
    }
    
    
    func dateByAddingMonths(monthsToAdd: Int) -> NSDate? {
        
        let calendar = NSCalendar.currentCalendar()
        let months = NSDateComponents()
        months.month = monthsToAdd
        return calendar.dateByAddingComponents(months, toDate: currentDate!, options: [])
    }
    
    func endOfMonth() -> NSDate? {
        
        let calendar = NSCalendar.currentCalendar()
        if let plusOneMonthDate = dateByAddingMonths(2) {
            let plusOneMonthDateComponents = calendar.components([.Year, .Month], fromDate: plusOneMonthDate)
            
            let endOfMonth = calendar.dateFromComponents(plusOneMonthDateComponents)?.dateByAddingTimeInterval(-1)
            
            return endOfMonth
        }
        return nil
    }
 
    func createNavBar() {
        navigationItem.title = Helper.stringForDate(navBarDate, format: "MMMM yyyy")
        self.navigationController?.setupNavigationBar()

        
        let closeItem = UIBarButtonItem.init(image: AssetImage.cross.image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CalendarMonthController.showSideMenu))
        
        if status == ViewStatus.MonthView.rawValue {
        let dayViewItem = UIBarButtonItem.init(image: AssetImage.calendarDaily.image , style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CalendarMonthController.showDayView))
        let weekViewItem = UIBarButtonItem.init(image:AssetImage.calendarWeek.image , style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CalendarMonthController.showWeekView))
            navigationItem.leftBarButtonItem = closeItem
            navigationItem.rightBarButtonItems = [weekViewItem,dayViewItem]
        }
        else if status == ViewStatus.WeekView.rawValue {
            let dayViewItem = UIBarButtonItem.init(image: AssetImage.calendarDaily.image , style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CalendarMonthController.showDayView))
            let monthViewItem = UIBarButtonItem.init(image: AssetImage.calendarMonth.image , style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CalendarMonthController.showMonthView))
            navigationItem.leftBarButtonItem = closeItem
            navigationItem.rightBarButtonItems = [monthViewItem,dayViewItem]
        }
        
        else {
            let monthViewItem = UIBarButtonItem.init(image: AssetImage.calendarMonth.image , style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CalendarMonthController.showMonthView))
            let weekViewItem = UIBarButtonItem.init(image:AssetImage.calendarDaily.image , style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CalendarMonthController.showWeekView))
            navigationItem.leftBarButtonItem = closeItem
            navigationItem.rightBarButtonItems = [weekViewItem,monthViewItem]
        }
    }
    
    func showDayView() {
        isWeekView = false
        status = ViewStatus.DailyView.rawValue
        let dayController = UIStoryboard.CalendarStoryboard().instantiateViewControllerWithIdentifier(String("CalendarDayController")) as! CalendarDayController
        let nc = UINavigationController.init(rootViewController: dayController)
        dayController.calendarMonthController = self
        dayController.teamCalendarDict = teamCalendarDict
        self.presentViewController(nc, animated: false, completion: nil)
    }
    
    func showWeekView(){
        status = ViewStatus.WeekView.rawValue
        isWeekView = true
        createNavBar()
        calendarView.changeMode(.WeekView)
    }
    
    func showMonthView(){
        isWeekView = false
        status = ViewStatus.MonthView.rawValue
        createNavBar()
        calendarView.changeMode(.MonthView)
    }
    
    func showSideMenu() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func teamCalendarDictionary(){
        dateKeyArray.removeAll()
        CVDateArray.removeAll()
        if let start = startDate{
            var date : NSDate = start
            for _ in 0...90 {
                var isPresent : Bool = false
                var objectsArray = [Calendar]()
                for item in teamCalendar{
                    if let unwrappedFromDate = item.fromDate, let unwrappedToDate = item.toDate {
                        
                        let toDatePlusOne = unwrappedToDate.dateByAddingTimeInterval(24 * 60 * 60)
                        
                        if ((calendar.compareDate(date, toDate: unwrappedFromDate, toUnitGranularity: .Hour) == .OrderedDescending) || (calendar.compareDate(date, toDate: unwrappedFromDate, toUnitGranularity: .Hour) == .OrderedSame)) &&  ((calendar.compareDate(date, toDate: toDatePlusOne, toUnitGranularity: .Hour) == .OrderedAscending) || (calendar.compareDate(date, toDate: toDatePlusOne, toUnitGranularity: .Hour) == .OrderedSame)){
                            objectsArray.append(item)
                            isPresent = true
                        }
                    }
                }
                if isPresent == true {
                    let dateInString = Helper.stringForDate(date, format: "dd/MM/yyyy")
                    print(dateInString)
                    dateKeyArray.append(date)
                    createCVDateArray(dateInString)
                    teamCalendarDict[dateInString] = objectsArray
                }
                date = date.dateByAddingTimeInterval(24 * 60 * 60)
            }
        }
    }
    
    func createCVDateArray(dateString : String) {
        
        let dateFromString = dateString.componentsSeparatedByString("/")
        let newCVDate = CVDate(day: Int(dateFromString[0])!, month: Int(dateFromString[1])!, week: ((Int(dateFromString[1])!)/7)+1, year: Int(dateFromString[2])!)
        
        CVDateArray.append(newCVDate)
    }
    
    func downloadTeamCalendar(){
        
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
                
//                
//                if let keyValues = jsonData.allKeys as? [String] {
//                    
//                    for key in keyValues {
//                        var calendarArray = [Calendar]()
//                        if let dataDict = jsonData[key] as? [NSDictionary] {
//                            
//                            if let dataArray = dataDict as NSArray? {
//                                
//                                for data in dataArray as! [NSDictionary] {
//                                    
//                                    if let teamCalendarParsed = Parser.teamCalendar(data) {
//                                        
//                                        calendarArray.append(teamCalendarParsed)
//                                    }
//                                }
//                            }
//                        }
//                        self.teamCalendarDict[key] = calendarArray
//                    }
//                }
//                
                
//                
//                
                
                
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
                self.teamCalendarDictionary()
                
                self.calendarView.contentController.refreshPresentedMonth()
                
                
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
 
    func usersForDate(queryDate : NSDate) -> [Calendar]{
        var filteredTeamCalender = [Calendar]()
        for item in teamCalendar {
            if let fromDate = item.fromDate, let toDate = item.toDate {
                if (queryDate.compare(fromDate) == .OrderedDescending || queryDate.compare(fromDate) == .OrderedSame) && (queryDate.compare(toDate) == .OrderedAscending || queryDate.compare(fromDate) == .OrderedSame) {
                    filteredTeamCalender.append(item)
                }
            }
        }
        return filteredTeamCalender
        
    }
    
}


extension CalendarMonthController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    // MARK: Optional methods
    
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")

        if teamCalendarDict.isEmpty == false {
       
        let dayController = UIStoryboard.CalendarStoryboard().instantiateViewControllerWithIdentifier(String("CalendarDayController")) as! CalendarDayController
            dayController.teamCalendarDict = teamCalendarDict
            dayController.dateKeyArray = dateKeyArray
            dayController.selectedDay = dayView.date.convertedDate()!
        let nc = UINavigationController.init(rootViewController: dayController)
        self.presentViewController(nc, animated: true, completion: nil)
        }
        else {
            
            print("--------NOTHING TO DISPLAY-------")
            
        }
       
    }
    
    func presentedDateUpdated(date: CVDate) {
        if navigationItem.title != date.globalDescription && self.animationFinished {
           navigationItem.title = date.globalDescription
            
        }
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }

    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .Short
    }
    
    func selectionViewPath() -> ((CGRect) -> (UIBezierPath)) {
        return { UIBezierPath(rect: CGRectMake(0, 0, $0.width, $0.height)) }
    }
    
    func shouldShowCustomSingleSelection() -> Bool {
        return false
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (dayView.isCurrentDay) {
            return true
        }
        return false
    }
    
    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
        
        
        let newView = UIView(frame: dayView.bounds)
        let eventView = UIView(frame: CGRect(x: 0, y: newView.bounds.width/3 + 12, width: newView.bounds.width - 5, height: newView.bounds.height - 40))
        var viewArray = [UIView]()
        let convertedDate = dayView.date
        let cDate = convertedDate.convertedDate()
        let datePlusOne = cDate?.dateByAddingTimeInterval(24 * 60 * 60)
        let dateInString = Helper.stringForDate(datePlusOne, format: "dd/MM/yyyy")
        
        if let calendarObject = teamCalendarDict[dateInString] as? [Calendar] {
            if let count = teamCalendarDict[dateInString]?.count {
                
                for i in 0..<count{
                    eventLabel = UILabel()
                    if let user = calendarObject[i].user {
                        eventLabel!.text = user.displayName
                
                    }
                    
                    eventLabel!.textAlignment = NSTextAlignment.Left
                    //            eventLabel!.frame = CGRectMake(0, 30, dayView.bounds.width, newView.bounds.width/3)
                    eventLabel!.numberOfLines = 1
                    eventLabel!.backgroundColor = UIColor(red: 218.0/255, green: 31.0/255, blue: 19.0/255, alpha: 1.0)
                    eventLabel!.font = UIFont.systemFontOfSize(11)
                    eventLabel.textColor = UIColor.whiteColor()
                    //            viewArray[i].addSubview(eventLabel)
                    
                    viewArray.append(eventLabel)
                }
            }
        }

        if isWeekView == false {
            
            eventView.createStackOfViews(true, viewHeightConstraint: NSLayoutConstraint(), viewArray: viewArray, numberOfElementsInEachRow: 1, fixedHeightOfEachView: 11, maximumNumberOfElementsToShow: 4, padding: 3.0)
        }
        else{
            eventView.createStackOfViews(true, viewHeightConstraint: NSLayoutConstraint(), viewArray: viewArray, numberOfElementsInEachRow: 1, fixedHeightOfEachView: 11, maximumNumberOfElementsToShow: nil, padding: 3.0)
        }
        
        return eventView
    }
    
    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
       
        var datePresent : Bool = false
        if let date1 = dayView.date as CVDate?{
            for date in CVDateArray {
                if date.convertedDate() == date1.convertedDate() {
                    datePresent = true
                    return datePresent
                }
                else {
                    datePresent = false
                }   
            }
        }
        return datePresent
    }
}


extension CalendarMonthController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return true
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 0.0
    }
    
    
}

extension CalendarMonthController {
    
    func toggleMonthViewWithMonthOffset(offset: Int) {
        let calendar = NSCalendar.currentCalendar()
        //        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(NSDate()) // from today
        components.month += offset
        let resultDate = calendar.dateFromComponents(components)!
        self.calendarView.toggleViewWithDate(resultDate)
    }
    
    func didShowNextMonthView(date: NSDate)
    {
        navBarDate = date.dateByAddingTimeInterval(24 * 60 * 60)
        getFirstDateOfMonth(date)
        downloadTeamCalendar()
        //        let calendar = NSCalendar.currentCalendar()
        //        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(date) // from today
        
//        print("Showing Month: \(components.month)")
    }
    
    
    func didShowPreviousMonthView(date: NSDate)
    {
        navBarDate = date.dateByAddingTimeInterval(24 * 60 * 60)
        getFirstDateOfMonth(date)
        downloadTeamCalendar()
        let components = Manager.componentsForDate(date) // from today
//        print("Showing Month: \(components.month)")
    }
    
    
    func getFirstDateOfMonth(date: NSDate) {
        
        let dateComponent = calendar.components([.Year, .Month], fromDate: date)
        let startOfPresentedMonth = calendar.dateFromComponents(dateComponent)
        currentDate = startOfPresentedMonth
        startDate = startOfMonth()
        endDate = endOfMonth()
        
    }
}






