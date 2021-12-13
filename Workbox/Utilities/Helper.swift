//
//  Helper.swift
//  Workbox
//
//  Created by Ratan D K on 07/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import UIKit
import CoreData
import ReachabilitySwift

class Helper {
    
    class func clearAllCookies() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = storage.cookies
        for cookie in cookies! {
            storage.deleteCookie(cookie)
        }
    }
    
    class func urlEncode(string: String) -> String {
        let encodedURL = string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        return encodedURL
    }
    
   class func isConnectedToInternet() -> Bool{
        let reachability = try! Reachability.reachabilityForInternetConnection()
        if reachability.currentReachabilityStatus == .NotReachable {
            print("not connected")
            return false
        } else {
            print("connected")
            return true
        }
    }
    
    class func base64ForImage(image: UIImage) -> String? {
        guard let imageData = UIImagePNGRepresentation(image) else{
            return nil
        }
        return imageData.base64EncodedStringWithOptions([])
    }
    
    
    
    class func dateForString(dateString: String?) -> NSDate? {
        guard let unwrappedDateString = dateString where unwrappedDateString.characters.count > 0 else{
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: ConstantDate.utcTimeZone)
        dateFormatter.dateFormat = ConstantDate.tzDateFormat
        let date = dateFormatter.dateFromString(unwrappedDateString)
        return date;
        
    }
    
    class func dateForDDMMYYYYString(dateString: String?) -> NSDate? {
        guard let unwrappedDateString = dateString where unwrappedDateString.characters.count > 0 else{
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: ConstantDate.utcTimeZone)
        dateFormatter.dateFormat = ConstantDate.ddmmyyyyFormat
        let date = dateFormatter.dateFromString(unwrappedDateString)
        return date
    }
    
    class func dateForMMYYYYString(dateString: String?) -> NSDate? {
        guard let unwrappedDateString = dateString where unwrappedDateString.characters.count > 0 else{
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: ConstantDate.utcTimeZone)
        dateFormatter.dateFormat = ConstantDate.MMMyyyyFormat
        let date = dateFormatter.dateFromString(unwrappedDateString)
        return date;
        
    }
    
    class func stringForDate(date:NSDate?, format:String) -> String {
        
        guard let date = date else {
            return kEmptyString
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: ConstantDate.utcTimeZone)
        dateFormatter.dateFormat = format
        let dateString = dateFormatter.stringFromDate(date)
        return dateString;
    }
    
    class func stringForDateWithYearCorrection(date:NSDate?) -> String {
        
        
        guard let unwrappedDate = date else {
            return kEmptyString
        }
        let calander = NSCalendar.currentCalendar()
        let dateYear = calander.components([.Day , .Month , .Year], fromDate: unwrappedDate).year
        let currentYear =  calander.components([.Day , .Month , .Year], fromDate: NSDate()).year
        
        if dateYear == currentYear{
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(abbreviation: ConstantDate.utcTimeZone)
            dateFormatter.dateFormat = ConstantDate.dMMMM
            let dateString = dateFormatter.stringFromDate(unwrappedDate)
            return dateString;
        
        }else{
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(abbreviation: ConstantDate.utcTimeZone)
            dateFormatter.dateFormat = ConstantDate.dMMMMyyyy
            let dateString = dateFormatter.stringFromDate(unwrappedDate)
            return dateString;
        }
    }
    
    
    class func stringForDateWithYearCorrectionIncludingDayOfWeek(date:NSDate?) -> String {
        
        
        guard let unwrappedDate = date else {
            return kEmptyString
        }
        let calander = NSCalendar.currentCalendar()
        let dateYear = calander.components([.Day , .Month , .Year], fromDate: unwrappedDate).year
        let currentYear =  calander.components([.Day , .Month , .Year], fromDate: NSDate()).year
        
        if dateYear == currentYear{
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(abbreviation: ConstantDate.utcTimeZone)
            dateFormatter.dateFormat = "E, MMM d"
            let dateString = dateFormatter.stringFromDate(unwrappedDate)
            return dateString;
            
        }else{
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(abbreviation: ConstantDate.utcTimeZone)
            dateFormatter.dateFormat = "E, MMM d yyyy"
            let dateString = dateFormatter.stringFromDate(unwrappedDate)
            return dateString;
        }
    }
    
    class func stringFromDateInHumanReadableFormat(date: NSDate?, dateStype : NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String? {
        guard let unwrappedDate = date else{
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = dateStype
        dateFormatter.timeStyle = timeStyle
        dateFormatter.doesRelativeDateFormatting = true
        let dateString = dateFormatter.stringFromDate(unwrappedDate)
        return dateString
    }
    
    class func isValidEmail(string:String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(string)
    }
    
    class func nsurlFromString(urlString: String?) -> NSURL? {
        guard let unwrappedUrlString = urlString where unwrappedUrlString.characters.count > 0 else{
            return nil
        }
        let url = NSURL(string: "\(ConstantServer.cdnURL)\(unwrappedUrlString)")
        //        print(url)
        return url;
    }
    
    class func nsurlFromStringWithImageSize(urlString: String?, imageSize : ImageSizeConstant ) -> NSURL? {
        guard let unwrappedUrlString = urlString where unwrappedUrlString.characters.count > 0 else{
            return nil
        }
        let url = NSURL(string: "\(ConstantServer.cdnURL)\(imageSize.rawValue)/\(unwrappedUrlString)")
        //        print(url)
        return url;
    }
    
//    class func attachmentURL(size:String, imageName:String) -> NSURL! {
//        let urlString = "\(ConstantServer.cdnURL)\(size)\(imageName)";
//        return NSURL(string: urlString)
//    }
    
    class func lengthOfStringWithoutSpace(string:String?) -> Int {
        guard let text = string else {
            return 0
        }
        
        let trimmedText = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return trimmedText.characters.count
    }
    class func likeCommentAttachmentString(numberOfLikes : Int?, numberOfComments : Int?, likesEnabled : Bool, commentEnabled : Bool , numberOfAttachments : Int?, attachmentCountEnabled : Bool) -> String {
        var finalString = ""
        if (likesEnabled){
            let unwrappedLikes = numberOfLikes ?? 0
            switch unwrappedLikes {
            case 0:
                finalString = finalString + ""
            case 1:
                finalString = finalString +  "\(unwrappedLikes) Like   "
            default:
                finalString = finalString + "\(unwrappedLikes) Likes   "
            }
        }
            
            //        case .Comment:
        if(commentEnabled){
            let unwrappedComments = numberOfComments ?? 0
            switch unwrappedComments {
            case 0:
                finalString = finalString + ""
            case 1:
                finalString = finalString +   "\(unwrappedComments) Comment   "
            default:
                finalString = finalString +  "\(unwrappedComments) Comments   "
            }
        }
            //        case .Attachment:
        if(attachmentCountEnabled){
            let unwrappedAttachments = numberOfAttachments ?? 0
            switch unwrappedAttachments {
            case 0:
                finalString = finalString + ""
            case 1:
                finalString = finalString +   "\(unwrappedAttachments) Attachment   "
            default:
                finalString = finalString +   "\(unwrappedAttachments) Attachments   "
            }
        }
        return finalString
        
    }
    
    class func timeInHMformatForMinutes(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h" + " \(mins)m"
    }
   
    
//    class func timeAgoSinceDate(date: NSDate, numericDates: Bool) -> String {
//        let calendar = NSCalendar.currentCalendar()
//        let now = NSDate()
//        let earliest = now.earlierDate(date)
//        let latest = (earliest == now) ? date : now
//        let components:NSDateComponents = calendar.components([NSCalendarUnit.Minute , NSCalendarUnit.Hour , NSCalendarUnit.Day , NSCalendarUnit.WeekOfYear , NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Second], fromDate: earliest, toDate: latest, options: NSCalendarOptions())
//        
//        if (components.year >= 2) {
//            return "\(components.year) years ago"
//        } else if (components.year >= 1){
//            if (numericDates){
//                return "1 year ago"
//            } else {
//                return "Last year"
//            }
//        } else if (components.month >= 2) {
//            return "\(components.month) months ago"
//        } else if (components.month >= 1){
//            if (numericDates){
//                return "1 month ago"
//            } else {
//                return "Last month"
//            }
//        } else if (components.weekOfYear >= 2) {
//            return "\(components.weekOfYear) weeks ago"
//        } else if (components.weekOfYear >= 1){
//            if (numericDates){
//                return "1 week ago"
//            } else {
//                return "Last week"
//            }
//        } else if (components.day >= 2) {
//            return "\(components.day) days ago"
//        } else if (components.day >= 1){
//            if (numericDates){
//                return "1 day ago"
//            } else {
//                return "Yesterday"
//            }
//        } else if (components.hour >= 2) {
//            return "\(components.hour) hours ago"
//        } else if (components.hour >= 1){
//            if (numericDates){
//                return "1 hour ago"
//            } else {
//                return "An hour ago"
//            }
//        } else if (components.minute >= 2) {
//            return "\(components.minute) minutes ago"
//        } else if (components.minute >= 1){
//            if (numericDates){
//                return "1 minute ago"
//            } else {
//                return "A minute ago"
//            }
//        } else if (components.second >= 3) {
//            return "\(components.second) seconds ago"
//        } else {
//            return "Just now"
//        }
//        
//    }
    
    class func getColor(status:TSStatus)->UIColor{
        switch (status.rawValue){
        case "Approved": return UIColor(red: 32/255.0, green: 169/255.0, blue: 117/255.0, alpha: 1.0)
        case "Rejected": return UIColor(red: 212/255.0, green: 73/255.0, blue: 66/255.0, alpha: 1.0)
        case "Submitted": return UIColor(red: 255/255.0, green: 211/255.0, blue: 92/255.0, alpha: 1.0)
        case "Prefilled": return UIColor(red: 255/255.0, green: 211/255.0, blue: 92/255.0, alpha: 1.0)
        case "Saved": return UIColor(red: 255/255.0, green: 211/255.0, blue: 92/255.0, alpha: 1.0)
        default:  return UIColor(red: 32/255.0, green: 169/255.0, blue: 117/255.0, alpha: 1.0) // Green By default
        }
        
    }
    
    class func getBoldAttributtedString(text1:String?,text2:String?,font:CGFloat) -> NSMutableAttributedString{
    
        let attributedString = NSMutableAttributedString(string: text1 ?? "", attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(font)])
        
        let tempStr = NSMutableAttributedString(string: " ")
        tempStr.appendAttributedString(NSMutableAttributedString(string: text2 ?? ""))
        attributedString.appendAttributedString(tempStr)
        
       return attributedString
    }
    
    
    class func insertSpace(string : NSMutableString) -> String {

        let str2: NSMutableString = NSMutableString()
        for i in 0..<string.length {
            let ch : NSString = string.substringWithRange(NSMakeRange(i, 1))
            if(ch .rangeOfCharacterFromSet(NSCharacterSet.uppercaseLetterCharacterSet()).location != NSNotFound) {
                str2 .appendString(" ")
            }
            str2 .appendString(ch as String)
        }
        return str2 as String
    }
    
    
    

    class func setBorderForButtons(button:UIButton,color:UIColor){
        button.backgroundColor = UIColor.whiteColor()
        button.titleLabel?.font = UIFont.systemFontOfSize(13)
        button.setTitleColor(color, forState: .Normal)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.layer.borderColor = color.CGColor
        button.layer.borderWidth = 1
    }
    

    class func layoutButtons(actionBarEnabled : Bool, actionView : UIView,  actionViewHeightConstraint : NSLayoutConstraint, actionViewInitialHeight : CGFloat, viewArray : [UIView]?, maximumNumberOfButtonsToShow : Int?) {
        
        var isTruncated : Bool = false
        actionView.hidden = false
        
        
        
        guard actionBarEnabled else{
            
            actionViewHeightConstraint.constant = 0
            
            //            actionView.hidden = true
            
            return
            
        }
        
        
        
        guard let unwrappedViewArray = viewArray else{
            
            actionViewHeightConstraint.constant = 0
            
            //            actionView.hidden = true
            
            return
            
        }
        
        var totalNumberOfElements : Int = unwrappedViewArray.count
        
        
        
        if let unwrappedMaxNumOfElementsToShow = maximumNumberOfButtonsToShow {
            
            if unwrappedViewArray.count > unwrappedMaxNumOfElementsToShow{
                
                totalNumberOfElements = unwrappedMaxNumOfElementsToShow
                
                isTruncated = true
                
            }
                
            else{
                
                totalNumberOfElements = unwrappedViewArray.count
                
                isTruncated = false
                
            }
            
        }
            
        else{
            
            totalNumberOfElements = unwrappedViewArray.count
            
            isTruncated = false
            
        }
        
        
        
        guard totalNumberOfElements > 0 else{
            
            actionViewHeightConstraint.constant = 0
            
            //            actionView.hidden = true
            
            
            
            return
            
        }
        
//        print("totalNumberOfElements \(totalNumberOfElements)")
        
        let numberOfActionButtons = totalNumberOfElements
        
        let padding : CGFloat = 8.0
        
        var numberOfRow = 0
        
        let mod = totalNumberOfElements % numberOfActionButtons
        
        let div = Int(totalNumberOfElements / numberOfActionButtons)
        
        
        
        if mod != 0{
            
            numberOfRow = div + 1
            
        }
            
        else{
            
            numberOfRow = div
            
        }
        
        
        
        for subView in actionView.subviews {
            
            subView.removeFromSuperview()
            
        }
        
        
        
        let actionViewWidthWithoutPaddings = actionView.bounds.width - (padding * CGFloat(numberOfActionButtons - 1))
        
        
        
        let widthOfEachView =  actionViewWidthWithoutPaddings / CGFloat(numberOfActionButtons)
        
        let heightOfEachView = actionViewInitialHeight
        
        
        
        let actionViewHeight = (heightOfEachView * CGFloat(numberOfRow)) + (padding * CGFloat(numberOfRow - 1))
        
        
        
        actionViewHeightConstraint.constant = actionViewHeight
        
        
        
        for i in 0..<totalNumberOfElements{
            
            let viewElement = UIView()
            
            
            let widthIndex = Int(i % numberOfActionButtons)
            
            let heightIndex = Int(i / numberOfActionButtons)
            
            
            
            let originXOfElement =    (CGFloat(widthIndex) * (widthOfEachView))
            
            let originYOfElement =   (CGFloat(heightIndex) * (padding + heightOfEachView))
            
            let left = (actionView.bounds.width - (2 * padding))
            let right = (CGFloat(totalNumberOfElements - 1) * padding)
            let buttonWidth = (left - right) / CGFloat(totalNumberOfElements)
            
            viewElement.frame = CGRectMake(originXOfElement ,originYOfElement , widthOfEachView, heightOfEachView)
            
            unwrappedViewArray[i].frame = CGRectMake(padding, padding, buttonWidth , viewElement.bounds.height - (2*padding))
            
            Helper.setBorderForButtons(unwrappedViewArray[i] as! UIButton, color: UIColor.navBarColor())
            
            viewElement.addSubview(unwrappedViewArray[i])
            
            actionView.addSubview(viewElement)
            
        }
        
        
        actionView.layoutIfNeeded()
    }
    
    class func clearDBForConfig() {
        deleteAllObjectsFromEntity(String(Cherry))
        deleteAllObjectsFromEntity(String(Filter))
        deleteAllObjectsFromEntity(String(Menu))
        deleteAllObjectsFromEntity(String(SubMenu))
        deleteAllObjectsFromEntity(String(Tab))
        deleteAllObjectsFromEntity(String(CardConfig))
    }
    
    class func clearAllDB() {
        clearDBForConfig()
        deleteAllObjectsFromEntity(String(Workitem))
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        do {
            try appDelegate.managedObjectContext.save()
            UserDefaults.setIsConfigurationDownloaded(true)
        } catch let error {
            print("Coredata error: \(error)")
        }
    }
  
    class func deleteAllObjectsFromEntity(entityName: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest = NSFetchRequest.init(entityName: entityName)
        
        var allObjects: [AnyObject]
        do {
            allObjects = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
            for object in allObjects {
                appDelegate.managedObjectContext.deleteObject(object as! NSManagedObject)
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
    class func createNotificationBadge(badgeValue : Int?) -> UIButton {
        let notificationImage = AssetImage.notification.image
        let button = UIButton(frame: CGRect(x: 0 , y: 0, width: 25 , height: 25))
        button.setBackgroundImage(notificationImage, forState: .Normal)
        
        if let unwrappedBadgeValue = badgeValue {
            
            let badgeLabel = UILabel(frame: CGRect(x: button.frame.midX + 1, y: -5 , width: 15, height: 15))
            badgeLabel.text = String(unwrappedBadgeValue)
            badgeLabel.sizeToFit()
            if badgeLabel.frame.width < 18 {
                badgeLabel.frame = CGRect(x: button.frame.midX + 1, y: -5, width: 15, height: 15)
            }
            badgeLabel.textAlignment = .Center
            badgeLabel.textColor = UIColor.whiteColor()
            badgeLabel.font = UIFont.systemFontOfSize(12)
            badgeLabel.backgroundColor = UIColor.redColor()
            badgeLabel.clipToCircularCorner()
            button.addSubview(badgeLabel)
        }
        return button
    }
}

func compressedDataForImage(image: UIImage?) -> UIImage? {
    guard let originaImage = image else {
        return nil
    }
    
    var compression: CGFloat = 0.9
    let maxCompression: CGFloat = 0.1
    let maxFileSize: Int = 300000    // 300 KB
    
    if var imageData: NSData = UIImageJPEGRepresentation(originaImage, compression) {
        
        while (imageData.length > maxFileSize && compression > maxCompression)
        {
            compression -= 0.1
            imageData = UIImageJPEGRepresentation(originaImage, compression)!
        }
        
        return UIImage(data: imageData)
    }
    
    return nil
}


class UIBorderedLabel: UILabel {
    
    var topInset:       CGFloat = 0
    var rightInset:     CGFloat = 0
    var bottomInset:    CGFloat = 0
    var leftInset:      CGFloat = 8
    
    override func drawTextInRect(rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override func intrinsicContentSize() -> CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize()
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalizedString
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

