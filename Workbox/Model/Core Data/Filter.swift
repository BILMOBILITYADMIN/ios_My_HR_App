//
//  Filter.swift
//  
//
//  Created by Chetan Anand on 05/02/16.
//
//

import Foundation
import CoreData


class Filter: NSManagedObject {

    @NSManaged var optionId: String?
    @NSManaged var optionIconName: String?
    @NSManaged var optionDisplayName: String?
    @NSManaged var filterTabId: String?
    @NSManaged var filterId: String?
    @NSManaged var filterIcon: String?
}
