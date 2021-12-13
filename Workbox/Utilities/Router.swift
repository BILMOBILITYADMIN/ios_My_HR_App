//
//  Router.swift
//  Workbox
//
//  Created by Ratan D K on 23/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    static let baseURLString = ConstantServer.qaURL  // qaprodurl
    
    case ConfigureURL(urlString: String) //No statusCode
    case LoginUser(username: String, password: String)
    case GetConfiguration(email: String) //No statusCode
    case Logout
    case RegisterDevice(deviceId: String, deviceToken: String)
    case ForgotPassword(email: String)
    case GetUserProfile(userId: String) // Status Code
    case UpdateUserProfile(userId: String ,profileDict: Dictionary<String, AnyObject>)
    case GetWorkitems(limit : Int,skip : Int, filter: String?)
    case SearchUser(text: String)
    case GetGroups()
    case GetGroupDetail(groupID: String)
    case GetWorkitemDetail(id : String)
    case DeleteWorkitem(id : String)
    case DeleteComment(workitemId : String, commentId : String)
    case ShareWorkitem(id : String,shareDict : Dictionary<String, AnyObject>)
    case CommentOnWorkitem(id : String, commentText : String, attachments : [NSDictionary])
    case Like(workitemId : String)
    case UnLike(workitemId : String)
    case FilterForTimesheetWeek()
    case GetTimesheetForWeek(date : String?)
    case GetTSTasks(date:String?)
    case SaveTS(timesheetDict:Dictionary<String, AnyObject>)
    case SubmitTS(timesheetDict:Dictionary<String, AnyObject>, isSave: Bool)
    case Approve(workitemId : String)
    case Reject(workitemId : String, reason : String)
    case ApproveAll(workitemIdArray: [String])
    case CreateFeedTask(type : CardType, system : Bool, title : String, description : String, isPublic : Bool, cardType : CardType, cardSubtype: CardSubtype, groups: [String], users : [String], files: [NSDictionary])
    case NotificationFetch()
    case NotificationRead(id: String)
    case TeamCalendar(from : String, to : String, fromSession: Int, toSession : Int)
    case BadgeCount()
    case GetSubscription()
    case UpdateSubscription(subscriptionDict: Dictionary<String, AnyObject>)
    case ActivityLog(startDate : String, endDate: String)
    
    //Task Actions
    case CloseTask(workitemId : String)
    case CompleteTask(workitemId : String)
    case DelegateTask(workitemId : String, userEmailArray : [String])
    case HoldTask(workitemId : String)
    case WithdrawTask(workitemId : String)
    case ReopenTask(workitemId:String)
    case GroupAddUsers(groupId:String,usersDictionary:Dictionary<String, AnyObject>)
    case GroupCreation(groupDictionary:Dictionary<String, AnyObject>)
    case GroupUpdate(groupId:String,groupDictionary:Dictionary<String, AnyObject>)
    case GroupRemoveUsers(groupId:String,usersIdArrayString:String)
    case AddCollaborator(workItemId:String,userIdsArray:[String])
    case DeleteCollaborator(workItemId:String,userIdsArray:String)
    case DeleteGroup(groupId:String)
    case GetGamifyUser()
    
    //BMP Task
    case GetBPMTask()
    case GetBMPTaskDetail(contentId : String)
    case ApproveBMPTask(contentId : String,actionType:Bool)//true- approve & false - reject
    case DelegateBMPTask(contentId : String)
    
    var method: Alamofire.Method {
        switch self {
        case .LoginUser, .ForgotPassword, .RegisterDevice, .Logout, .CommentOnWorkitem, .Like, .ShareWorkitem, .SaveTS, .SubmitTS,.Approve, .Reject, .ApproveAll, .CreateFeedTask, .GroupAddUsers, .GroupCreation, .ApproveBMPTask,.DelegateBMPTask:
            return .POST
        case .UpdateUserProfile, .NotificationRead, .CloseTask, .CompleteTask, .DelegateTask, .HoldTask, .WithdrawTask, .GroupUpdate, .AddCollaborator,.ReopenTask,.UpdateSubscription(_):
            return .PUT
        case .UnLike, .GroupRemoveUsers,.DeleteCollaborator,.DeleteWorkitem, .DeleteComment, .DeleteGroup:
            return .DELETE
        default:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .ConfigureURL(let urlString):
            return "configuration?email=\(urlString)"
        case .LoginUser:
            return "login"
        case .GetConfiguration(let email):
            return "api/v1/configuration?email=\(email)"
        case .Logout:
            return "api/v1/logout"
        case .RegisterDevice:
            return "api/v1/device"
        case .ForgotPassword:
            return "forgotPassword"
        case .GetUserProfile(let userId):
            return "api/v1/user/\(userId)"
        case .UpdateUserProfile(let userId, _):
            return "api/v1/user/\(userId)"
            
        case .GetWorkitems(let limit,let skip, let filter):
            var urlString = "api/v1/workitems/?"
            if let filter = filter {
                urlString = urlString + "filter=\(filter)&&"
            }
            return "\(urlString)limit=\(limit)&&skip=\(skip)"
            
        case .SearchUser(_):
            return "api/v1/search/user"
        case .GetGroups:
            return "api/v1/groups"
        case .GetGroupDetail(let groupID):
            return "api/v1/groups/\(groupID)"
        case .GetWorkitemDetail(let id):
            return "api/v1/workitem/\(id)"
        case .CommentOnWorkitem(let id, _,_):
            return "api/v1/comment/workitem/\(id)"
        case .ShareWorkitem(let id,_):
            return "api/v1/share/workitem/\(id)"
        case .Like(let workitemId):
            return "api/v1/like/workitem/\(workitemId)"
        case .UnLike(let workitemId):
            return "api/v1/like/workitem/\(workitemId)"
        case .FilterForTimesheetWeek() :
            return "api/v1/timesheet/weeks"
            
        case .GetTimesheetForWeek(let date):
            if let dateValue = date{
                return  "api/v1/timesheet?startDate=\(dateValue)"
            }
            else{
                return "api/v1/timesheet"
            }
            
        case .GetTSTasks(let date):
            if let dateValue = date{
            return "api/v1/timesheet/tasks?date=\(dateValue)"
            }
            else{
                return "api/v1/timesheet/tasks"
            }
            
        case .SaveTS:
            return "api/v1/timesheet/save"
            
        case .SubmitTS(_, let isSave):
            if isSave {
                return "api/v1/timesheet/save"
            }
            else {
                return "api/v1/timesheet/submit"
            }
            
        case .Approve(let workitemId):
            return "api/v1/approve/approvals/\(workitemId)"
        case .Reject(let workitemId,_):
            return "api/v1/reject/approvals/\(workitemId)"
        case .ApproveAll(_):
            return "api/v1/approve/approvals/"
        case .CreateFeedTask(_,_,_,_,_,_,_,_,_,_):
            return "api/v1/workitems"
        case .NotificationFetch():
            return "api/v1/notifications"
        case .NotificationRead(let NotificationId):
            return "api/v1/notifications/read/\(NotificationId)"
            
            //Task Actions
        case .CloseTask(let workitemId):
            return "api/v1/close/workitem/\(workitemId)"
        case .CompleteTask(let workitemId):
            return "api/v1/approve/workitem/\(workitemId)"
        case .DelegateTask(let workitemId, _):
            return "api/v1/delegate/workitem/\(workitemId)"
        case .ReopenTask(let workitemId):
            return "api/v1/reopen/workitem/\(workitemId)"
        case .HoldTask(let workitemId):
            return "api/v1/hold/workitem/\(workitemId)"
        case .WithdrawTask(let workitemId):
            return "api/v1/withdraw/workitem/\(workitemId)"
            
        case .GroupAddUsers(let groupId,_):
            return "api/v1/groups/\(groupId)/users"
        case .GroupCreation(_):
            return "api/v1/groups/"
        case .GroupUpdate(let groupId,_):
            return "api/v1/groups/\(groupId)"
        case .GroupRemoveUsers(let groupId,let userIdArrayString):
            return "api/v1/groups/\(groupId)/users?users=\(userIdArrayString)"
        case .AddCollaborator(let workItemId,_):
            return "api/v1/workitems/\(workItemId)/collaborators"
        case .DeleteCollaborator(let workItemId,let userIdArrayString):
                return "api/v1/workitems/\(workItemId)/collaborators?collaborators=\(userIdArrayString)"
        case .DeleteWorkitem(let workitemId):
            return "api/v1/workitem/\(workitemId)"
        case .DeleteComment(let workitemId,_):
            return "api/v1/comment/workitem/\(workitemId)"
        case .DeleteGroup(let groupId):
            return "api/v1/groups/\(groupId)"
        case .TeamCalendar(_,_,_,_):
            return "api/v1/leave/teamCalendar"
        case .BadgeCount:
            return "api/v1/notifications/count"
        case .GetSubscription:
            return "api/v1/subscriptions"
        case .UpdateSubscription(_):
            return "api/v1/subscriptions"
            
        case .GetGamifyUser():
            return "api/v1/leaderboard"
        case .ActivityLog(let startDate, let endDate):
            return "api/v1/activities?startDate=\(startDate)&endDate=\(endDate)"
        case .GetBPMTask():
            return "api/v1/bpmTasks"
        case .GetBMPTaskDetail(let contentId):
            return "api/v1/bpmTasks/\(contentId)"
        case .ApproveBMPTask(let contentId,_):
            print("/api/v1/bpmTasks/complete/\(contentId)")
            
            return "api/v1/bpmTasks/complete/\(contentId)"
        case .DelegateBMPTask(let contentId):
            return "api/v1/bpmTasks/delegate/\(contentId)"
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        guard let URL = NSURL(string: Router.baseURLString) else{
            print("DEADLY ERROR : URL CREATION FAILED")
            return NSMutableURLRequest()

        }
        
        guard let url = NSURL(string: "\(path)", relativeToURL:URL) else{
            print("DEADLY ERROR : PATH CREATION FAILED")
            return NSMutableURLRequest()
        }
        
        let mutableURLRequest = NSMutableURLRequest(URL: url)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        // HTTP Headers
        mutableURLRequest.setValue(UserDefaults.deviceId(), forHTTPHeaderField: "x-device-id")
        mutableURLRequest.setValue("ios", forHTTPHeaderField: "x-device-type")
        
        if let deviceToken = UserDefaults.deviceToken() {
            mutableURLRequest.setValue(deviceToken, forHTTPHeaderField: "x-device-token")
        }
        
        if let accessToken = UserDefaults.accessToken() {
            mutableURLRequest.setValue(accessToken, forHTTPHeaderField: "x-access-token")
        }
        if let email = UserDefaults.loggedInEmail() {
            mutableURLRequest.setValue(email, forHTTPHeaderField: "x-email-id")
        }
        
        if let userID = UserDefaults.userId(){
            mutableURLRequest.setValue(userID, forHTTPHeaderField: "userId")
        }
//        if let role = UserDefaults.userRole(){
//             mutableURLRequest.setValue(role, forHTTPHeaderField: "role")
//        }
        
        
        switch self {
            
        case .LoginUser(let username, let password):
            let parameters = ["email": username, "password": password]
            print(mutableURLRequest)
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
            
            
        case .RegisterDevice(let deviceId, let deviceToken):
            let parameters = ["id": deviceId, "token": deviceToken]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
            
        case .ForgotPassword(let email):
            let parameters = ["email": email]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
            
        case .SearchUser(let text):
            let parameters = ["text": text]
            return Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest, parameters: parameters).0
            
        case .UpdateUserProfile(_, let profileDict):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: profileDict).0
            
        case .CommentOnWorkitem(_,let commentText, let attachments):
            let parameters : Dictionary<String,AnyObject>  = Dictionary(dictionaryLiteral: ("text", commentText),("files",attachments))
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters ).0
            
        case .ShareWorkitem(_,let shareDict):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: shareDict).0
            
        case .SaveTS(let timesheetDict):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: timesheetDict).0
        
        case .SubmitTS(let timesheetDict, _):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: timesheetDict).0
            
        case .Reject(_,let reason):
            let parameters = ["reason" : reason]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
            
        case .ApproveAll(let workitemIdArray):
            let parameter = ["id" : workitemIdArray]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameter).0
      
        case .CreateFeedTask(let workItemType, let systemType, let title, let description, let isPublic, let cardType, let cardSubtype, let groups, let users, let files):
            var parameters = Dictionary<String,AnyObject>()
            parameters = ["type": workItemType.rawValue, "system": systemType, "title": title, "description": description, "public": isPublic, "cardType": cardType.rawValue, "cardSubtype": cardSubtype.rawValue, "groups": groups, "users": users, "files": files]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0

        case .DeleteComment(_, let commentId):
            let parameters = ["commentId" : commentId]
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
   
        case .DelegateTask(_, let userEmailArray):
            let parameter = ["users" : userEmailArray]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameter).0
            
        case .GroupAddUsers(_,let userDict):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: userDict).0
            
        case .GroupCreation(let groupDict):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: groupDict).0
            
        case .GroupUpdate(_, let groupDict):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: groupDict).0
            
        case .AddCollaborator(_,let userIdsArray):
            let parameter = ["userId" : userIdsArray]
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameter).0
            
        case .TeamCalendar(let fromDate, let toDate, let fromSession, let toSession):
            var parameters = Dictionary<String,AnyObject>()
            parameters = ["from" : fromDate, "to": toDate, "fromSession" : fromSession, "toSession": toSession]
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            
        case .BadgeCount():
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0
            
        case .GetSubscription():
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest,parameters: nil).0
            
        case .UpdateSubscription(let subscriptionDict):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: subscriptionDict).0
            
        case .ApproveBMPTask(_,let actionType):
            let parameter = ["approved": actionType]
            print(parameter)
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameter).0

        default:
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0
        }
    }
}

