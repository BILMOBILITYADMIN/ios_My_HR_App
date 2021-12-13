//
//  TimesheetWeek.swift
//  Workbox
//
//  Created by Ratan D K on 16/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation

class TimesheetWeek {
    
    var id: String?
    var submittedHours: String?
    var allocatedHours: String?
    var startDate: NSDate?
    var endDate: NSDate?
    var status: TSStatus?
    var timesheets: [Timesheet]?
    var submittedBy : User?
    var createdAt : NSDate?
    var updatedAt : NSDate?
    
}