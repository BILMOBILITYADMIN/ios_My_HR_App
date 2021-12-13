//
//  ActivityMonthCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 20/06/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class ActivityMonthCell: UITableViewCell {
    
    @IBOutlet weak var activityTableView: UITableView!
    var sectionHeaderDict = [ActivityLog]()
    var sectionDateDict = [String : AnyObject]()
    var datesInMonth = [NSDate]()
    var datesInString = [String]()
    var sectionDate  = [String]()
    let currentDate = NSDate()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        activityTableView.delegate = self
        activityTableView.dataSource = self
        activityTableView.registerNib(UINib(nibName: String("ActivityLogCell"), bundle: nil), forCellReuseIdentifier: String("ActivityLogCell"))
        activityTableView.layoutIfNeeded()
        activityTableView.tableFooterView = UIView(frame: CGRectZero)
        activityTableView.scrollEnabled = false
        activityTableView.contentInset = UIEdgeInsetsMake(-5, 0, 0, 0)
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func createCell(sectionDateArray : [ActivityLog]){
        sectionHeaderDict = sectionDateArray
        sortDate()
        sortDateIntoDict()
        activityTableView.reloadData()
    }
    
    func sortDate() {
        sectionDate.removeAll()
        if let aDate = sectionHeaderDict[0].time as NSDate? {
            var date = Helper.stringForDate(aDate, format: "dd MMMM, yyyy")
            sectionDate.append(date)
            for i in 0..<sectionHeaderDict.count {
                if let timeUpdated = sectionHeaderDict[i].time as NSDate? {
                    let aSectionDate = Helper.stringForDate(timeUpdated, format: "dd MMMM, yyyy")
                    if  aSectionDate != date {
                        sectionDate.append(aSectionDate)
                        date = Helper.stringForDate(timeUpdated, format: "dd MMMM, yyyy")
                    }
                }
            }
        }
    }
    
    
    
    func sortDateIntoDict(){
        var dateArray = [ActivityLog]()
        for item in sectionDate {
            dateArray.removeAll()
            for i in 0..<sectionHeaderDict.count {
                if Helper.stringForDate(sectionHeaderDict[i].time, format: "dd MMMM, yyyy") == item {
                    dateArray.append(sectionHeaderDict[i])
                }
            }
            sectionDateDict[item] = dateArray
        }
    }
    
}

extension ActivityMonthCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if sectionDate.isEmpty {
            return 1
        }
        else {
            return sectionDate.count
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionDateDict.isEmpty {
            return 1
        }
        else {
            if let dates = sectionDateDict[sectionDate[section]] as? [ActivityLog] {
                return dates.count
            }
            else {
                return 1
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(String("ActivityLogCell"), forIndexPath: indexPath) as! ActivityLogCell
        if sectionDate.isEmpty == false {
            if let dayData = sectionDateDict[sectionDate[indexPath.section]] as? [ActivityLog] {
                cell.createCell(indexPath.row, data: dayData[indexPath.row], count: dayData.count)
            }
        }
        else {
            print("No activities")
        }
        return cell
        
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let returnValue = sectionDate.isEmpty ? kEmptyString : sectionDate[section]
        
        return returnValue
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UIView()
        if sectionDate.isEmpty {
            sectionHeaderView.frame = CGRectZero
        }
        else {
            sectionHeaderView.frame = CGRect(x: 0, y: 0, width: activityTableView.frame.size.width , height: 44)
            let sectionTitleLabel = UILabel(frame: CGRect(x: 20, y: 0, width: sectionHeaderView.frame.size.width - 10, height: 44))
            let currentDateInString = Helper.stringForDate(currentDate, format: "dd MMMM, yyyy")
            let previousDay = currentDate.dateByAddingTimeInterval(24 * 60 * 60 * -1)
            if sectionDate[section] == currentDateInString {
                sectionTitleLabel.text = "Today"
            }
            else if sectionDate[section] == Helper.stringForDate(previousDay, format: "dd MMMM, yyyy") {
                sectionTitleLabel.text = "Yesterday"
            }
            else {
                    sectionTitleLabel.text = sectionDate[section]
            }
                sectionTitleLabel.font = UIFont.systemFontOfSize(14)
            sectionTitleLabel.textColor = UIColor.darkGrayColor()
            sectionHeaderView.addSubview(sectionTitleLabel)
            
        }
        return sectionHeaderView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sectionDate.isEmpty {
            return 1.0
        }
            
        else {
            
            if let activityLog = sectionDateDict[sectionDate[section]] as? [ActivityLog] {
                if activityLog[0].activity == "No Activities" {
                    return 1.0
                }
                else {
                    return 44.0
                }
            }
        }
        return 44.0
    }
    
}
