//
//  User.swift
//  Workbox
//
//  Created by Ratan D K on 07/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import Foundation

class User : NSObject{
    
    var username : String?
    var id : String?
    var employeeId : String?
    var designation : String?
    var firstName : String?
    var lastName : String?
    var displayName : String?
    var email : String?
    var phoneNo : String?
//    var avatarURL : NSURL?
    var avatarURLString: String?
    var location : String?
    var maritalStatus: String?
    var experiences : [UserExperience]?
    var certifications : [UserCertification]?
    var manutalTaskStatus : CardStatus = CardStatus.Open
    var officialInformation : NSDictionary?
    var role : String?
    var hrFunction : String?
    
   override init(){
    }
    
    convenience init?(dictionaryData : NSDictionary?) {
        guard let data = dictionaryData else{
            return nil
        }
        self.init(JSON: data)
    }
    
    
    init(JSON: AnyObject) {
        id = JSON.valueForKey("_id") as? String
        avatarURLString = JSON.valueForKey("avatar") as? String
        firstName = JSON.valueForKey("firstName") as? String
        lastName  = JSON.valueForKey("lastName") as? String
        let fullName = (JSON.valueForKey("displayName") as? String)
        if let unwrappedDisplayName = fullName{
            displayName = unwrappedDisplayName.capitalizedString
        }
        else{
            displayName = "\(firstName ?? "") \(lastName ?? "")".capitalizedString
        }
        email = JSON.valueForKey("email") as? String
        role = JSON.valueForKey("role.name") as? String
        hrFunction = JSON.valueForKey("role.hrFunction") as? String
        designation = JSON.valueForKey("designation") as? String
        maritalStatus = JSON.valueForKeyPath("personalInformation.maritalStatus") as? String
        phoneNo = JSON.valueForKeyPath("personalInformation.mobile") as? String
        location = JSON.valueForKeyPath("personalInformation.location") as? String
        officialInformation = JSON.valueForKey("officialInformation") as? NSDictionary
        experiences = Parser.userExperienceFromDictionaryArray(JSON.valueForKey("experience") as? [NSDictionary])
        certifications = Parser.userCertificationFromDictionaryArray(JSON.valueForKey("certifications") as? [NSDictionary])
        manutalTaskStatus = CardStatus(value: JSON.valueForKeyPath("status") as? String)

    }
}



struct UserExperience {
    
    var designation : String?
    var companyName : String?
    var companyImageName : String?
    var websiteUrl : String?
    var fromDate : NSDate?
    var toDate : NSDate?
    
    init?(dictionaryData : NSDictionary?) {
        guard let unwrappedData = dictionaryData else{
            return nil
        }
        designation = unwrappedData.valueForKey("designation") as? String
        companyName = unwrappedData.valueForKey("companyName") as? String
        fromDate = Helper.dateForMMYYYYString(unwrappedData.valueForKeyPath("date.from") as? String)
        toDate = Helper.dateForMMYYYYString(unwrappedData.valueForKeyPath("date.to") as? String)
        websiteUrl = unwrappedData.valueForKey("website") as? String
    }
    init?(){
        
    }
}

struct UserCertification {
    
    var certificationTitle : String?
    var instituteName : String?
    var certificationDate : NSDate?
    
    init?(dictionaryData : NSDictionary?) {
        guard let unwrappedData = dictionaryData else{
            return nil
        }
        certificationTitle = unwrappedData.valueForKey("name") as? String
        instituteName = unwrappedData.valueForKey("institution") as? String
        certificationDate = Helper.dateForMMYYYYString(unwrappedData.valueForKeyPath("date") as? String)
    }
    init?(Title:String,Name:String,Date:NSDate){
        certificationTitle = Title
        instituteName = Name
        certificationDate = Date
    }
    init?(){
        
    }
}




