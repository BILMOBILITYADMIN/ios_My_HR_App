//
//  TSApprovalProjectCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 17/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class TSApprovalProjectCell: UITableViewCell {
    @IBOutlet weak var project: UILabel!
    @IBOutlet weak var task: UILabel!

    @IBOutlet weak var taskHours: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Function to update project cell
    func updateProjectCell(timesheet : Task,projectName : String){
        task.text = timesheet.name
        taskHours.backgroundColor = UIColor.navBarColor()
        taskHours.layer.cornerRadius = 8
        project.text = projectName
        taskHours.text = (timesheet.hours != nil) ? (kSpaceString + " " + Helper.timeInHMformatForMinutes(Int(timesheet.hours! * 60)) + " " + kSpaceString) : kEmptyString
        taskHours.clipsToBounds = true
    }
}
