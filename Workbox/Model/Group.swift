//
//  SystemGroup.swift
//  Workbox
//
//  Created by Pavan Gopal on 11/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
class Group {
    var name : String?
    var imageName : String?
    var type : String?
    var groupId : String?
    var members : [User]?
    
    init(){
        
    }
    
    convenience init?(dictionaryData : NSDictionary?) {
        guard let data = dictionaryData else{
            return nil
        }
        self.init(JSON: data)
    }
    
    init(JSON:AnyObject){
        name = JSON.valueForKey("name") as? String
        groupId = JSON.valueForKey("_id") as? String
        type = JSON.valueForKey("type") as? String
        members  =  Parser.usersFromDictionaryArray(JSON.valueForKey("users") as? [NSDictionary])
        imageName = JSON.valueForKey("avatar") as? String
    }
}
