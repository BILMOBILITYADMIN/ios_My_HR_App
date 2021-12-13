//
//  Gamify.swift
//  Workbox
//
//  Created by Pavan Gopal on 25/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation

class GamifyUser {
    var id : String?
    var avatarURLString : String?
    var displayName : String?
    var designation : String?
    var progress : Int = 0
    var level : String?
    var contest : String?
    var  milestone : String?
    
    init(){
    }
    
    convenience init?(dictionaryData : NSDictionary?) {
        guard let data = dictionaryData else{
            return nil
        }
        self.init(JSON: data)
    }
    
    init(JSON: AnyObject) {
        
        id = JSON.valueForKeyPath("_id") as? String
        avatarURLString = JSON.valueForKeyPath("user.avatar") as? String
        displayName = JSON.valueForKeyPath("user.displayName") as? String
        designation = JSON.valueForKeyPath("user.designation") as? String
        progress = JSON.valueForKey("progress") as! Int
        level = JSON.valueForKey("level") as? String
        contest = JSON.valueForKey("contest") as? String
        milestone = JSON.valueForKey("milestone") as? String
        
    }
    
    

}