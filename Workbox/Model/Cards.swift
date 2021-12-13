//
//  Cards.swift
//  Workbox
//
//  Created by Chetan Anand on 14/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation


//MARK: - List View Card Model

/// ## ListView Data Model
class ListView {
    
    //Card Data Model
    var id: String?
    var workItemType: String?
    var updatedBy : User?
    var updatedAt : NSDate?
    var titleString: String?
    var isPublic: Bool = false
    var descriptionString: String?
    var isDeleted: Bool = false
    var createdBy : User?
    var assignedTo : [User]?
    var createdAt : NSDate?
    var contentString : NSDictionary?
    var likeCountInt: Int?
    var commentsCountInt : Int = 0
    var likedBySelf : Bool = false
    var comments: [Comment]?
    var numberOfComments: Int = 0
    var commonCardFields : CommonFields?
    var defaultManualCardActionsStringArray : [String]
    var cardStatus : CardStatus = CardStatus.Open
    //    var latestActivityText: String?
    var cardType  : CardType
    var cardSubtype : CardSubtype
    var cardMandatoryFields = [String]()
    var cardOptionalFields = [String]()
    
    //Card Rendering Model: Non-Optional
    var latestActivityBarEnabled : Bool = true
    var attachmentBarEnabled : Bool = true
    var actionBarEnabled: Bool = true
    var commentBarEnabled : Bool = true

    var defaultCardTemplate : CardTemplate
    var defaultCardActions = [CardAction]()
    
    enum CardTemplate: String {
        case GenericFeed01Card = "manualTask_card_001"
        init(value : String?){
            self =  CardTemplate(rawValue: value ?? "") ?? .GenericFeed01Card
        }
    }
    enum CardField: String {
        case LastActivity  = "lastActivity"
    }
    
    init(JSON: AnyObject) {
        id = JSON.valueForKeyPath("_id") as? String
        workItemType = JSON.valueForKeyPath("workItemType") as? String
        updatedBy = User(dictionaryData: JSON.valueForKeyPath("updatedBy") as? NSDictionary)
        updatedAt = Helper.dateForString(JSON.valueForKeyPath("updatedAt") as? String)
        titleString =  JSON.valueForKeyPath("title") as? String
        isPublic = (JSON.valueForKeyPath("public") as? String)?.boolValue ?? false
        descriptionString = JSON.valueForKeyPath("description") as? String
        isDeleted = (JSON.valueForKeyPath("delete") as? String)?.boolValue ?? false
        createdBy = User(dictionaryData: JSON.valueForKeyPath("createdBy") as? NSDictionary)
        
        if let  unwrappedDictionaryArray = JSON.valueForKeyPath("assignedTo") as? [NSDictionary]{
            assignedTo = unwrappedDictionaryArray.flatMap{ User(dictionaryData: $0) }
        }
        createdAt = Helper.dateForString(JSON.valueForKeyPath("createdAt") as? String)
        contentString = JSON.valueForKeyPath("content") as? NSDictionary
        comments = Parser.commentsFromAnyObject(JSON.valueForKeyPath("comments"))
        likeCountInt = JSON.valueForKeyPath("likeCount") as? Int
        commentsCountInt = (JSON.valueForKeyPath("commentsCount") as? Int) ?? 0
        likedBySelf = (JSON.valueForKeyPath("likedByUser") as? Int)?.boolValue ?? false
        commonCardFields = CommonFields(JSON: JSON)
        cardStatus = CardStatus(value: JSON.valueForKeyPath("status") as? String)

        cardType = CardType(value: JSON.valueForKeyPath("card.type") as? String)
        cardSubtype = CardSubtype(value: JSON.valueForKeyPath("card.subtype") as? String)
        defaultCardTemplate = CardTemplate(value: Parser.fetchCardTemplate(forType: cardType, forSubtype: cardSubtype))
        defaultCardActions = Parser.fetchActions(forType: cardType ,forSubtype: cardSubtype, forCardStatus: CardStatus.Unknown)
        
        defaultManualCardActionsStringArray = ["COMPLETE_TASK","CLOSE_TASK","HOLD_TASK","WITHDRAW_TASK","DELEGATE_TASK"]
        defaultCardActions = defaultManualCardActionsStringArray.flatMap{ CardAction(value: $0 as? String) }

        latestActivityBarEnabled  = cardOptionalFields.contains(CardField.LastActivity.rawValue)
        attachmentBarEnabled = true
        actionBarEnabled = true
        
        
        numberOfComments = comments?.count ?? 0

    }
}

//MARK: - New Joinee Card Model
class NewJoinee {
    
    //Card Data Model
    var id: String?
    var workItemType: String?
    var updatedBy : User?
    var updatedAt : NSDate?
    var titleString: String?
    var isPublic: Bool = false
    var descriptionString: String?
    var isDeleted: Bool = false
    var createdBy : User?
    var createdAt : NSDate?
    var contentString : String?
    var likeCountInt: Int?
    var commentsCountInt : Int = 0
    var likedBySelf : Bool = false
    var comments: [Comment]?
    var numberOfComments: Int = 0
    //    var latestActivityText: String?
    var commonCardFields : CommonFields?
    
    
    var cardType  : CardType
    var cardSubtype : CardSubtype
    var cardMandatoryFields = [String]()
    var cardOptionalFields = [String]()
    
    
    //Card Rendering Model: Non-Optional
    var latestActivityBarEnabled : Bool = true
    var attachmentBarEnabled : Bool
    var actionBarEnabled: Bool = true
    var commentBarEnabled : Bool = true

    
    var defaultCardTemplate : CardTemplate
    var defaultCardActions : [CardAction]
    
    
    enum CardTemplate: String {
        case NewJoinee01Card  = "newjoinee_card_001"
        
        init(value : String?){
            self =  CardTemplate(rawValue: value ?? "") ?? .NewJoinee01Card
        }
    }
    enum CardField: String {
        case LastActivity  = "lastActivity"
    }
    
    init(JSON: AnyObject) {
        id = JSON.valueForKeyPath("_id") as? String
        workItemType = JSON.valueForKeyPath("workItemType") as? String
        updatedBy = User(dictionaryData: JSON.valueForKeyPath("updatedBy") as? NSDictionary)
        updatedAt = Helper.dateForString(JSON.valueForKeyPath("updatedAt") as? String)
        titleString =  JSON.valueForKeyPath("title") as? String
        isPublic = (JSON.valueForKeyPath("public") as? String)?.boolValue ?? false
        descriptionString = JSON.valueForKeyPath("description") as? String
        isDeleted = (JSON.valueForKeyPath("delete") as? String)?.boolValue ?? false
        createdBy = User(dictionaryData: JSON.valueForKeyPath("createdBy") as? NSDictionary)
        createdAt = Helper.dateForString(JSON.valueForKeyPath("createdAt") as? String)
        contentString = JSON.valueForKeyPath("content") as? String
        likeCountInt = JSON.valueForKeyPath("likeCount") as? Int
        likedBySelf = (JSON.valueForKeyPath("likedByUser") as? Int)?.boolValue ?? false
        comments = Parser.commentsFromAnyObject(JSON.valueForKeyPath("comments"))
        cardType = CardType(value: JSON.valueForKeyPath("card.type") as? String)
        cardSubtype = CardSubtype(value: JSON.valueForKeyPath("card.subtype") as? String)
        commonCardFields = CommonFields(JSON: JSON)
        
        cardOptionalFields = Parser.fetchOptionalFields(forType: cardType, forSubtype: cardSubtype)
        
        latestActivityBarEnabled  = false
        attachmentBarEnabled = false
        actionBarEnabled = true
        commentBarEnabled = false
        defaultCardTemplate = CardTemplate(value: Parser.fetchCardTemplate(forType: cardType, forSubtype: cardSubtype))
        defaultCardActions = Parser.fetchActions(forType: cardType ,forSubtype: cardSubtype, forCardStatus: CardStatus.Unknown)
    
        
        
    }
}

//MARK: - News Feed Card Model
class NewsFeed {
    
    //Card Data Model
    var id: String?
    var workItemType: String?
    var updatedBy : User?
    var updatedAt : NSDate?
    var titleString: String?
    var isPublic: Bool = false
    var descriptionString: String?
    var isDeleted: Bool = false
    var createdBy : User?
    var createdAt : NSDate?
    var contentString : String?
    var likeCountInt: Int?
    var commentsCountInt : Int = 0
    var likedBySelf : Bool = false
    var comments: [Comment]?
    var numberOfComments: Int = 0
    var commonCardFields : CommonFields?
    
    
    var cardType  : CardType
    var cardSubtype : CardSubtype
    var cardMandatoryFields = [String]()
    var cardOptionalFields = [String]()
    
    //Card Rendering Model: Non-Optional
    var latestActivityBarEnabled : Bool = false
    var commentBarEnabled : Bool = false
    var likeCountEnabled : Bool = false
    var commentCountEnabled : Bool = false
    var actionBarEnabled : Bool = true

    
    var defaultCardTemplate : CardTemplate
    var defaultCardActions : [CardAction]
    
    enum CardTemplate: String {
        case NewsFeed01Card = "news_card_001"

        init(value : String?){
            self =  CardTemplate(rawValue: value ?? "") ?? .NewsFeed01Card
        }
    }
    enum CardField: String {
        case LastActivity  = "lastActivity"
        case LikeCount = "likeCount"
        case CommentCount = "commentCount"
        case LastComment = "lastComment"
    }
    
    init(JSON: AnyObject) {
        id = JSON.valueForKeyPath("_id") as? String
        workItemType = JSON.valueForKeyPath("workItemType") as? String
        updatedBy = User(dictionaryData: JSON.valueForKeyPath("updatedBy") as? NSDictionary)
        updatedAt = Helper.dateForString(JSON.valueForKeyPath("updatedAt") as? String)
        titleString =  JSON.valueForKeyPath("title") as? String
        isPublic = (JSON.valueForKeyPath("public") as? String)?.boolValue ?? false
        descriptionString = JSON.valueForKeyPath("description") as? String
        isDeleted = (JSON.valueForKeyPath("delete") as? String)?.boolValue ?? false
        createdBy = User(dictionaryData: JSON.valueForKeyPath("createdBy") as? NSDictionary)
        createdAt = Helper.dateForString(JSON.valueForKeyPath("createdAt") as? String)
        contentString = JSON.valueForKeyPath("content") as? String
        comments = Parser.commentsFromAnyObject(JSON.valueForKeyPath("comments"))
        likeCountInt = JSON.valueForKeyPath("likeCount") as? Int
        commentsCountInt = (JSON.valueForKeyPath("commentsCount") as? Int) ?? 0
        likedBySelf = (JSON.valueForKeyPath("likedByUser") as? Int)?.boolValue ?? false
        
        commonCardFields = CommonFields(JSON: JSON)
        
        cardType = CardType(value: JSON.valueForKeyPath("card.type") as? String)
        cardSubtype = CardSubtype(value: JSON.valueForKeyPath("card.subtype") as? String)
        
        defaultCardTemplate = CardTemplate(value: Parser.fetchCardTemplate(forType: cardType, forSubtype: cardSubtype))
        defaultCardActions = Parser.fetchActions(forType: cardType ,forSubtype: cardSubtype, forCardStatus: CardStatus.Unknown)
        
        cardOptionalFields = Parser.fetchOptionalFields(forType: cardType, forSubtype: cardSubtype)
        
        likeCountEnabled = cardOptionalFields.contains(CardField.LikeCount.rawValue)
        commentCountEnabled = cardOptionalFields.contains(CardField.CommentCount.rawValue)
        latestActivityBarEnabled  = cardOptionalFields.contains(CardField.LastActivity.rawValue)
        commentBarEnabled = cardOptionalFields.contains(CardField.LastComment.rawValue)

    }
}
//MARK: - Generic Feed Card Model
class GenericFeed {
    
    //Card Data Model
    var id: String?
    var workItemType: String?
    var updatedBy : User?
    var updatedAt : NSDate?
    var titleString: String?
    var isPublic: Bool = false
    var descriptionString: String?
    var isDeleted: Bool = false
    var createdBy : User?
    var createdAt : NSDate?
    var contentString : String?
    var likeCountInt: Int?
    var commentsCountInt : Int = 0
    var likedBySelf : Bool = false
    var comments: [Comment]?
    var attachments : [Attachment]?
    var numberOfComments: Int = 0
    var commonCardFields : CommonFields?
    
    
    var cardType  : CardType
    var cardSubtype : CardSubtype
    var cardMandatoryFields = [String]()
    var cardOptionalFields = [String]()
    
    //Card Rendering Model: Non-Optional
    var latestActivityBarEnabled : Bool = false
    var commentBarEnabled : Bool = false
    var likeCountEnabled : Bool = false
    var commentCountEnabled : Bool = false
    var galleryEnabled : Bool = false
    var descriptionEnabled : Bool = false
    var actionBarEnabled : Bool = true

    
    
    
    var defaultCardTemplate : CardTemplate
    var defaultCardActions : [CardAction]
    
    enum CardTemplate: String {
        case UserMessage01Card = "userMessage_card_001"

        init(value : String?){
            self =  CardTemplate(rawValue: value ?? "") ?? .UserMessage01Card
        }
    }
    enum CardField: String {
        case LastActivity  = "lastActivity"
        case LikeCount = "likeCount"
        case CommentCount = "commentCount"
        case LastComment = "lastComment"
        case Gallery = "gallery"
        case Description = "description"

    }
    
    init(JSON: AnyObject) {
        id = JSON.valueForKeyPath("_id") as? String
        workItemType = JSON.valueForKeyPath("workItemType") as? String
        updatedBy = User(dictionaryData: JSON.valueForKeyPath("updatedBy") as? NSDictionary)
        updatedAt = Helper.dateForString(JSON.valueForKeyPath("updatedAt") as? String)
        titleString =  JSON.valueForKeyPath("title") as? String
        isPublic = (JSON.valueForKeyPath("public") as? String)?.boolValue ?? false
        descriptionString = JSON.valueForKeyPath("description") as? String
        isDeleted = (JSON.valueForKeyPath("delete") as? String)?.boolValue ?? false
        createdBy = User(dictionaryData: JSON.valueForKeyPath("createdBy") as? NSDictionary)
        createdAt = Helper.dateForString(JSON.valueForKeyPath("createdAt") as? String)
        contentString = JSON.valueForKeyPath("content") as? String
        comments = Parser.commentsFromAnyObject(JSON.valueForKeyPath("comments"))
        likeCountInt = JSON.valueForKeyPath("likeCount") as? Int
        commentsCountInt = (JSON.valueForKeyPath("commentsCount") as? Int) ?? 0
        likedBySelf = (JSON.valueForKeyPath("likedByUser") as? Int)?.boolValue ?? false
        attachments = Parser.attachmentsFromDictionaryArray( JSON.valueForKeyPath("attachments") as? [NSDictionary])
        
        commonCardFields = CommonFields(JSON: JSON)
        
        cardType = CardType(value: JSON.valueForKeyPath("card.type") as? String)
        cardSubtype = CardSubtype(value: JSON.valueForKeyPath("card.subtype") as? String)
        
        defaultCardTemplate = CardTemplate(value: Parser.fetchCardTemplate(forType: cardType, forSubtype: cardSubtype))
        
        defaultCardActions = Parser.fetchActions(forType: cardType ,forSubtype: cardSubtype, forCardStatus: CardStatus.Unknown)
        
        cardOptionalFields = Parser.fetchOptionalFields(forType: cardType, forSubtype: cardSubtype)
        numberOfComments = comments?.count ?? 0

        
        //Rendering model parsing
        likeCountEnabled = cardOptionalFields.contains(CardField.LikeCount.rawValue)
        commentCountEnabled = cardOptionalFields.contains(CardField.CommentCount.rawValue)
        galleryEnabled = cardOptionalFields.contains(CardField.Gallery.rawValue)
        descriptionEnabled = cardOptionalFields.contains(CardField.Description.rawValue)
        latestActivityBarEnabled  = cardOptionalFields.contains(CardField.LastActivity.rawValue)
        commentBarEnabled = cardOptionalFields.contains(CardField.LastComment.rawValue)
    
    }
}

//MARK: - News Feed Card Model
class GenericTask {
    
    //Card Data Model
    var id: String?
    var workItemType: String?
    var updatedBy : User?
    var updatedAt : NSDate?
    var titleString: String?
    var isPublic: Bool = false
    var descriptionString: String?
    var isDeleted: Bool = false
    var createdBy : User?
    var createdAt : NSDate?
    var contentString : NSDictionary?
    var likeCountInt: Int?
    var commentsCountInt : Int = 0
    var likedBySelf : Bool = false
    var comments: [Comment]?
    var attachments : [Attachment]?
    var assignedTo : [User]?
    var numberOfComments: Int = 0
    var commonCardFields : CommonFields?
    var cardStatus : CardStatus = CardStatus.Open

    
    
    var cardType  : CardType
    var cardSubtype : CardSubtype
    var cardEnabledFields = [String]()
    
    //Card Rendering Model: Non-Optional
    var latestActivityBarEnabled : Bool = false
    var commentBarEnabled : Bool = false
    var likeCountEnabled : Bool = false
    var commentCountEnabled : Bool = false
    var galleryEnabled : Bool = false
    var descriptionEnabled : Bool = false
    var avatarEnabled : Bool = true
    var actionBarEnabled : Bool = true


    
    var defaultCardTemplate : CardTemplate
    var defaultCardActions : [CardAction]
    var defaultManualCardActionsStringArray : [String]


    
    enum CardTemplate: String {
        case GenericTask01Card = "manualTask_card_001"
        init(value : String?){
            self =  CardTemplate(rawValue: value ?? "") ?? .GenericTask01Card
        }
    }
    
    enum CardField: String {
        case LastActivity  = "lastActivity"
        case LikeCount = "likeCount"
        case CommentCount = "commentCount"
        case LastComment = "lastComment"
        case Gallery = "gallery"
        case Description = "description"
        case avatar = "avatar"
    }
    
    
    
    init(JSON: AnyObject) {
        id = JSON.valueForKeyPath("_id") as? String
        workItemType = JSON.valueForKeyPath("workItemType") as? String
        updatedBy = User(dictionaryData: JSON.valueForKeyPath("updatedBy") as? NSDictionary)
        updatedAt = Helper.dateForString(JSON.valueForKeyPath("updatedAt") as? String)
        titleString =  JSON.valueForKeyPath("title") as? String
        isPublic = (JSON.valueForKeyPath("public") as? String)?.boolValue ?? false
        descriptionString = JSON.valueForKeyPath("description") as? String
        isDeleted = (JSON.valueForKeyPath("delete") as? String)?.boolValue ?? false
        createdBy = User(dictionaryData: JSON.valueForKeyPath("createdBy") as? NSDictionary)
        createdAt = Helper.dateForString(JSON.valueForKeyPath("createdAt") as? String)
        contentString = JSON.valueForKeyPath("content") as? NSDictionary
        comments = Parser.commentsFromAnyObject(JSON.valueForKeyPath("comments"))
        likeCountInt = JSON.valueForKeyPath("likeCount") as? Int
        commentsCountInt = (JSON.valueForKeyPath("commentsCount") as? Int) ?? 0
        likedBySelf = (JSON.valueForKeyPath("likedByUser") as? Int)?.boolValue ?? false
        attachments = Parser.attachmentsFromDictionaryArray( JSON.valueForKeyPath("attachments") as? [NSDictionary])
        cardStatus = CardStatus(value: JSON.valueForKeyPath("status") as? String)
        commonCardFields = CommonFields(JSON: JSON)
        
        if let  unwrappedDictionaryArray = JSON.valueForKeyPath("assignedTo") as? [NSDictionary]{
            assignedTo = unwrappedDictionaryArray.flatMap{ User(dictionaryData: $0) }
        }
        
        cardType = CardType(value: JSON.valueForKeyPath("card.type") as? String)
        cardSubtype = CardSubtype(value: JSON.valueForKeyPath("card.subtype") as? String)
        
        defaultCardTemplate = CardTemplate(value: Parser.fetchCardTemplate(forType: cardType, forSubtype: cardSubtype))
        defaultCardActions = Parser.fetchActions(forType: cardType ,forSubtype: cardSubtype, forCardStatus: cardStatus)
        
//        //temp
        defaultManualCardActionsStringArray = ["COMPLETE_TASK","CLOSE_TASK","HOLD_TASK","WITHDRAW_TASK","DELEGATE_TASK"]
        defaultCardActions = defaultManualCardActionsStringArray.flatMap{ CardAction(value: $0 as? String) }
////        for item in cardStatus.disabledActions{
////            actionsArray.removeObject(item)
////        }

        
        cardEnabledFields = Parser.fetchOptionalFields(forType: cardType, forSubtype: cardSubtype)
        
        
        //Rendering model parsing
        
        likeCountEnabled = false
        commentCountEnabled = false
        galleryEnabled = true
        descriptionEnabled = true
        latestActivityBarEnabled  = cardEnabledFields.contains(CardField.LastActivity.rawValue)
        commentBarEnabled = false
        
        numberOfComments = comments?.count ?? 0
    }
    
    func isFieldEnabled(cardField : CardField) -> Bool {
        return  cardEnabledFields.contains(cardField.rawValue)
    }
}




class Gamify {
    
    var id : String?
    var workItemType :String?
    var cardObject : GamifyUser?
    var cardType  : CardType
    var cardSubtype : CardSubtype
    var commonCardFields : CommonFields?
    var defaultCardTemplate : CardTemplate

//    var defaultCardActions : [CardAction]
    var cardEnabledFields = [String]()

    init(JSON: AnyObject) {
        id = JSON.valueForKeyPath("_id") as? String
        workItemType = JSON.valueForKeyPath("workItemType") as? String
        
        commonCardFields = CommonFields(JSON: JSON)
        
        cardType = CardType(value: JSON.valueForKeyPath("card.type") as? String)
        cardSubtype = CardSubtype(value: JSON.valueForKeyPath("card.subtype") as? String)
        
        defaultCardTemplate = CardTemplate(value: Parser.fetchCardTemplate(forType: cardType, forSubtype: cardSubtype))
        
        
        
        cardEnabledFields = Parser.fetchOptionalFields(forType: cardType, forSubtype: cardSubtype)
        
        
     
    }
    
    enum CardTemplate: String {
        case GamifyCell = "Gamify_Leaderboard_001"
        init(value : String?){
            self =  CardTemplate(rawValue: value ?? "") ?? .GamifyCell
        }
    }
    
    
    
    enum CardField: String {
        case Contest  = "contest"
        case Level = "level"
        case Milestone = "milestone"
    }
    
    
    func isFieldEnabled(cardField : CardField) -> Bool {
        return  cardEnabledFields.contains(cardField.rawValue)
    }

}


class PMSAppraisalTemplate{
    //Card Data Model
    var id: String?
    var workItemType: String?
    var updatedBy : User?
    var updatedAt : NSDate?
    var titleString: String?
    var isPublic: Bool = false
    var isSystem: Bool = true
    var descriptionString: String?
    var isDeleted: Bool = false
    var createdBy : User?
    var assignedTo : [User]?
    var subscribers : [User]?
    var createdAt : NSDate?
    var contentString : String?
    var cardStatus : CardStatus = CardStatus.Open
    
    var contentId : String?
    var contentType : String?
    
   
    
    var submittedBy : User?
     var actionBarEnabled : Bool = true
    
    
    
    var cardType  : CardType
    var cardSubtype : CardSubtype
    var cardMandatoryFields = [String]()
    var cardOptionalFields = [String]()
    
    
    
    var defaultCardTemplate : CardTemplate = CardTemplate.PMSApproval01Card
    var defaultCardActions : [CardAction]
    
    
    enum CardTemplate: String {
    case PMSApproval01Card = "appraisal_Template_001"
    init(value : String?){
    self =  CardTemplate(rawValue: value ?? "") ?? .PMSApproval01Card
    }
    }

    
    init(JSON: AnyObject) {
    id = JSON.valueForKeyPath("_id") as? String
    workItemType = JSON.valueForKeyPath("workItemType") as? String
    updatedBy = User(dictionaryData: JSON.valueForKeyPath("updatedBy") as? NSDictionary)
    
    if let  unwrappedDictionaryArray = JSON.valueForKeyPath("assignedTo") as? [NSDictionary]{
    assignedTo = unwrappedDictionaryArray.flatMap{ User(dictionaryData: $0) }
    }
    if let  unwrappedDictionaryArray = JSON.valueForKeyPath("subscribers") as? [NSDictionary]{
    subscribers = unwrappedDictionaryArray.flatMap{ User(dictionaryData: $0) }
    }
    
    updatedAt = Helper.dateForString(JSON.valueForKeyPath("updatedAt") as? String)
    titleString =  JSON.valueForKeyPath("content.name") as? String
    isPublic = (JSON.valueForKeyPath("public") as? String)?.boolValue ?? false
    descriptionString = JSON.valueForKeyPath("content.description") as? String
    isDeleted = (JSON.valueForKeyPath("delete") as? String)?.boolValue ?? false
    createdBy = User(dictionaryData: JSON.valueForKeyPath("content.createdBy") as? NSDictionary)
    createdAt = Helper.dateForString(JSON.valueForKeyPath("content.createdAt") as? String)
    contentString = JSON.valueForKeyPath("content") as? String
 
    cardStatus = CardStatus(value: JSON.valueForKeyPath("status") as? String)
  
    cardType = CardType(value: JSON.valueForKeyPath("card.type") as? String)
    cardSubtype = CardSubtype(value: JSON.valueForKeyPath("card.subtype") as? String)
    defaultCardTemplate = CardTemplate(value: Parser.fetchCardTemplate(forType: cardType, forSubtype: cardSubtype))
    //        defaultCardActions = Parser.fetchActions(forType: cardType ,forSubtype: cardSubtype, forCardStatus: cardStatus)
    defaultCardActions = [CardAction.Approve, CardAction.Reject]
    cardOptionalFields = Parser.fetchOptionalFields(forType: cardType, forSubtype: cardSubtype)
    

    //Content
    contentId = JSON.valueForKeyPath("content._id") as? String
    contentType = JSON.valueForKeyPath("content.type") as? String
   
    
    //Content>submittedBy
    submittedBy = User(dictionaryData: JSON.valueForKeyPath("createdBy") as? NSDictionary)
    
    
    
    
    }
    

    
}






//MARK: - News Feed Card Model
class Approval {
    
    //Card Data Model
    var id: String?
    var workItemType: String?
    var updatedBy : User?
    var updatedAt : NSDate?
    var titleString: String?
    var isPublic: Bool = false
    var descriptionString: String?
    var isDeleted: Bool = false
    var createdBy : User?
    var assignedTo : [User]?
    var createdAt : NSDate?
    var contentString : String?
    var likeCountInt: Int?
    var commentsCountInt : Int = 0
    var likedBySelf : Bool = false
    var comments: [Comment]?
    var numberOfComments: Int = 0
    var cardStatus : CardStatus = CardStatus.Open
    
    var contentId : String?
    var contentType : String?
    
    var submittedHours : Double
    var allocatedHours : Double
    var projectHours : Double
    var nonProjectHours : Double
    
    var projectType : String?
    var projectId: String?
    var projectName : String?
    
    var days : [Day]?
    var weekStartDate : NSDate?
    var weekEndDate : NSDate?
    
    var leaveStartDate : NSDate?
    var leaveEndDate : NSDate?
    var leaveHours : Double?
    
    var submittedBy : User?
    
    
    
    
    var cardType  : CardType
    var cardSubtype : CardSubtype
    var cardMandatoryFields = [String]()
    var cardOptionalFields = [String]()
    
    //Card Rendering Model: Non-Optional
    var taskScheduleEnabled : Bool = true   //Mandatory Field
    var noOfDaysEnabled : Bool = true              //Mandatory Field
    var toSession : Bool = false            //Optional Field
    var statusLabel: Bool = false                //Optional Field
    var fromSession : Bool = false          //Optional Field
    var actionBarEnabled : Bool = true

    
    var defaultCardTemplate : CardTemplate = CardTemplate.Approval01Card
    var defaultCardActions : [CardAction]

    
    enum CardTemplate: String {
        case Approval01Card = "approval_Card_001"
        init(value : String?){
            self =  CardTemplate(rawValue: value ?? "") ?? .Approval01Card
        }
    }
    
    enum CardField: String {
        case TaskSchedule  = "taskSchedule"
        case NoOfDays = "noOfDays"
        case ToSession = "toSession"
        case Status = "status"
        case FromSession = "fromSession"
    }
    
    
    init(JSON: AnyObject) {
        id = JSON.valueForKeyPath("_id") as? String
        workItemType = JSON.valueForKeyPath("workItemType") as? String
        updatedBy = User(dictionaryData: JSON.valueForKeyPath("updatedBy") as? NSDictionary)
        
        if let  unwrappedDictionaryArray = JSON.valueForKeyPath("assignedTo") as? [NSDictionary]{
            assignedTo = unwrappedDictionaryArray.flatMap{ User(dictionaryData: $0) }
        }
        
        updatedAt = Helper.dateForString(JSON.valueForKeyPath("updatedAt") as? String)
        titleString =  JSON.valueForKeyPath("title") as? String
        isPublic = (JSON.valueForKeyPath("public") as? String)?.boolValue ?? false
        descriptionString = JSON.valueForKeyPath("description") as? String
        isDeleted = (JSON.valueForKeyPath("delete") as? String)?.boolValue ?? false
        createdBy = User(dictionaryData: JSON.valueForKeyPath("createdBy") as? NSDictionary)
        createdAt = Helper.dateForString(JSON.valueForKeyPath("createdAt") as? String)
        contentString = JSON.valueForKeyPath("content") as? String
        comments = Parser.commentsFromAnyObject(JSON.valueForKeyPath("comments"))
        likeCountInt = JSON.valueForKeyPath("likeCount") as? Int
        commentsCountInt = (JSON.valueForKeyPath("commentsCount") as? Int) ?? 0
        cardStatus = CardStatus(value: JSON.valueForKeyPath("status") as? String)
        
        likedBySelf = (JSON.valueForKeyPath("likedByUser") as? Int)?.boolValue ?? false
        cardType = CardType(value: JSON.valueForKeyPath("card.type") as? String)
        cardSubtype = CardSubtype(value: JSON.valueForKeyPath("card.subtype") as? String)
        defaultCardTemplate = CardTemplate(value: Parser.fetchCardTemplate(forType: cardType, forSubtype: cardSubtype))
//        defaultCardActions = Parser.fetchActions(forType: cardType ,forSubtype: cardSubtype, forCardStatus: cardStatus)
        defaultCardActions = [CardAction.Approve, CardAction.Reject]
        cardOptionalFields = Parser.fetchOptionalFields(forType: cardType, forSubtype: cardSubtype)

        //Content
        contentId = JSON.valueForKeyPath("content._id") as? String
        contentType = JSON.valueForKeyPath("content.type") as? String
        submittedHours = JSON.valueForKeyPath("content.submittedHours") as? Double ?? 0
        allocatedHours = JSON.valueForKeyPath("content.allocatedHours") as? Double ?? 0
        projectHours = JSON.valueForKeyPath("content.hours") as? Double ?? 0
        nonProjectHours = JSON.valueForKeyPath("content.nonProject") as? Double ?? 0
        
        //Content>Project
        projectType = JSON.valueForKeyPath("content.project.type") as? String
        projectId = JSON.valueForKeyPath("content.project._id") as? String
        projectName = JSON.valueForKeyPath("content.project.name") as? String
        
        //Content>Day
        days = Parser.daysFromDictionaryArray(JSON.valueForKeyPath("content.days") as? [NSDictionary])
        
        //Content>Week
        weekStartDate = Helper.dateForDDMMYYYYString(JSON.valueForKeyPath("content.week.startDate") as? String)
        weekEndDate = Helper.dateForDDMMYYYYString(JSON.valueForKeyPath("content.week.endDate") as? String)
        
        //Content>Leave
        leaveStartDate = Helper.dateForDDMMYYYYString(JSON.valueForKeyPath("content.leave.startDate") as? String)
        leaveEndDate = Helper.dateForDDMMYYYYString(JSON.valueForKeyPath("content.leave.endDate") as? String)
        leaveHours = JSON.valueForKeyPath("content.leave.hours") as? Double ?? 0
        
        //Content>submittedBy
        submittedBy = User(dictionaryData: JSON.valueForKeyPath("content.submittedBy") as? NSDictionary)
        
        
        

    }
    
    func isFieldEnabled(cardField : CardField) -> Bool {
      return  cardOptionalFields.contains(cardField.rawValue)
    }
}


class LeaveApproval {
    //Card Data Model
    var id: String?
    var isPublic: Bool = false
    var isSystem: Bool = false
    var titleString: String?
    var descriptionString: String?
    var assignedTo : [User]?
    var subscribers : [User]?
    var createdBy : User?
    var updatedBy : User?
    var createdAt : NSDate?
    var updatedAt : NSDate?
    var likeCount : Int?
    var likedBySelf : Bool = false
    
    var attachments : [Attachment]?
    var cardStatus : CardStatus = CardStatus.Open
    var commonCardFields : CommonFields?
    var isDeleted: Bool = false
    
    //Content
    var contentId : String?
    var contentType : String?
    
    
    
    //Content>Leave
    var leaveId : String?
    var leaveName : String?
    var leaveCode : String?
    
    var leaveDuration : String?
    var leaveFromDate : NSDate?
    var leaveToDate   : NSDate?
    var leaveFromSession : Int?
    var leaveToSession : Int?
    
    var leaveSubmittedBy : User?
    var leaveCopyTo : [User]?
    
    var leaveAttachments : [Attachment]?
    var leaveBalances : [LeaveBalance]?
    
    
    //Card Type/Subtype
    var cardType  : CardType
    var cardSubtype : CardSubtype
    
    
    //Card Template 
    var defaultCardTemplate : CardTemplate = CardTemplate.LeaveApproval01Card
    var defaultCardActions : [CardAction]
    

    //Card Rendering Model: Non-Optional
    var cardEnabledFields = [String]()
    var actionBarEnabled : Bool = true

    //Mandatory Field
    var isAvatarEnabled : Bool = true
    var isDurationEnabled : Bool = true
    var isLeavetypeEnabled : Bool = true
    var isFromDateEnabled : Bool = true
    var isToDateEnabled : Bool = true
    //Optional Field
    var isLeaveBalanceEnabled : Bool = false
    var isFromTimeEnabled : Bool = false
    var isToTimeEnabled : Bool = false

    

    //Private Enums
    enum CardTemplate: String {
        case LeaveApproval01Card = "leave_approval_Card_001"
        init(value : String?){
            self =  CardTemplate(rawValue: value ?? "") ?? .LeaveApproval01Card
        }
    }
    
    //Initialiser
    init(JSON: AnyObject) {
        cardType = CardType(value: JSON.valueForKeyPath("card.type") as? String)
        cardSubtype = CardSubtype(value: JSON.valueForKeyPath("card.subtype") as? String)

        defaultCardTemplate = CardTemplate(value: Parser.fetchCardTemplate(forType: cardType, forSubtype: cardSubtype))
        defaultCardActions = Parser.fetchActions(forType: cardType ,forSubtype: cardSubtype, forCardStatus: cardStatus)
        cardEnabledFields = Parser.fetchEnabledFields(forType: cardType, forSubtype: cardSubtype)
        
        id = JSON.valueForKeyPath("_id") as? String
        isPublic = (JSON.valueForKeyPath("public") as? String)?.boolValue ?? false
        isSystem = (JSON.valueForKeyPath("system") as? String)?.boolValue ?? false
        titleString =  JSON.valueForKeyPath("title") as? String
        descriptionString = JSON.valueForKeyPath("description") as? String
        
        if let  unwrappedDictionaryArray = JSON.valueForKeyPath("assignedTo") as? [NSDictionary]{
            assignedTo = unwrappedDictionaryArray.flatMap{ User(dictionaryData: $0) }
        }
        if let  unwrappedDictionaryArray = JSON.valueForKeyPath("subscribers") as? [NSDictionary]{
            subscribers = unwrappedDictionaryArray.flatMap{ User(dictionaryData: $0) }
        }
        createdBy = User(dictionaryData: JSON.valueForKeyPath("createdBy") as? NSDictionary)
        updatedBy = User(dictionaryData: JSON.valueForKeyPath("updatedBy") as? NSDictionary)
        createdAt = Helper.dateForString(JSON.valueForKeyPath("createdAt") as? String)
        updatedAt = Helper.dateForString(JSON.valueForKeyPath("updatedAt") as? String)
        likeCount = JSON.valueForKeyPath("likeCount") as? Int
        likedBySelf = (JSON.valueForKeyPath("likedByUser") as? Int)?.boolValue ?? false
        attachments = Parser.attachmentsFromDictionaryArray( JSON.valueForKeyPath("attachments") as? [NSDictionary])
        cardStatus = CardStatus(value: JSON.valueForKeyPath("status") as? String)
        commonCardFields = CommonFields(JSON: JSON)
        isDeleted = (JSON.valueForKeyPath("delete") as? String)?.boolValue ?? false
        
        //Content
        contentId = JSON.valueForKeyPath("content._id") as? String
        contentType = JSON.valueForKeyPath("content.type") as? String
        
        //Content>Leave
        leaveId = JSON.valueForKeyPath("content.leave._id") as? String
        leaveName = JSON.valueForKeyPath("content.leave.name") as? String
        leaveCode = JSON.valueForKeyPath("content.leave.code") as? String
        
        leaveDuration = JSON.valueForKeyPath("content.duration") as? String
        leaveFromDate = Helper.dateForString(JSON.valueForKeyPath("content.from") as? String)
        leaveToDate = Helper.dateForString(JSON.valueForKeyPath("content.to") as? String)
        leaveFromSession = JSON.valueForKeyPath("content.fromSession") as? Int
        leaveToSession = JSON.valueForKeyPath("content.toSession") as? Int
        
        leaveSubmittedBy = User(dictionaryData: JSON.valueForKeyPath("content.submittedBy") as? NSDictionary)
        if let  unwrappedDictionaryArray = JSON.valueForKeyPath("content.copyTo") as? [NSDictionary]{
            leaveCopyTo = unwrappedDictionaryArray.flatMap{ User(dictionaryData: $0) }
        }
        
        leaveAttachments = Parser.attachmentsFromDictionaryArray( JSON.valueForKeyPath("content.attachments") as? [NSDictionary])
        
        if let  unwrappedDictionaryArray = JSON.valueForKeyPath("content.leaveBalance") as? [NSDictionary]{
            leaveBalances = unwrappedDictionaryArray.flatMap{ LeaveBalance(dictionaryData: $0) }
        }
        
        //setting optional fields
        isLeaveBalanceEnabled = cardEnabledFields.contains("leaveBalance")
        isFromTimeEnabled = cardEnabledFields.contains("fromTime")
        isToTimeEnabled = cardEnabledFields.contains("toTime")
    }

}

//MARK: - Other Sub Models

struct CommonFields {
    var lastActivityAction : CardAction?
    var lastActivityText: String?
    var lastActivityTime : NSDate?
    var userDisplayName : String?
    
    
    init?(JSON: AnyObject){
        
        guard JSON.valueForKeyPath("lastActivity") is NSDictionary else{
            return
        }
        lastActivityText = JSON.valueForKeyPath("lastActivity.activity") as? String
        userDisplayName = JSON.valueForKeyPath("lastActivity.user") as? String
        userDisplayName = userDisplayName?.capitalizedString
        lastActivityAction = CardAction(value: JSON.valueForKeyPath("lastActivity.action") as? String)
        lastActivityTime = Helper.dateForString(JSON.valueForKeyPath("lastActivity.time") as? String)
    }
}





struct Comment {
    var id : String?
    var commentText : String?
    var createdAt : NSDate?
    var isDeleted: Bool = false
    var commentedBy: User?
    var attachments : [Attachment]?
    init(){}
    init(dictionaryData : NSDictionary) {
        id = dictionaryData.valueForKeyPath("_id") as? String
        commentText = dictionaryData.valueForKeyPath("text") as? String
        createdAt = Helper.dateForString(dictionaryData.valueForKeyPath("createdAt") as? String)
        isDeleted = (dictionaryData.valueForKeyPath("deleted") as? Int)?.boolValue ?? false
        commentedBy = User(dictionaryData: dictionaryData.valueForKeyPath("commentedBy") as? NSDictionary)
        attachments = Parser.attachmentsFromDictionaryArray( dictionaryData.valueForKeyPath("attachments") as? [NSDictionary])
    }
}

struct Attachment {
    var attachmentName : String?
    var attachmentType : AttachmentType?
    var urlString: String?
    var createdBy : User?
    
    
    init(dictionaryData : NSDictionary) {
        attachmentName = dictionaryData.valueForKeyPath("DisplayName") as? String
        attachmentType = AttachmentType(value: dictionaryData.valueForKeyPath("type") as? String)
        urlString = dictionaryData.valueForKeyPath("url") as? String
        createdBy = User(dictionaryData: dictionaryData.valueForKeyPath("createdBy") as? NSDictionary)
    }
}


struct Day {
    var date : NSDate?
    var allocatedHours : Double?
    var  tasks : [Task]?
    
    init?(dictionaryData : NSDictionary?) {
        guard let unwrappedDictionaryData = dictionaryData else{
            return nil
        }
        date = Helper.dateForDDMMYYYYString(unwrappedDictionaryData.valueForKeyPath("date") as? String)
        allocatedHours = Double(unwrappedDictionaryData.valueForKeyPath("allocatedHours") as? String ?? "0")
        if let  unwrappedDictionaryArray = unwrappedDictionaryData.valueForKeyPath("tasks") as? [NSDictionary]{
            tasks = unwrappedDictionaryArray.flatMap{ Task(dictionaryData: $0) }
        }
    }
}

struct Task {
    var name : String?
    var hours : Double?
    init(dictionaryData : NSDictionary) {
        name = dictionaryData.valueForKeyPath("name") as? String
        hours = (dictionaryData.valueForKeyPath("hours") as? Double ?? 0.0)
    }
}


struct LeaveBalance {
    var id : String?
    var name : String?
    var code : String?
    var availableLeave : Int?
    var availedLeave : Int?
    
    init(dictionaryData : NSDictionary) {
        id = dictionaryData.valueForKeyPath("_id") as? String
        name = dictionaryData.valueForKeyPath("name") as? String
        code = dictionaryData.valueForKeyPath("code") as? String
        availableLeave = dictionaryData.valueForKeyPath("available") as? Int
        availedLeave = dictionaryData.valueForKeyPath("availed") as? Int
        
    }
}


//MARK:- BPMApproval View Card Model

//THIS is a copy of leave card model

class BPMApproval {
    
    //Card Data Model
    var id: String?
    
    var isSystem: Bool = false

    //Card Type/Subtype
    var cardType  : CardType
    var cardSubtype : CardSubtype
    var titleString: String?
    var descriptionString: String?
    var isPublic: Bool = false
  
    //Card?
    
    var assignedTo : [User]?
    var subscribers : [User]?
    var attachments : [Attachment]?
    var comments: [Comment]?
    var likeCount : Int?
//    var likedBySelf : Bool = false
    var cardStatus : CardStatus = CardStatus.Open
    //read?
    var commonCardFields : CommonFields? // LastActivity
    
    var isDeleted: Bool = false
    var createdAt : NSDate?
    var updatedAt : NSDate?
    
    
    //Content
    var activationTime : NSDate?
    var completedByTime : NSDate?
    var createdTime : NSDate?
    var definitionId : String?
    var executionUrl : String?
    var contentId : String?
    var modelId : String?
    var contentName : String?
    var priority : BPMContentPriority?
    var contentDict : NSDictionary?
    
    //Process
    var processDefinitionId : String?
    var processInitiator : String?
    var processInstanceId : String?
    var processIsConditionalStart : String?
    var processModelId : String?
    var processName : String?
    var processStartDate : NSDate?
    var processStatus : BPMProcessStatus
    var processSubject : String?
    
    
    //status?
    var subject : String?
    var taskInitiator : String?
    var taskType : BMPTaskType// create a enum
    
    var createdBy : User?
    var updatedBy : User?
    
    
    
    //Card Template

    var defaultCardTemplate : CardTemplate = CardTemplate.BPM01Card
    var defaultCardActions : [CardAction]
    var defaultManualCardActionsStringArray : [String]
   
    
    
    //Private Enums
    enum CardTemplate: String {
        case BPM01Card = "bpmTask_card_001" // bpmTask_card_001
        init(value : String?){
            self =  CardTemplate(rawValue: value ?? "") ?? .BPM01Card
        }
    }
    
   
    
    
    //Card Rendering Model: Non-Optional
    var cardEnabledFields = [String]()
    var actionBarEnabled : Bool = true
    
    //Mandatory Field
    var isTitleEnabled : Bool = true
    var isDescriptionEnabled : Bool = true
    var isContentEnabled : Bool = true
    
    //Optional Field
    var isAvatarEnabled : Bool = false
    var islastActivityEnabled : Bool = false
    
    
    

    
    //Initialiser
    init(JSON: AnyObject) {
        
        id = JSON.valueForKeyPath("_id") as? String
        isSystem = (JSON.valueForKeyPath("system") as? String)?.boolValue ?? false
        cardType = CardType(value: JSON.valueForKeyPath("card.type") as? String)
        cardSubtype = CardSubtype(value: JSON.valueForKeyPath("card.subtype") as? String)
        titleString =  JSON.valueForKeyPath("title") as? String
        descriptionString = JSON.valueForKeyPath("description") as? String
        
        defaultCardTemplate = CardTemplate(value: Parser.fetchCardTemplate(forType: cardType, forSubtype: cardSubtype))
        defaultCardActions = Parser.fetchActions(forType: cardType ,forSubtype: cardSubtype, forCardStatus: cardStatus)
        cardEnabledFields = Parser.fetchEnabledFields(forType: cardType, forSubtype: cardSubtype)
        isPublic = (JSON.valueForKeyPath("public") as? String)?.boolValue ?? false
        
        //card?

        
        if let  unwrappedDictionaryArray = JSON.valueForKeyPath("assignedTo") as? [NSDictionary]{
            assignedTo = unwrappedDictionaryArray.flatMap{ User(dictionaryData: $0) }
        }
        if let  unwrappedDictionaryArray = JSON.valueForKeyPath("subscribers") as? [NSDictionary]{
            subscribers = unwrappedDictionaryArray.flatMap{ User(dictionaryData: $0) }
        }
        
        attachments = Parser.attachmentsFromDictionaryArray( JSON.valueForKeyPath("attachments") as? [NSDictionary])
        comments = Parser.commentsFromAnyObject(JSON.valueForKeyPath("comments"))
        likeCount = JSON.valueForKeyPath("likes") as? Int
        cardStatus = CardStatus(value: JSON.valueForKeyPath("status") as? String)
        //Read? - not used
        commonCardFields = CommonFields(JSON: JSON)
        isDeleted = (JSON.valueForKeyPath("delete") as? String)?.boolValue ?? false



        createdBy = User(dictionaryData: JSON.valueForKeyPath("createdBy") as? NSDictionary)
        updatedBy = User(dictionaryData: JSON.valueForKeyPath("updatedBy") as? NSDictionary)
        //something wrong here
        createdAt = Helper.dateForString(JSON.valueForKeyPath("createdAt") as? String)
        updatedAt = Helper.dateForString(JSON.valueForKeyPath("updatedAt") as? String)
        
        
        //Content
        if let unwrappedContentDict = JSON.valueForKeyPath("content") as? NSDictionary{
            contentDict = unwrappedContentDict
        }
        activationTime = Helper.dateForString(JSON.valueForKeyPath("content.activationTime") as? String)
        completedByTime = Helper.dateForString(JSON.valueForKeyPath("content.completedByTime") as? String)
        createdTime = Helper.dateForString(JSON.valueForKeyPath("content.createdTime") as? String)
        
        definitionId = JSON.valueForKeyPath("content.definitionId") as? String
        executionUrl = JSON.valueForKeyPath("content.executionUrl") as? String
        contentId = JSON.valueForKeyPath("content.id") as? String
        modelId = JSON.valueForKeyPath("content.modelId") as? String
        contentName = JSON.valueForKeyPath("content.name") as? String
        priority = BPMContentPriority(value: JSON.valueForKeyPath("content.priority") as? String)
        processDefinitionId = JSON.valueForKeyPath("content.processDefinitionId") as? String
        processInitiator = JSON.valueForKeyPath("content.processInitiator") as? String
        processInstanceId = JSON.valueForKeyPath("content.processInstanceId") as? String
        processIsConditionalStart = JSON.valueForKeyPath("content.processIsConditionalStart") as? String
        processModelId = JSON.valueForKeyPath("content.processModelId") as? String
        processName = JSON.valueForKeyPath("content.processName") as? String
        processStartDate = Helper.dateForString(JSON.valueForKeyPath("content.processStartDate") as? String)
        processStatus = BPMProcessStatus(value: JSON.valueForKeyPath("content.processStatus") as? String)
        
            processSubject = JSON.valueForKeyPath("content.processSubject") as? String
        //Status? - not used
        subject = JSON.valueForKeyPath("content.subject") as? String
        taskInitiator = JSON.valueForKeyPath("content.taskInitiator") as? String
        taskType = BMPTaskType(value:JSON.valueForKeyPath("content.taskType") as? String)
        createdBy = User(dictionaryData: JSON.valueForKeyPath("createdBy") as? NSDictionary)
        updatedBy = User(dictionaryData: JSON.valueForKeyPath("updatedBy") as? NSDictionary)
        
        //Actions
        defaultManualCardActionsStringArray = ["APPROVE","REJECT","CLOSE_TASK"]
        defaultCardActions = defaultManualCardActionsStringArray.flatMap{ CardAction(value: $0 as? String) }

        
        //setting optional fields
         isAvatarEnabled  = cardEnabledFields.contains("avatar")
         islastActivityEnabled = cardEnabledFields.contains("lastActivity")
    }
    
}












