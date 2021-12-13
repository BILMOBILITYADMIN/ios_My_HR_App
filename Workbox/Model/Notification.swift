//
//  Notification.swift
//  Workbox
//
//  Created by Anagha Ajith on 28/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation

class Notification {
    
    var id : String?
    var applicationType : String?
    var message : String?
    var read : Bool?
    var content : NSDictionary?
    var endDate: NSDate?
    var startDate: NSDate?
    var workItemId: String?
    var sender : User?
    var receiver : User?
    var createdAt :NSDate?
    var updatedAt: NSDate?
    var updatedBy: User?
}