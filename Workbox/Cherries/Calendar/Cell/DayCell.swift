//
//  DayCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 09/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class DayCell: UITableViewCell {

    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellView.layer.cornerRadius = 2
        cellView.clipsToBounds = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }



    func makeCal( empName : String, dateInString : NSDate, index: Int ){
        
        name.text = empName
        name.font = UIFont.systemFontOfSize(13)
        
        
        let dateString : String?
        let dayString : String?
        dateString = Helper.stringForDate(dateInString, format: "dd")
        dayString = Helper.stringForDate(dateInString, format: "EEE")
        dayLabel.text = dayString
        date.text = dateString
        
        if index != 0 {
            
            dayLabel.hidden = true
            date.hidden = true
            
        }
        
        profileImgView.clipToCircularCorner()
        profileImgView.image = AssetImage.placeholderProfileIcon.image
    }

    
    
    func createCell()
    {
        
        name.text = "Aditya.B"
        dayLabel.text = "Mon"
        date.text = "25"
        
//        name.text = leave.user?.firstName
//       
//        if let fromDate = leave.fromDate {
//        date.text = Helper.stringForDate(fromDate, format: "dd")
//        dayLabel.text = Helper.stringForDate(fromDate, format: "EEE")
//        }
  
    }
    
    
    
    
}


