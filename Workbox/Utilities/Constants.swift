//
//  Constants.h
//  Workbox
//
//  Created by Ratan D K on 07/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import Foundation
import UIKit

let kEmptyString: String = ""
let kServerKeyStatus: String = "status"
let kServerKeyMessage: String = "message"
let kServerKeyFailure: String = "failure"
let kServerKeySuccess: String = "success"
let kServerKeyData: String = "data"
let kLoadingCellTag = 121212  //Any Integer Value
let kSpaceString = "\u{200c}"
let kUpdateURL: String = "http://myhr.britindia.com/store/files/brit_PMS.ipa"
let systemURL = "http://hrapps.britindia.com/" //QA
//let systemURL = "http://myhr.britindia.com/" // Prod
//let systemURL = "http://dev.cherrywork.in:7014/" //Dev
//let systemURL = "http://dev.cherrywork.in:7023/" // Dev again :P


// prod "http://hrapps.britindia.com/"



struct ConstantServer {
    static var apiURL = "http://dev.cherrywork.in:4002/"//Dev
    static var stagingURL = "http://52.39.185.168:4001/"// Staging Dev 2
    static var qaURL = "http://hrapps.britindia.com/platform/"//QA
    static var prodURL = "http://myhr.britindia.com/api/"//prod
    static var devURL = "http://dev.cherrywork.in:4013/" // Dev 3
    static let x_APIKey = "API-20140922"
    static var cdnURL = "http://d1sqfcb5cb617.cloudfront.net/images/"
    static var vpnURL = "http://125.16.214.229:4002/"
    static var localURL = "http://192.168.1.158:4005/"
//    static var imageRelativeUrl = "http://hrapps.britindia.com/platform"
    static var imageRelativeUrl = "http://myhr.britindia.com/api"
    //static var imageRelativeUrl = "http://dev.cherrywork.in:4002"
}
enum ImageSizeConstant : String {
    case Thumbnail = "thumbnail"
    case Large = "large"
    case Medium = "medium"
}


public enum ErrorCode : Int {
    case Forbidden = 403
    case PageNotFound = 404
    case SimulatorError = 3010
}

struct ConstantUI {
    static let defaultPadding : CGFloat = 8.0
    static let defaultPaddingByTwo : CGFloat = 4.0
    static let screenWidth = UIScreen.mainScreen().bounds.width
    static let cardWidth = screenWidth - CGFloat(2*16)
    static let actionViewHeight : CGFloat = 38
    static let commentViewHeight : CGFloat = 48
    static let userProfileWidth : CGFloat = 50
    
    
    
    
}


struct ConstantDate {
    static let tzDateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
    static let ddmmyyyyFormat = "ddMMyyyy"
    static let MMMyyyyFormat = "MMMyyyy"
    static let utcTimeZone = "UTC"
    static let dMMMM = "d MMM"
    static let dMMMMyyyy = "d MMM, yyyy"
    static let hma = "h:m a"
    
}

struct ConstantIdentifier {
    struct Segue {
        static let cardToDetail = "CardToDetail"
    }
}

struct ConstantColor {
    static let CWBlue = UIColor(red: 0/255.0, green: 132/255.0, blue: 255/255.0, alpha: 1.0)
    static let CWOrange = UIColor(red: 255/255.0, green: 165/255.0, blue: 0/255.0, alpha: 1.0)
    static let CWGreen = UIColor(red: 32/255.0, green: 169/255.0, blue: 117/255.0, alpha: 1.0)
    static let CWYellow = UIColor(red: 255/255.0, green: 211/255.0, blue: 92/255.0, alpha: 1.0)
    static let CWRed = UIColor(red: 212/255.0, green: 73/255.0, blue: 66/255.0, alpha: 1.0)
    static let CWButtonGray = UIColor.grayColor()
    static let CWLightGray = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)
    static let CWBlackWithAlpa = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    // static let CWBlackWithAlpa = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    
    
}

//MARK: - ENUM of Assets
// Declare enum for required images here and there will be no any dependency on string named UIImage.
// Usages: imageview.image = AssetImage.ProfileImage.image
public enum AssetImage : String {
    case RoundedCornerShadow = "card background"
    case ConfigureButton = "configureButton"
    case ProfileImage = "ProfileImage"
    case Slice1 = "slice1"
    case Slice2 = "slice2"
    case Slice3 = "slice3"
    case PlaceholderIcon = "fav"
    case InsertPhoto = "InsertPhoto"
    case Cherries = "cherry"
    case uncheck = "Unchecked_checkBox"
    case check = "Checked_checkBox"
    case clock = "clock"
    case approveAll = "approveAll"
    case completedTasks = "completedtasks"
    case copyDay = "copyDay"
    case copyAll = "copyAll"
    case info = "info"
    case resetAll = "reset"
    case sentTasks = "senttasks"
    case tasks = "tasks"
    case arrow = "arrow"
    case cross = "cross"
    case send = "send"
    case settings = "settingsIcon"
    case sideNav = "sideNav"
    case attach = "attach"
    case attachment = "attachment"
    case edit = "edit"
    case email = "email"
    case location = "location"
    case maritalstatus = "marital"
    case phone = "phone"
    case back = "profileBack"
    case backArrow = "back"
    case placeholderProfileIcon = "profile_icon"
    case call = "call"
    case hangout = "hangouts"
    case sms = "sms"
    case emailWhite = "email-1"
    case tickMark = "tickmark"
    case people = "people"
    case notification = "notification"
    case gradient = "grad"
    case subscriber = "subscriber"
    case GroupIcon = "groups_icon"
    case calendarMonth = "month"
    case calendarDaily = "daily"
    case calendarWeek = "week"
    case performance = "performance"
    
}

public enum InboxFilter : String {
    case Timesheet = "timesheet"
    case Leave = "leave"
}


//MARK:- Other Enum
public enum WorkitemType : String {
    case Generic
    case Leave
    case POPR
    
}

public enum TabID : String {
    case Inbox = "INBOX"
    case Reports = "REPORTS"
    case Cherries = "CHERRIES"
}

public enum TabIndex : Int {
    case Inbox = 0
    case Reports = 1
    case Cherries = 2
}

public enum GroupType : String{
    case System = "system"
    case Custom = "custom"
}

public enum Perspective {
    case List
    case Card
    case People
}

public enum GestureType {
    case Tap
    case LongPress
}


//TODO: Name Cardtype based on backend Response
enum CardType : String {
    
    case TaskType = "task"
    case FeedType = "feeds"
    case TimesheetType = "Timesheet"
    case LeaveType = "Leave"
    case Gamify = "Gamify"
    case Performance = "Performance Management System"
    case CSC = "Champion score card"
    case LMS = "Learning management system"
    case All = "All"
    case CurriculumApprovalTemplate = "Curriculum Approval Template"
    case Recruitment = "Recruitment"
    
    case UnknownType
    
    init(value : String?){
        if let unwrappedValue = value{
            if let unwrappedType = CardType(rawValue: unwrappedValue){
                self = unwrappedType
            }
            else{
                self = .UnknownType
            }
        }
        else{
            self = .UnknownType
        }
    }
    
}


enum CardSubtype : String{
    //Feed
    case UserMessageType = "usermessage"
    case NewJoineeType = "newjoinee"
    case NewsFeedType = "news"
    case Approve = "Approve"
    case PlanningType = "planning"
    case VisitPlanType = "visit_plan"
    case HolidayCalenderType = "Holiday Calendar"
    case LeaveHistoryType = "Leave History"
    case ApplyLeaveType = "Apply Leave"
    case TasksType = "Tasks"
    case Leaderboard = "Leaderboard"
    case PMSApproval = "Appraisal Template Approve"
    case CurriculumApprovalTemplate = "Curriculum Approval Template"
    
    
    //Recruitment
    case requisition = "requisition"
    case jobApplicationException = "jobApplicationException"
    case offerRollout = "offerRollout"
    case updateRequisition = "updateRequisition"
    //    case GenericFeedType = "genericFeed"
    
    
    //Task
    case ManualTaskType = "manualtask"
    case BPMTask = "BPM Task"
    
    //TimeSheet
    case AddTaskType = "Add Task"
    case CopyType = "Copy"
    case HomeType = "Home"
    case ApprovalDetailType = "Approvals Detail"
    
    case UnknownType
    
    init(value : String?){
        
        if let unwrappedSubtype = CardSubtype(rawValue: value ?? ""){
            self = unwrappedSubtype
        }
        else{
            self = .UnknownType
        }
    }
    
    
}

enum CardStatus : String{
    
    case Approved = "approved"
    case Rejected = "rejected"
    
    case Open = "open"
    case Closed = "closed"
    case Withdrawn = "withdrawn" // backend not sending these status
    case Onhold = "on-hold" // backend not sending these status
    case Completed = "completed"
    case Submitted = "submitted"
    case Unknown
    
    init(value : String?){
        
        if let unwrappedStatus = CardStatus(rawValue: value ?? ""){
            self = unwrappedStatus
        }
        else{
            self = .Unknown
        }
    }
    
    var labelText: String{
        switch self {
        default :
            return String(self).uppercaseString
        }
    }
    
    var disabledActions: [CardAction]{
        switch self {
        case .Open:
            return [CardAction.Attach]
        case .Closed:
            return [CardAction.Attach, CardAction.CloseTask ]
        case .Approved, .Rejected:
            return [CardAction.Attach, CardAction.Approve, CardAction.Reject]
        default:
            return [CardAction.Attach]
        }
    }
    
    var labelColor: UIColor{
        switch self {
        case .Open:
            return  ConstantColor.CWYellow
        case .Closed:
            return ConstantColor.CWBlue
        case .Approved:
            return ConstantColor.CWGreen
        case .Rejected:
            return ConstantColor.CWRed
        case .Onhold:
            return  ConstantColor.CWYellow
        case .Completed:
            return  ConstantColor.CWGreen
        case .Withdrawn:
            return  ConstantColor.CWRed
        case .Submitted:
            return ConstantColor.CWYellow
            
        default:
            return ConstantColor.CWBlue
        }
    }
    
    var enabledActionsForAssigner : [CardAction]{
        switch self{
        case .Open:
            return [CardAction.WithdrawTask,CardAction.CloseTask,CardAction.Comment]
        case .Completed:
            return [CardAction.CloseTask,CardAction.ReopenTask,CardAction.Comment]
        case .Withdrawn:
            return [CardAction.CloseTask,CardAction.Comment]
        default :
            return [CardAction.Comment]
        }
    }
    
    var enabledActionsForAssignee : [CardAction]{
        switch self{
        case .Open:
            return [CardAction.CompleteTask,CardAction.HoldTask,CardAction.DelegateTask,CardAction.Comment]
        case .Onhold:
            return [CardAction.CompleteTask,CardAction.DelegateTask,CardAction.Comment]
        default :
            return [CardAction.Comment]
        }
    }
    var enabledActionsForWatcher : [CardAction]{
        switch self{
        default:
            return [CardAction.Comment]
        }
    }
}

// BPM task approval card

enum BPMContentPriority : String{
    
    case Low = "Low"
    case Medium = "MEDIUM"
    case High = "HIGH"
    case Unknown
    
    init(value : String?){
        
        if let unwrappedPriority = BPMContentPriority(rawValue: value ?? ""){
            self = unwrappedPriority
        }
        else{
            self = .Unknown
        }
    }
}

enum BPMProcessStatus : String{
    case InProgress = "IN_PROGRESS"
    case  Unknown
    init(value : String?){
        
        if let unwrappedProcessStatus = BPMProcessStatus(rawValue: value ?? ""){
            self = unwrappedProcessStatus
        }
        else{
            self = .Unknown
        }
    }
}

enum BMPTaskType : String{
    case Task = "TASK"
    case Unknown
    init(value : String?){
        
        if let unwrappedTaskType = BMPTaskType(rawValue: value ?? ""){
            self = unwrappedTaskType
        }
        else{
            self = .Unknown
        }
    }
    
}


public enum AttachmentType {
    case ImageType
    case UnknownType
    
    init(value: String?) {
        if let unwrappedValue = value{
            switch(unwrappedValue){
            case "image":
                self = .ImageType
            default:
                self = .UnknownType
            }
        }
        else{
            self = .UnknownType
        }
    }
}

//public enum ImageSize : String {
//    case Thumbnail = "thumbnail"
//    case Medium = "medium"
//    case Large = "large"
//}

public enum Visibility {
    case Private
    case Public
    case Unknown
    
    init?(value: Int?) {
        if let nonOptionalValue = value{
            switch(nonOptionalValue){
            case 0:
                self = .Private
            case 1:
                self = .Public
            default:
                self = .Unknown
            }
        }
        else{
            return nil
        }
    }
}

public enum TSStatus:String{
    case Approved
    case Rejected
    case Prefilled
    case Saved
    case Submitted
    case Unknown
    
    init?(value: String?){
        switch(value ?? ""){
        case "approved":
            self = .Approved
        case "rejected":
            self = .Rejected
        case "prefilled":
            self = .Prefilled
        case "saved":
            self = .Saved
        case "submitted":
            self = .Submitted
        default :
            self = .Unknown
            
        }
    }
}

public enum TagColor {
    case Red, Orange, Yellow, Green, Blue
    
    func toUIColor() -> UIColor {
        switch self {
        case .Red:
            return UIColor(red: 179, green: 47, blue: 60, alpha: 1)
        case .Orange:
            return UIColor(red: 248, green: 148, blue: 29, alpha: 1)
        case .Yellow:
            return UIColor(red: 231, green: 217, blue: 54, alpha: 1)
        case .Green:
            return UIColor(red: 57, green: 181, blue: 74, alpha: 1)
        case .Blue:
            return UIColor(red: 0, green: 114, blue: 188, alpha: 1)
        }
    }
}

public enum CherryName: String {
    case Timehsheet = "Timesheet"
    case Leave = "Leave"
    case Travel = "Travel"
    case Gamify  = "Gamify"
    case Calendar = "Calendar"
    case Performance = "Performance Management System"
}

public enum LeaveStatus : String {
    case Approved
    case Rejected
    case Pending
    case Unknown
    
    init?(value: String?){
        switch(value ?? ""){
        case "approved":
            self = .Approved
        case "rejected":
            self = .Rejected
        case "pending":
            self = .Pending
            
        default :
            self = .Unknown
            
        }
    }
}

public enum userPermission: String {
    case All = "all"
    case None = "none"
    case oneSelf = "self"
}

//Usage:- TagColor.Blue.toUIColor()
