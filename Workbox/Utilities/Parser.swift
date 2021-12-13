//
//  Parser.swift
//  Workbox
//
//  Created by Ratan D K on 08/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class Parser {
    
    class func stringForData(data: AnyObject?) -> String? {
        if data is String {
            return data as? String
        }
        else {
            return nil
        }
    }
    
    class func actionsFromStringArray(stringArray : [String]?) -> [CardAction]? {
        if let stringArrayValue = stringArray{
            return  stringArrayValue.flatMap { CardAction(value: $0) }
        }
        else{
            return nil
        }
    }
    
    class func commentsFromDictionaryArray(dictionaryArray : [NSDictionary]?) -> [Comment]? {
        guard let unwrappedDictionaryArray = dictionaryArray else{
            return nil
        }
        return  unwrappedDictionaryArray.flatMap { Comment(dictionaryData: $0) }
    }
    
    class func daysFromDictionaryArray(dictionaryArray : [NSDictionary]?) -> [Day]? {
        guard let unwrappedDictionaryArray = dictionaryArray else{
            return nil
        }
        return  unwrappedDictionaryArray.flatMap { Day(dictionaryData: $0) }
    }
    
    /// It will also filter out deleted comments
    class func commentsFromAnyObject(jsonData : AnyObject?) -> [Comment]? {
        
        if let unwrappedData = jsonData as? NSDictionary {
            return [Comment(dictionaryData: unwrappedData)].filter{ $0.isDeleted == false}
        }
        else if let unwrappedData = jsonData as? [NSDictionary] {
            
            let comments =  unwrappedData.flatMap { Comment(dictionaryData: $0) }
            return comments.filter{ $0.isDeleted == false }
        }
        else{
            return nil
        }
    }
    
    
    
    class func attachmentsFromDictionaryArray(dictionaryArray : [NSDictionary]?) -> [Attachment]? {
        guard let unwrappedDictionaryArray = dictionaryArray else{
            return nil
        }
        return  unwrappedDictionaryArray.flatMap { Attachment(dictionaryData: $0) }
    }
    
    
    
    class func usersFromDictionaryArray(dictionaryArray : [NSDictionary]?) -> [User]? {
        if let dictionaryArrayValue = dictionaryArray{
            return  dictionaryArrayValue.flatMap { User(dictionaryData: $0) }
        }
        else{
            return nil
        }
    }
    class func userExperienceFromDictionaryArray(dictionaryArray : [NSDictionary]?) -> [UserExperience]? {
        if let dictionaryArrayValue = dictionaryArray{
            return  dictionaryArrayValue.flatMap { UserExperience(dictionaryData: $0) }
        }
        else{
            return nil
        }
    }
    class func userCertificationFromDictionaryArray(dictionaryArray : [NSDictionary]?) -> [UserCertification]? {
        if let dictionaryArrayValue = dictionaryArray{
            return  dictionaryArrayValue.flatMap { UserCertification(dictionaryData: $0) }
        }
        else{
            return nil
        }
    }
    
    class func dictionaryFromData(binaryData : NSData?) -> NSDictionary {
        
        guard let unwrappedData = binaryData else{
            print("binaryData is NILL")
            return NSDictionary()
        }
        return NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedData) as! NSDictionary
    }
    
    class func urlFromString(url : String?) -> String? {
        if let urlValue = url{
            return "\(ConstantServer.cdnURL)\(urlValue)"
        }
        else{
            return nil
        }
    }
    
    class func mediaUrlFromDictionaryArray(dictionaryData : [NSDictionary]?) -> String? {
        guard let dictionaryDataValue = dictionaryData, let url =  dictionaryDataValue.first?.valueForKey("preview") as? String else{
            return nil
        }
        return "\(ConstantServer.cdnURL)\(url)"
        
    }
    
    class func mediaTitleFromDictionaryArray(dictionaryData : [NSDictionary]?) -> String? {
        if let dictionaryDataValue = dictionaryData {
            return dictionaryDataValue.first?.valueForKey("mediaTitle") as? String
            
        }
        else{
            return nil
        }
    }
    
    
    //MARK: CORE DATA
    class func newObjectForPredicate(predicate: NSPredicate, entityName: String) -> AnyObject {
        
        let fetchRequest = NSFetchRequest(entityName:entityName)
        fetchRequest.predicate = predicate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var result: NSArray?
        do {
            result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        // Delete object if already exists and create a new one
        if result?.count > 0 {
            let object: NSManagedObject = result?.firstObject as! NSManagedObject
            appDelegate.managedObjectContext.deleteObject(object)
        }
        
        return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: appDelegate.managedObjectContext)
    }
    
    class func coreDataObjectForPredicate(predicate: NSPredicate, entityName: String) -> AnyObject {
        
        let fetchRequest = NSFetchRequest(entityName:entityName)
        fetchRequest.predicate = predicate
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var result: NSArray?
        
        do {
            result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        // Return that eobject if already exists or create a new one
        if result?.count > 0 {
            let object: NSManagedObject = result?.firstObject as! NSManagedObject
            return object
            //            appDelegate.managedObjectContext.deleteObject(object)
        }else{
            return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: appDelegate.managedObjectContext)
        }
    }
    
    class func fetchFilterOptions(entityName : String, forTabId: String) -> [Filter]? {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate(format: "filterTabId = %@", argumentArray: [forTabId])
        fetchRequest.predicate = predicate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var result: NSArray?
        do {
            result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
            
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        //
        guard let unwrappedResult = result where unwrappedResult.count > 0  else{
            print("filterArray is empty")
            return nil
        }
        var filterArray = [Filter]()
        filterArray = unwrappedResult.flatMap{$0 as? Filter}
        
        return filterArray
    }
    
    //    class func fetchCardConfig() {
    //        let fetchRequest = NSFetchRequest(entityName: String(CardConfig))
    //        //        let predicate = NSPredicate(format: "subType = %@", argumentArray: ["subType"])
    //        //        fetchRequest.predicate = predicate
    //        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    //
    //        var result: NSArray?
    //        do {
    //            result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
    //        } catch let error as NSError {
    //            print("Fetch failed: \(error.localizedDescription)")
    //        }
    //        guard let unwrappedResult = result where unwrappedResult.count > 0  else{
    //            print("filterArray is empty")
    //            return
    //        }
    //        var cardConfigArray = [CardConfig]()
    //        cardConfigArray =  unwrappedResult.flatMap{$0 as? CardConfig}
    //
    //        for cardConfigItem in cardConfigArray {
    //
    //            if let unwrappedSubtype = cardConfigItem.subType {
    //                let cardSubType = CardSubtype(value: unwrappedSubtype)
    //                if  let templateIdSring = cardConfigItem.templateId{
    //                    CardConfiguration.cardTemplate.setValue(templateIdSring, forKey: String(cardSubType))
    //                }
    //            }
    //        }
    //
    //    }
    
    class func fetchActions(forType forType : CardType, forSubtype : CardSubtype, forCardStatus : CardStatus) -> [CardAction]{
        let fetchRequest = NSFetchRequest(entityName: String(CardConfig))
        
        let predicateForType = NSPredicate(format: "type = %@", argumentArray: [forType.rawValue])
        let predicateForSubType = NSPredicate(format: "subType = %@", argumentArray: [forSubtype.rawValue])
        let compoundPredicate  = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [predicateForType,predicateForSubType])
        
        fetchRequest.predicate = compoundPredicate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var result: NSArray?
        do {
            result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        var actionsArray = [CardAction]()
        
        guard let unwrappedResult = result where unwrappedResult.count > 0  else{
            print("actionsArray is empty")
            return actionsArray
        }
        var cardConfigArray = [CardConfig]()
        cardConfigArray =  unwrappedResult.flatMap{$0 as? CardConfig}
        guard let unwrappedActionsData = cardConfigArray.first?.actions else{
            print("actionsArray is empty")
            return actionsArray
        }
        let objectArray = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedActionsData) as! NSArray
        
        
        
        actionsArray = objectArray.flatMap{ CardAction(value: $0 as? String) }
        
        for item in forCardStatus.disabledActions{
            actionsArray.removeObject(item)
        }
        
        return actionsArray
        
    }
    
    class func fetchOptionalFields(forType forType : CardType, forSubtype : CardSubtype) -> [String]{
        let fetchRequest = NSFetchRequest(entityName: String(CardConfig))
        
        let predicateForType = NSPredicate(format: "type = %@", argumentArray: [forType.rawValue])
        let predicateForSubType = NSPredicate(format: "subType = %@", argumentArray: [forSubtype.rawValue])
        let compoundPredicate  = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [predicateForType,predicateForSubType])
        
        fetchRequest.predicate = compoundPredicate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var result: NSArray?
        do {
            result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        var optionalFieldsArray = [String]()
        
        guard let unwrappedResult = result where unwrappedResult.count > 0  else{
            print("fetchOptionalFields unwrappedResult is empty" + String(forType) + String(forSubtype))
            return optionalFieldsArray
        }
        var cardConfigArray = [CardConfig]()
        cardConfigArray =  unwrappedResult.flatMap{$0 as? CardConfig}
        guard let unwrappedFieldsData = cardConfigArray.first?.fields else{
            print(" fetchOptionalFields unwrappedFieldsData is empty")
            return optionalFieldsArray
        }
        let objectDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedFieldsData) as! NSDictionary
        let objectArray = objectDictionary.valueForKey("optional") as! NSArray
        
        optionalFieldsArray = objectArray.flatMap{ ($0 as? String) }
        
        return optionalFieldsArray
    }
    
    class func fetchEnabledFields(forType forType : CardType, forSubtype : CardSubtype) -> [String]{
        let fetchRequest = NSFetchRequest(entityName: String(CardConfig))
        
        let predicateForType = NSPredicate(format: "type = %@", argumentArray: [forType.rawValue])
        let predicateForSubType = NSPredicate(format: "subType = %@", argumentArray: [forSubtype.rawValue])
        let compoundPredicate  = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [predicateForType,predicateForSubType])
        
        fetchRequest.predicate = compoundPredicate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var result: NSArray?
        do {
            result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        var optionalFieldsArray = [String]()
        
        guard let unwrappedResult = result where unwrappedResult.count > 0  else{
            print("fetchOptionalFields unwrappedResult is empty" + String(forType) + String(forSubtype))
            return optionalFieldsArray
        }
        var cardConfigArray = [CardConfig]()
        cardConfigArray =  unwrappedResult.flatMap{$0 as? CardConfig}
        guard let unwrappedFieldsData = cardConfigArray.first?.fields else{
            print(" fetchOptionalFields unwrappedFieldsData is empty")
            return optionalFieldsArray
        }
        let objectDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedFieldsData) as! NSDictionary
        let objectArrayOfOptionalFields = objectDictionary.valueForKey("optional") as! NSArray
        let objectArrayOfMandatoryFields = objectDictionary.valueForKey("mandatory") as! NSArray
        
        
        
        
        let optionalFields = objectArrayOfOptionalFields.flatMap{ ($0 as? String) }
        let mandatoryFields = objectArrayOfMandatoryFields.flatMap{ ($0 as? String) }
        
        optionalFieldsArray.appendContentsOf(optionalFields)
        optionalFieldsArray.appendContentsOf(mandatoryFields)
        
        return optionalFieldsArray
    }
    
    
    class func fetchCardTemplate(forType forType : CardType, forSubtype : CardSubtype) -> String?{
        let fetchRequest = NSFetchRequest(entityName: String(CardConfig))
        
        let predicateForType = NSPredicate(format: "type = %@", argumentArray: [forType.rawValue])
        let predicateForSubType = NSPredicate(format: "subType = %@", argumentArray: [forSubtype.rawValue])
        let compoundPredicate  = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [predicateForType,predicateForSubType])
        
        fetchRequest.predicate = compoundPredicate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var result: NSArray?
        do {
            result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        //        let cardTemplateString : String?
        
        
        
        guard let unwrappedResult = result where unwrappedResult.count > 0  else{
            print("fetchCardTemplate optionalFieldsArray is empty" + String(forType) + String(forSubtype))
            return nil
        }
        var cardConfigArray = [CardConfig]()
        cardConfigArray =  unwrappedResult.flatMap{$0 as? CardConfig}
        
        guard let unwrappedTemplateID = cardConfigArray.first?.templateId else{
            print("templateId is empty")
            return nil
        }
//        let unwrappedTemplateID = "appraisalTemplate"
        return unwrappedTemplateID
    }
    
    
    class func fetchWorkitem(forId forId : String) -> Workitem?{
        let fetchRequest = NSFetchRequest(entityName: String(Workitem))
        
        let predicateForId = NSPredicate(format: "workitemId = %@", argumentArray: [forId])
        
        fetchRequest.predicate = predicateForId
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var result: NSArray?
        do {
            result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        guard let unwrappedResult = result where unwrappedResult.count > 0  else{
            print("workitemArray is empty")
            return nil
        }
        guard let unwrappedWorkitemData = unwrappedResult.firstObject as? Workitem else{
            print("unwrappedworkitem is empty")
            return nil
        }
        
        //        let objectDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedWorkitemData) as! NSDictionary
        return unwrappedWorkitemData
        
    }
    
    class func fetchAllWorkitems() -> [Workitem]{
        let fetchRequest = NSFetchRequest(entityName: String(Workitem))
        var workitemArray = [Workitem]()
        
        //        let predicateForId = NSPredicate(format: "workitemId = %@", argumentArray: [forId])
        
        //        fetchRequest.predicate = predicateForId
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var result: NSArray?
        do {
            result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        guard let unwrappedResult = result where unwrappedResult.count > 0  else{
            print("unwrappedResult is empty")
            return workitemArray
        }
        
        for workitem in unwrappedResult{
            if let workitemElement = workitem as? Workitem{
                workitemArray.append(workitemElement)
            }
            
        }
        
        return workitemArray
    }
    
    
    class func isElementEnabled(forType forType : CardType, forSubtype : CardSubtype, optionalFieldString : String) -> Bool{
        let optionalFields =   Parser.fetchOptionalFields(forType: forType, forSubtype: forSubtype)
        return optionalFields.contains(optionalFieldString)
    }
    
    
    class func subMenuForDictionary(dict: NSDictionary) -> SubMenu? {
        
        guard let id = dict["id"] else {
            return nil
        }
        
        let predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        let newObject = newObjectForPredicate(predicate, entityName: String(SubMenu)) as! SubMenu
        newObject.id = id as? String
        newObject.displayName = dict["displayName"] as? String
        newObject.imageName = dict["icon"] as? String
        
        return newObject
    }
    
    class func menuForDictionary(dict: NSDictionary) -> Menu? {
        
        guard let id = dict["id"] else {
            return nil
        }
        
        let predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        let newObject = newObjectForPredicate(predicate, entityName: String(Menu)) as! Menu
        newObject.id = id as? String
        newObject.tabId = dict["tab_id"] as? String
        newObject.displayName = dict["displayName"] as? String
        newObject.imageName = dict["icon"] as? String
        if let options = dict["options"] as? NSArray {
            let subMenus = NSMutableOrderedSet()
            for optionDict in options as! [NSDictionary] {
                if let subMenu = subMenuForDictionary(optionDict) {
                    subMenu.menu = newObject
                    subMenus.addObject(subMenu)
                }
            }
            newObject.subMenus = subMenus
        }
        
        return newObject
    }
    
    class func workitemForDictionary(dict: NSDictionary) -> Workitem? {
        
        guard let id = dict["_id"] else {
            return nil
        }
        
        let predicate = NSPredicate(format: "workitemId = %@", argumentArray: [id])
        let newObject = coreDataObjectForPredicate(predicate, entityName: String(Workitem)) as! Workitem
        
        
        newObject.workitemId = id as? String
        newObject.workitemData = NSKeyedArchiver.archivedDataWithRootObject(dict)
        newObject.cardType = dict.valueForKeyPath("card.type") as? String
        newObject.cardSubtype  = dict.valueForKeyPath("card.subtype") as? String
        newObject.updatedAt = dict.valueForKeyPath("updatedAt") as? String
        return newObject
        
    }
    
    ///Using Core Data as just a database for actions, because we have a saperate model called ActionProperty for actions(Defined in Action Controller)
    
    class func SetOfflineAction(actionProperty: ActionProperty) {
        
        guard let id = actionProperty.workitemId else {
            return
        }
        
        let entityName = String(OfflineAction)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Create object even if already exists
        let  newObject =  NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: appDelegate.managedObjectContext) as! OfflineAction
        
        newObject.workitemId = id
        newObject.actionProperty = NSKeyedArchiver.archivedDataWithRootObject(actionProperty)
        
        
        do {
            try appDelegate.managedObjectContext.save()
        } catch let error {
            print("Coredata error: \(error)")
        }
        
        
    }
    
    
    class func GetOfflineActions(forWorkitemId: String?) -> [OfflineAction] {
        
        let entityName = String(OfflineAction)

        let fetchRequest = NSFetchRequest(entityName: entityName)

        if let unwrappedWorkitemId = forWorkitemId {
            let predicate = NSPredicate(format: "workitemId = %@", argumentArray: [unwrappedWorkitemId])
            fetchRequest.predicate = predicate
        }
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var actionPropertyArray = [OfflineAction]()
        
        var result: NSArray?
        do {
            result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        guard let unwrappedResult = result where unwrappedResult.count > 0  else{
            print("unwrappedResult is empty")
            return actionPropertyArray
        }
        
        actionPropertyArray = unwrappedResult as! [OfflineAction]

        return actionPropertyArray
        
    }
    
    
    class func deleteOfflineAction(object : OfflineAction){
        let fetchRequest = NSFetchRequest(entityName : String(OfflineAction))
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var result: NSArray?
        do {
            result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        // Delete object if already exists and create a new one
        if result?.count > 0 {
            appDelegate.managedObjectContext.deleteObject(object)
        }
    }
    
    
    
    class func cherryForDictionary(str : String?) -> Cherry? {
        
        guard let name = str else {
            return nil
        }
        
        let predicate = NSPredicate(format: "cherryName = %@", argumentArray: [name])
        let newObject = newObjectForPredicate(predicate, entityName: String(Cherry)) as! Cherry
        newObject.cherryName = name
        
        
        return newObject
        
    }
    
    class func TabForDictionary(dict: NSDictionary) -> Tab? {
        
        guard let id = dict["id"] else {
            return nil
        }
        
        let predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        let newObject = newObjectForPredicate(predicate, entityName: String(Tab)) as! Tab
        newObject.id = id as? String
        if let isDefaultObject = dict["default"] {
            let isDefaultString = isDefaultObject as! NSNumber
            newObject.isDefault = NSNumber(bool: isDefaultString.boolValue)
        }
        
        return newObject
    }
    
    
    class func CardConfigForDictionary(dict: NSDictionary) -> CardConfig? {
        
        guard let subType = dict["subtype"], templateId = dict["templateId"], type = dict["type"] else {
            return nil
        }
        
        let predicate = NSPredicate(format: "templateId = %@", argumentArray: [templateId])
        let newObject = newObjectForPredicate(predicate, entityName: String(CardConfig)) as! CardConfig
        newObject.type = type as? String
        newObject.subType = subType as? String
        newObject.templateId = templateId as? String
        if let actions = dict["actions"] {
            newObject.actions = NSKeyedArchiver.archivedDataWithRootObject(actions)
        }
        if let fields = dict["fields"] {
            newObject.fields = NSKeyedArchiver.archivedDataWithRootObject(fields)
        }
        
        return newObject
    }
    
    class func filtersForDictionaryArray(dictArray: [NSDictionary]) -> [Filter]? {
        var filterArray = [Filter]()
        for filter in dictArray{
            guard let filterTabId = filter["tab_id"] as? String else   {
                print("Error: filterTabId")
                return nil
            }
            
            guard let options = filter.valueForKey("options") as? [NSDictionary] else{
                print("Error: options")
                
                return nil
            }
            for optionItem in options{
                guard let optionId = optionItem["id"] as? String else   {
                    print("Error: optionItem")
                    return nil
                }
                let predicate = NSPredicate(format: "optionId = %@", argumentArray: [optionId])
                guard let newObject = newObjectForPredicate(predicate, entityName: String(Filter)) as? Filter else {
                    print("Error: newObject")
                    return nil
                }
                newObject.filterTabId = filterTabId
                newObject.filterId = filter["id"] as? String
                newObject.filterIcon = filter["icon"] as? String
                newObject.optionId = optionItem["id"] as? String
                newObject.optionDisplayName = optionItem["displayName"] as? String
                newObject.optionIconName = optionItem["icon"] as? String
                filterArray.append(newObject)
            }
        }
        return filterArray
    }
    
    class func permissionForDict(dict: NSDictionary) -> Permission? {
        guard let keys = dict.allKeys as NSArray? where keys.count > 0,
            let moduleName = keys.firstObject as? String,
            let permissionDict = dict[moduleName] as? NSDictionary else {
            return nil
        }
        
        let predicate = NSPredicate(format: "moduleName = %@", argumentArray: [moduleName])
        let newObject = newObjectForPredicate(predicate, entityName: String(Permission)) as! Permission
        
        newObject.moduleName = stringForData(moduleName)
        newObject.create = stringForData(permissionDict["create"])
        newObject.read = stringForData(permissionDict["read"])
        newObject.update = stringForData(permissionDict["update"])
        newObject.delete = stringForData(permissionDict["delete"])
        
        return newObject
    }
    
    
    //MARK:
    
    class func groupForDict(dict:NSDictionary?) -> Group? {
        guard let data = dict as NSDictionary!, groupId = data["_id"] as! String?, groupName = data["name"] as! String? else {
            return nil
        }
        
        let newGroup = Group()
        newGroup.name = stringForData(groupName)
        newGroup.type = stringForData(data["type"])
        newGroup.groupId = stringForData(groupId)
        newGroup.imageName = stringForData(data["icon"])
        
        if let usersArray = data["users"] as? NSArray {
            var members = [User]()
            for userDict in usersArray as! [NSDictionary] {
                let user = User.init(dictionaryData: userDict) as User!
                members.append(user)
            }
            newGroup.members = members
        }
        
        return newGroup
    }
    
    
    class func weekFromToDict (dict :NSDictionary?) -> TSWeekFromTo? {
        guard let data = dict as NSDictionary!, startDate = data["startDate"] as! String?, endDate = data["endDate"] as! String? else {
            return nil
        }
        let newWeekFromTo = TSWeekFromTo()
        newWeekFromTo.startDate = Helper.dateForDDMMYYYYString(startDate)
        newWeekFromTo.endDate = Helper.dateForDDMMYYYYString(endDate)
        
        return newWeekFromTo
        
    }
    
    class func taskFormDict(dict:NSDictionary?)->TSTask?{
        guard let data = dict as NSDictionary! else {
            return nil
        }
        guard let taskDict = data["task"] as? NSDictionary! else{
            return nil
        }
        let task = TSTask()
        
        if let taskId = taskDict["_id"] as! String?{
            task.id = taskId
        }
        
        if let taskName = taskDict["name"] as! String? {
            task.name = taskName
        }
        
        let sumittedHrs = data["submittedHours"] as? Int ?? 0
        let submittedHoursInFloat = Float(sumittedHrs)
        let submittedHoursInMinutes = submittedHoursInFloat * 60
        task.submittedHours = String(submittedHoursInMinutes)
        return task
    }
    
    class func projectFormDict(dict:NSDictionary?)->TSProject?{
        guard let data = dict as NSDictionary! else{
            return nil
        }
        guard let projectDict = data["project"] as! NSDictionary?,
            projectName = projectDict["name"] as! String? else {
                return nil
        }
        
        let project = TSProject()
        if let projectId = projectDict["_id"]{
            project.id = stringForData(projectId)
        }
        
        project.name = projectName
        
        project.status = TSStatus(value: stringForData(data["status"]))
        
        let sumittedHrs = data["submittedHours"] as? Int ?? 0
        let submittedHoursInFloat = Float(sumittedHrs)
        let submittedHoursInMinutes = submittedHoursInFloat * 60
        project.submittedHours = String(submittedHoursInMinutes)
        
        // not present for saveTS
        let allocatedHrs = data["allocatedHours"] as? Int ?? 0
        let allocatedHoursInFloat = Float(allocatedHrs)
        let allocatedHoursInMinutes = allocatedHoursInFloat * 60
        project.allocatedHours = String(allocatedHoursInMinutes)
        
        if let tasksDic = data["tasks"] as? NSArray{
            var tasksArray = [TSTask]()
            
            for task in tasksDic as! [NSDictionary] {
                if let task = taskFormDict(task) {
                    tasksArray.append(task)
                }
            }
            project.tasks = tasksArray
            
        }
        return project
    }
    
    class func timesheetFormDict(dict:NSDictionary?)->Timesheet?{
        guard let data = dict as NSDictionary! else{
            return nil
        }
        guard let timesheetDate = data["date"] as! String? else {
            return nil
        }
        let timesheet = Timesheet()
        timesheet.date = Helper.dateForDDMMYYYYString(timesheetDate)
        
        let sumittedHrs = data["submittedHours"] as? Int ?? 0
        let submittedHoursInFloat = Float(sumittedHrs)
        let submittedHoursInMinutes = submittedHoursInFloat * 60
        timesheet.submittedHours = String(submittedHoursInMinutes)
        // not present for saved TS
        let allocatedHrs = data["allocatedHours"] as? Int ?? 0
        let allocatedHoursInFloat = Float(allocatedHrs)
        let allocatedHoursInMinutes = allocatedHoursInFloat * 60
        timesheet.allocatedHours = String(allocatedHoursInMinutes)
        
        
        
        if let workingDayStatusDict = data["workingDayStatus"] as! NSDictionary? {
            if let isWorkingDay = (workingDayStatusDict["isWorkingDay"]) as! Bool?{
                timesheet.isWorkingDay = isWorkingDay
            }
            timesheet.nonWorkingDayType = stringForData( workingDayStatusDict["nonWorkingDayType"])
        }
        
        timesheet.status = TSStatus(value: stringForData(data["status"]))
        
        if let projectsDic = data["projects"] as? NSArray{
            var projectArray = [TSProject]()
            
            for project in projectsDic as! [NSDictionary] {
                if let project = projectFormDict(project) {
                    projectArray.append(project)
                }
            }
            timesheet.projects = projectArray
            
        }
        return timesheet
    }
    
    class func timesheetWeekFromDict(dict:NSDictionary?)->TimesheetWeek?{
        guard let data = dict as NSDictionary! else{
            return nil
        }
        
        let timesheetWeek = TimesheetWeek()
        
        if let id = data["_id"]{
            timesheetWeek.id = stringForData(id)
        }
        
        timesheetWeek.startDate = Helper.dateForDDMMYYYYString(stringForData(data["startDate"]))
        timesheetWeek.endDate = Helper.dateForDDMMYYYYString(stringForData(data["endDate"]))
        timesheetWeek.createdAt = Helper.dateForString(stringForData(data["createdAt"]))
        timesheetWeek.updatedAt = Helper.dateForString(stringForData(data["updatedAt"]))
        
        let sumittedHrs = data["submittedHours"] as? Int ?? 0
        let submittedHoursInFloat = Float(sumittedHrs)
        let submittedHoursInMinutes = submittedHoursInFloat * 60
        timesheetWeek.submittedHours = String(submittedHoursInMinutes)
        
        let allocatedHrs = data["allocatedHours"] as? Int ?? 0
        let allocatedHoursInFloat = Float(allocatedHrs)
        let allocatedHoursInMinutes = allocatedHoursInFloat * 60
        timesheetWeek.allocatedHours = String(allocatedHoursInMinutes)
        
        if let userDict = data["user"] as! NSDictionary?{
            timesheetWeek.submittedBy = User(dictionaryData:userDict)
        }
        
        timesheetWeek.status = TSStatus(value: stringForData(data["overallStatus"]))
        
        if let timesheetDictArray = data["days"] as? NSArray{
            var timesheetArray = [Timesheet]()
            for timesheet in timesheetDictArray as! [NSDictionary] {
                if let timesheet = timesheetFormDict(timesheet) {
                    timesheetArray.append(timesheet)
                }
            }
            timesheetWeek.timesheets = timesheetArray
            
        }
        
        return timesheetWeek
    }
    
    // tasks API
    class func TSTaskFromDict(dict :NSDictionary?)->TSTask?{
        guard let data = dict as NSDictionary!,id = data["_id"],taskName = stringForData(data["name"]), type = stringForData(data["type"]) else{
            return nil
        }
        let task = TSTask()
        
        task.id = stringForData(id)
        task.name = taskName
        task.type = stringForData(type)
        
        if let milestone = data["milestone"] as? String!{
            task.milestone  = milestone
        }
        
        if let projectDict = data["project"] as! NSDictionary?{
            if let projectId = projectDict["_id"],projectName = projectDict["name"]{
                let project = TSProject()
                project.name = stringForData(projectName)
                project.id = stringForData( projectId)
                task.project = project
            }
        }
        
        return task
    }
    
    class func TSApprovalProjectFromDict(dict:NSDictionary?)->TSProject?{
        guard let data = dict as NSDictionary!,type = data["type"] as? String,id = data["_id"] as? String,name = data["name"] as? String else{
            return nil
        }
        let project = TSProject()
        project.id = id
        project.type = type
        project.name = name
        return project
    }
    
    class func notificationFetch(dict: NSDictionary?)->Notification?{
        guard let data = dict as NSDictionary! else {
            return nil
        }
        
        let notification = Notification()
        
        if let id = data["_id"] as? String {
            
            notification.id = stringForData(id)
        }
        
        if let workItemId = data["workitemId"] as? String {
            notification.workItemId = stringForData(workItemId)
            
        }
        
        if let message = data["message"] as? String, applicationType = data["applicationType"] as? String {
            notification.applicationType = applicationType
            notification.message = message
            
        }
        print(data["applicationType"])
        if  data["applicationType"]! as! String == "Info Process"{
        print(notification.message)
        }
        
        notification.startDate = Helper.dateForDDMMYYYYString(stringForData(data["startDate"]))
        notification.endDate = Helper.dateForDDMMYYYYString(stringForData(data["endDate"]))
        
        
        if let senderDict = data["sender"] as? NSDictionary?{
            notification.sender = User(dictionaryData: senderDict)
            
        }
        
        
       // if data["receiver"] != nil{
            if let receiverDict = data["receiver"] as? NSDictionary? {
                notification.receiver = User(dictionaryData: receiverDict)
            }
       // }
        
        if let read = data["read"] as? Bool {
            notification.read = read
        }
        
        notification.createdAt = Helper.dateForString(stringForData(data["createdAt"]))
        notification.updatedAt = Helper.dateForString(stringForData(data["updateAt"]))
        
        if let updatedBy = data["updatedBy"] as! NSDictionary?{
            notification.updatedBy = User(dictionaryData: updatedBy)
        }
        
        if let contentDict = data["content"] as! NSDictionary? {
            
            notification.content = contentDict
        }
        
        
        return notification
        
    }
    
    class func teamCalendar(dict: NSDictionary?) -> Calendar? {
        
        guard let data = dict as NSDictionary! else {
            return nil
        }
        
        let teamCalendar = Calendar()
        
        if let user = data["user"] as! NSDictionary? {
            
            teamCalendar.user = User(dictionaryData: user)
        }
        teamCalendar.status = LeaveStatus(value: stringForData(data["status"]))
        
        if let fromDate = data["from"] as? String, toDate = data["to"] as? String {
            
            teamCalendar.fromDate = Helper.dateForString(fromDate)
            teamCalendar.toDate = Helper.dateForString(toDate)
        }
        
        if let sessionOne = data["fromSession"] as? Int {
            
            teamCalendar.fromSession = sessionOne
        }
        
        if let sessionTwo = data["toSession"] as? Int {
            
            teamCalendar.toSession = sessionTwo
            
        }
        return teamCalendar
    }
    
    class func subscriptionParsed(dict : NSDictionary?) -> Subscription?{
        
        guard let  data = dict as NSDictionary! else {
            return nil
        }
        
        let subscription = Subscription()
        
        if let subscribed = data["subscribed"] as? Bool {
            subscription.subscribed = subscribed
            
        }
        
        if let mandatory = data["mandatory"] as? Bool {
            
            subscription.mandatory = mandatory
        }
        
        if let subtype = data["subtype"] as? String, let type = data["type"] as? String {
            subscription.subtype = subtype
            subscription.type = type
        }
        
        return subscription
        
        
    }
    
    class func activityLogParsed(dict : NSDictionary?) -> ActivityLog? {
        
        
        guard let data = dict as NSDictionary! else {
            return nil
        }
        
        let activityLog = ActivityLog()
        
        if let id = data["_id"] as? String {
            activityLog._id = id
        }
        if let userId = data["userId"] as? String {
          activityLog.user_id = userId
        
        }
        if let type = data["type"] as? String {
            activityLog.type = type
        }
        if let contentDict = data["content"] as? [NSDictionary] {
            
            activityLog.content = contentDict
        }
        if let message = data["activity"] as? String {
            activityLog.activity = message
        }
        if let timeUpdated = data["time"] as? String {
            activityLog.time = Helper.dateForString(timeUpdated)
        }
        if let action = data["action"] as? String{
            activityLog.action = action
        }
        
        
        return activityLog
    }
    
    class func bmpTaskDetail(dict : NSDictionary) -> BPMTaskDetail?{
        guard let id = dict["_id"] as? String else{
            return nil
        }
        
        let bpmTaskDetailObject = BPMTaskDetail()
        
        
        guard let content = dict["content"] as? NSMutableDictionary, contentDict = content["d"] as? NSMutableDictionary else{
            return nil
            
        }
        
        bpmTaskDetailObject.id = id
        bpmTaskDetailObject.edmKey = contentDict["EDM_Key"] as? String
        
        bpmTaskDetailObject.requestId = contentDict["requestId"] as? String
        bpmTaskDetailObject.requester = contentDict["requester"] as? String
        bpmTaskDetailObject.vendor = contentDict["vendor"] as? String
        bpmTaskDetailObject.companyCode = contentDict["companyCode"] as? String
        bpmTaskDetailObject.purchaseOrg = contentDict["purchaseOrg"] as? String
        bpmTaskDetailObject.purchaseGroup = contentDict["purchaseGroup"] as? String
        bpmTaskDetailObject.documentType = contentDict["documentType"] as? String
        bpmTaskDetailObject.currency = contentDict["currency"] as? String
        bpmTaskDetailObject.createDate = Helper.dateForString(stringForData(contentDict["createDate"]))
        bpmTaskDetailObject.mode = contentDict["mode"] as? String
        let type  = contentDict.valueForKeyPath("__metadata.type") as? String
        bpmTaskDetailObject.type = self.secondWord(type)
        if let userDict = contentDict["approvedBy"] as? NSDictionary{
            bpmTaskDetailObject.approvedBy = User(dictionaryData:userDict)
        }
        
       
        
        let copy = contentDict.mutableCopy()
            copy.removeObjectsForKeys(["__metadata","approvedBy","approvedOn","approved","reviewed","userUniqueId","items","fileUpload","EDM_Key"])
       
//        copy.enumerateKeysAndObjectsUsingBlock({
//            (key, value, pointer) in
//            key.capitalizedString
//        })
        
        bpmTaskDetailObject.ContentData = copy as! NSMutableDictionary
        
      
        
        

        
        return bpmTaskDetailObject
    }
    
    class func secondWord(value: String?) -> String? {
        // Find index of space.
        if let unwrappedValue = value{
            var start = unwrappedValue.endIndex
            for var i = unwrappedValue.startIndex;
                i < unwrappedValue.endIndex;
                i = i.successor() {
                    // If character is a space, the second word starts at the next index.
                    if unwrappedValue[i] == "." {
                        // First char of second word is next index.
                        start = i.successor()
                        break
                    }
            }
            
            // Return substring.
            return unwrappedValue[start..<unwrappedValue.endIndex]
        }
        else{
            return "Approval Task"
        }
    }
}
