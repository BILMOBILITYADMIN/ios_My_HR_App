//
//  Timesheet.swift
//  Workbox
//
//  Created by Pavan Gopal on 17/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation

class Timesheet {
    var id :String?
    var date:NSDate?
    var status: TSStatus?
    var submittedHours: String?
    var allocatedHours: String?
    var isWorkingDay: Bool?
    var nonWorkingDayType: String?
    var projectHours: String?
    var nonProjectHours: String?
    var projects: [TSProject]?
    var week:TSWeekFromTo?
    var submittedBy: User?
}