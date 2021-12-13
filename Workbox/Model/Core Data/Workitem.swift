//
//  Workitem.swift
//  Workbox
//
//  Created by Chetan Anand on 15/04/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation
import CoreData


class Workitem: NSManagedObject {
    @NSManaged var workitemId: String? // primary key
    @NSManaged var workitemData: NSData?
    @NSManaged var updatedAt: String?
    @NSManaged var cardType: String?
    @NSManaged var cardSubtype: String?
    @NSManaged var isSynced: NSNumber?



// Insert code here to add functionality to your managed object subclass

}
