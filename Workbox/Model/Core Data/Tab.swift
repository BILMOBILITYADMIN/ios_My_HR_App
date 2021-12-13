//
//  Tab.swift
//  Workbox
//
//  Created by Ratan D K on 03/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation
import CoreData


class Tab: NSManagedObject {
    
    @NSManaged var id: String?
    @NSManaged var displayName: String?
    @NSManaged var isDefault: NSNumber?
    @NSManaged var imageName: String?

}
