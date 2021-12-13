//
//  Permission.swift
//  Workbox
//
//  Created by Ratan D K on 10/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation
import CoreData


class Permission: NSManagedObject {
    
    @NSManaged var moduleName: String?
    @NSManaged var create: String?
    @NSManaged var read: String?
    @NSManaged var update: String?
    @NSManaged var delete: String?
}
