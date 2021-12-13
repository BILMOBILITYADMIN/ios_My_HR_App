//
//  Menu.swift
//  Workbox
//
//  Created by Ratan D K on 03/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation
import CoreData


class Menu: NSManagedObject {
    
    @NSManaged var imageName: String?
    @NSManaged var displayName: String?
    @NSManaged var id: String?
    @NSManaged var tabId: String?
    @NSManaged var subMenus: NSOrderedSet?

}
