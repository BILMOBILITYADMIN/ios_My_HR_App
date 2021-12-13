//
//  ActivityLogCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 01/06/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class ActivityLogCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var noActivityLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lineViewTop: UIView!
    @IBOutlet weak var lineViewBottom: UIView!
    
    @IBOutlet weak var statusView: UIView!
    
    var currentDate = NSDate()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func createCell(index: Int,data: ActivityLog ,count : Int) {
        if count == 1 {
            lineViewTop.backgroundColor = .whiteColor()
            lineViewBottom.backgroundColor = .whiteColor()
        }
        else if index == 0 && count > 1 {
            lineViewTop.backgroundColor = .whiteColor()
            lineViewBottom.backgroundColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1.0)
        }
        else if index == count - 1 && count > 1 {
            lineViewBottom.backgroundColor = .whiteColor()
            lineViewTop.backgroundColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1.0)
        }
        else {
            lineViewTop.backgroundColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1.0)
            lineViewBottom.backgroundColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1.0)
        }
        
        if data.activity == "No Activities" {
            activityLabel.hidden = true
            timeLabel.hidden = true
            statusView.hidden = true
            noActivityLabel.text = data.activity
            noActivityLabel.hidden = false
        }
        else {
            timeLabel.hidden = false
            let currentDateInString = Helper.stringForDate(currentDate, format: "dd MM yyyy")
//            let previousDateInString = Helper.stringForDate(currentDate.dateByAddingTimeInterval(24 * 60 * 60 * -1), format: "dd MM yyyy")
            if Helper.stringForDate(data.time, format: "dd MM yyyy") == currentDateInString {
                if let timeString = data.time?.timeAgo {
                    if timeString == "Just now" {
                        timeLabel.text = timeString
                    }
                    else {
                        timeLabel.text = timeString + " ago"
                    }
                }
                
            }
            else {
            let timeInString = Helper.stringForDate(data.time, format: "HH:mma")
            timeLabel.text = timeInString
            }
            statusView.layer.borderColor = UIColor.navBarColor().CGColor
            activityLabel.font = UIFont.systemFontOfSize(14)
            activityLabel.textColor = UIColor.darkGrayColor()
            activityLabel.hidden = false
            statusView.hidden = false
            noActivityLabel.hidden = true
        }
        
        statusView.clipToCircularCorner()
        statusView.layer.borderWidth = 2
        statusView.backgroundColor = .whiteColor()
        activityLabel.text = data.activity
        timeLabel.font = UIFont.systemFontOfSize(11)
        timeLabel.textColor = UIColor.darkGrayColor()
     
    }
    
}
