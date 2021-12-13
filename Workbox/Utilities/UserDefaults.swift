//
//  UserDefaults.swift
//  Workbox
//
//  Created by Ratan D K on 07/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire

private let kIsConfigured = "kIsConfigured"
private let kIsConfigurationDownloaded = "kIsConfigurationDownloaded"
private let kAccessToken = "kAccessToken"
private let kUserRole = "kUserRole"
private let kDeviceId = "kDeviceId"
private let kDeviceToken = "kDeviceToken"
private let kUser = "kUser"
private let kUserId = "kUserId"
private let kEmail = "kEmail"
private let kDisplayName = "kDisplayName"
private let kCompanyLogoName = "kCompanyLogoName"
private let kTouchId = "kTouchId"
private let kConfigVersion = "kConfigVersion"
private let kBadgeCount = "kBadgeCount"
private let kUserRegion = "kUserRegion"

class UserDefaults {
    
    static let sharedInstance = NSUserDefaults.standardUserDefaults()
    
    class func isConfigured() -> Bool {
        if let isConfiguredNum = sharedInstance.valueForKey(kIsConfigured) {
            return isConfiguredNum.boolValue
        }
        return false
    }
    
    class func setIsConfigured(isConfigured: Bool) {
        sharedInstance.setValue(NSNumber.init(bool: isConfigured), forKey: kIsConfigured)
        sharedInstance.synchronize()
    }
    
    class func isConfigurationDownloaded() -> Bool {
        if let isConfiguredNum = sharedInstance.valueForKey(kIsConfigurationDownloaded) {
            return isConfiguredNum.boolValue
        }
        return false
    }
    
    class func setIsConfigurationDownloaded(isConfigured: Bool) {
        sharedInstance.setValue(NSNumber.init(bool: isConfigured), forKey: kIsConfigurationDownloaded)
        sharedInstance.synchronize()
    }
    
    class func deviceId() -> String? {
        return sharedInstance.valueForKey(kDeviceId) as? String
    }
    
    class func setDeviceId(deviceId: String?) {
        sharedInstance.setValue(deviceId, forKey: kDeviceId)
        sharedInstance.synchronize()
    }
    
    class func accessToken() -> String? {
        return sharedInstance.valueForKey(kAccessToken) as? String
    }
    
    class func setAccessToken(token: String?) {
        sharedInstance.setValue(token, forKey: kAccessToken)
        sharedInstance.synchronize()
    }
    
    class func userRole() -> Dictionary<String,[NSMutableDictionary]>{
        // return sharedInstance.valueForKey(kUserRole) as? NSDictionary
        //        let data = NSUserDefaults.standardUserDefaults().objectForKey(kUserRole) as! NSData
        //
        //
        //        let object = NSKeyedUnarchiver.unarchiveObjectWithData(data)
      //  let object = NSUserDefaults.standardUserDefaults().arrayForKey(kUserRole) as? Dictionary<String,[NSMutableDictionary]>
        
         let object = NSUserDefaults.standardUserDefaults().dictionaryForKey(kUserRole) as? Dictionary<String,[NSMutableDictionary]>
        var error : NSError?
        
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(object!, options: NSJSONWritingOptions.PrettyPrinted)
        
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
        
        print(jsonString)
        
        return object!
        
        
    }
    class func setId(id: String){
        sharedInstance.setValue(id, forKey: "id")
   
        sharedInstance.synchronize()
    
    }
    class func getId() -> String{
      return (sharedInstance.valueForKey("id") as? String)!
        
    }
    class func setManagerInfo(obj: NSDictionary){
        var managerinfoDict  = [String: String]()
        if let avatar = obj["_id"] as? String{
            managerinfoDict["_id"] = avatar as? String
        }else{
            managerinfoDict["_id"] = ""
        }
        if let avatar = obj["avatar"] as? String{
            managerinfoDict["avatar"] = avatar as? String
        }else{
            managerinfoDict["avatar"] = ""
        }
        if let avatar = obj["displayName"] as? String{
            managerinfoDict["displayName"] = avatar as? String
        }else{
            managerinfoDict["displayName"] = ""
        }

        if let avatar = obj["mobile"] as? String{
            managerinfoDict["mobile"] = avatar as? String
        }else{
            managerinfoDict["mobile"] = ""
        }

        if let avatar = obj["deleted"] as? String{
            managerinfoDict["deleted"] = avatar as? String
        }else{
            managerinfoDict["deleted"] = ""
        }

        if let avatar = obj["employeeNumber"] as? String{
            managerinfoDict["employeeNumber"] = avatar as? String
        }else{
            managerinfoDict["employeeNumber"] = ""
        }

        if let avatar = obj["email"] as? String{
            managerinfoDict["email"] = avatar as? String
        }else{
            managerinfoDict["email"] = ""
        }

        if let avatar = obj["designation"] as? String{
            managerinfoDict["designation"] = avatar as? String
        }else{
            managerinfoDict["designation"] = ""
        }

        
        
        sharedInstance.setValue(managerinfoDict, forKey: "ManagerInfo")
        sharedInstance.synchronize()
        
    }
    class func getManagerInfo() -> NSDictionary{
        return (sharedInstance.valueForKey("ManagerInfo") as? NSDictionary)!
        
    }
    class func setLeaveroles(roles: NSMutableDictionary){
        sharedInstance.setValue(roles, forKey: "leaveRoles")
        
        sharedInstance.synchronize()
        
    }
    class func getLeaveroles() -> NSMutableDictionary{
        return (sharedInstance.valueForKey("leaveRoles") as? NSMutableDictionary)!
        
    }

    class func setPosition(position: String){
        sharedInstance.setValue(position, forKey: "position")
        sharedInstance.synchronize()

    }
    class func getPosition() -> String {
         return (sharedInstance.valueForKey("position") as? String)!
    }
    class func setUserRole(userDict: NSMutableDictionary) {
        //        sharedInstance.setObject(NSKeyedArchiver.archivedDataWithRootObject(userDict), forKey: kUserRole)
        sharedInstance.setObject(userDict, forKey: kUserRole)
        sharedInstance.synchronize()
    }
    class func deviceToken() -> String? {
        return sharedInstance.valueForKey(kDeviceToken) as? String
    }
    
    class func setDeviceToken(token: String?) {
        sharedInstance.setValue(token, forKey: kDeviceToken)
        sharedInstance.synchronize()
    }
    
    class func userId() -> String? {
        return sharedInstance.valueForKey(kUserId) as? String
    }
    
    class func setUserId(userId: String?) {
        sharedInstance.setValue(userId, forKey: kUserId)
        sharedInstance.synchronize()
    }
    
    class func loggedInUser() -> User? {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(kUser) as! NSData
        let object = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSDictionary
        return User(dictionaryData: object)
    }
    
    class func setLoggedInUserDict(userDict: NSDictionary) {
        sharedInstance.setObject(NSKeyedArchiver.archivedDataWithRootObject(userDict), forKey: kUser)
        sharedInstance.synchronize()
    }
    
    class func companyLogoImageName() -> String? {
        return sharedInstance.valueForKey(kCompanyLogoName) as? String
    }
    
    class func setCompanyLogoImageName(imageName: String?) {
        sharedInstance.setValue(imageName, forKey: kCompanyLogoName)
        sharedInstance.synchronize()
    }
    
    class func isSetTouchId() -> Bool?{
        return sharedInstance.valueForKey(kTouchId) as? Bool
    }
    
    
    class func setTouchIdSettings(TouchId:Bool){
        sharedInstance.setBool(TouchId, forKey: kTouchId)
        sharedInstance.synchronize()
    }
    
    class func setConfigVersion(version: String?) {
        sharedInstance.setValue(version, forKey: kConfigVersion)
        sharedInstance.synchronize()
    }
    
    class func configVersion() -> String? {
        return sharedInstance.valueForKey(kConfigVersion) as? String
    }
    
    
    //    class func saveOfflineAction(actionProperty: ActionProperty) {
    //        let dict : NSMutableDictionary = [:]
    //
    //        if let actionType = actionProperty.actionType?.rawValue{
    //            dict.setValue(actionType, forKey: "actionType")
    //        }
    //        if let id = actionProperty.workitemId{
    //            dict.setValue(id, forKey: "workitemId")
    //        }
    //        if let senderVC = actionProperty.senderViewController{
    //            dict.setValue(senderVC, forKey: "senderViewController")
    //        }
    //        dict.setValue(actionProperty.likedBySelf, forKey: "likedBySelf")
    //
    //        if let text = actionProperty.text{
    //            dict.setValue(text, forKey: "text")
    //        }
    //        if let attachments = actionProperty.attachments{
    //            dict.setValue(attachments, forKey: "attachments")
    //        }
    //
    //        sharedInstance.setObject(NSKeyedArchiver.archivedDataWithRootObject(dict), forKey: "action")
    //        sharedInstance.synchronize()
    //    }
    
    
    //    class func OfflineAction() -> ActionProperty? {
    //        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("action") as? NSData else{
    //            return nil
    //        }
    //
    //        guard let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary else{
    //            return nil
    //        }
    //        let actProp = ActionProperty()
    //            actProp.actionType = CardAction(value: dict.valueForKey("actionType") as? String)
    //        actProp.workitemId = dict.valueForKey("workitemId") as? String
    //        return actProp
    //    }
    
    
    
    
    
    
    
    // MARK: temp
    
    class func loggedInEmail() -> String? {
        return sharedInstance.valueForKey(kEmail) as? String
    }
    
    class func setLoggedInEmail(email: String?) {
        sharedInstance.setValue(email, forKey: kEmail)
        sharedInstance.synchronize()
    }
    
    class func loggedInName() -> String? {
        return sharedInstance.valueForKey(kDisplayName) as? String
    }
    
    class func setLoggedInName(name: String?) {
        sharedInstance.setValue(name, forKey: kDisplayName)
        sharedInstance.synchronize()
    }
    
    
    class func setBadgeCount(value : Int?) {
        sharedInstance.setValue(value, forKey: kBadgeCount)
        sharedInstance.synchronize()
    }
    
    class func badgeCount() -> Int? {
        return sharedInstance.valueForKey(kBadgeCount) as? Int
    }
    
    
    class func setUserRegion(value : String?) {
        sharedInstance.setValue(value, forKey: kUserRegion)
        sharedInstance.synchronize()
    }
    
    class func userRegion() -> String? {
        return sharedInstance.valueForKey(kUserRegion) as? String
    }
}
