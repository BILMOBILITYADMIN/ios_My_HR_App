//
//  Cherry.swift
//  Workbox
//
//  Created by Anagha Ajith on 15/04/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation
import CoreData


class Cherry: NSManagedObject {

    @NSManaged var id: String?
    @NSManaged var cherryName: String?
    @NSManaged var imageName: String?
    @NSManaged var type: String?
}
