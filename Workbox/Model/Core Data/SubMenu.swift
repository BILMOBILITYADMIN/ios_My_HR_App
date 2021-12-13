//
//  SubMenu.swift
//  Workbox
//
//  Created by Ratan D K on 03/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation
import CoreData


class SubMenu: NSManagedObject {
    
    @NSManaged var displayName: String?
    @NSManaged var id: String?
    @NSManaged var imageName: String?
    @NSManaged var menu: Menu?

}
