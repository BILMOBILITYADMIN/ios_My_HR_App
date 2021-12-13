//
//  CardConfig.swift
//  Workbox
//
//  Created by Ratan D K on 03/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation
import CoreData


class CardConfig: NSManagedObject {
    
    @NSManaged var type: String?
    @NSManaged var subType: String?
    @NSManaged var fields: NSData?
    @NSManaged var templateId: String?
    @NSManaged var actions: NSData?

}

