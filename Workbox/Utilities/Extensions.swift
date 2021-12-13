//
//  Extensions.swift
//  Workbox
//
//  Created by Ratan D K on 15/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }
    
    class func loginStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Login", bundle: NSBundle.mainBundle())
    }
    
    class func cardsStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Cards", bundle: NSBundle.mainBundle())
    }
    
    class func groupsStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Groups", bundle: NSBundle.mainBundle())
    }
    
    class func othersStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Others", bundle: NSBundle.mainBundle())
    }
    
    class func AutoResizing() -> UIStoryboard {
        return UIStoryboard(name: "AutoResizing", bundle: NSBundle.mainBundle())
    }
    
    class func profileStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Profile", bundle: NSBundle.mainBundle())
    }
    
    class func TimeSheet() -> UIStoryboard {
        return UIStoryboard(name: "TimeSheet", bundle: NSBundle.mainBundle())
    }
    
    class func Approvals() -> UIStoryboard {
        return UIStoryboard(name: "Approvals", bundle: NSBundle.mainBundle())
    }
    
    class func notificationStoryboard() -> UIStoryboard {
        return UIStoryboard(name:"Notification", bundle: NSBundle.mainBundle())
    }
    
    class func reportStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Reports", bundle: NSBundle.mainBundle())
    }
    
    class func collaboratorStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Collaborator", bundle: NSBundle.mainBundle())
    }
    
    class func leaveStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Leave", bundle: NSBundle.mainBundle())
    }
    
    class func CalendarStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Calendar", bundle: NSBundle.mainBundle())
    }
    
    class func GamifyStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Gamify", bundle: NSBundle.mainBundle())
    }
    
    class func DashboardStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Dashboard", bundle: NSBundle.mainBundle())
    }
    class func POPRStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "POPR", bundle: NSBundle.mainBundle())
    }
}

extension UIColor {
    class func navBarColor() -> UIColor {
        return UIColor(red: 61/255, green: 60/255, blue: 121/255, alpha:1)
        //return UIColor(red: 234/255, green: 31/255, blue: 41/255, alpha:1)
    }
    
    class func navBarItemColor() -> UIColor{
        return UIColor.whiteColor()
    }
    
    class func sectionBackGroundColor() -> UIColor{
        return UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
    }
    
    class func tableViewBackGroundColor() -> UIColor{
         return UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
         //return UIColor(red: 250/255, green: 240/255, blue: 144/255, alpha: 1)
    }
    class func tableViewCellBackGroundColor() -> UIColor{
       // return UIColor(red: 226/255, green: 215/255, blue: 122/255, alpha: 1)
         return UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
    }
    
    class func cellBackGroundColor() -> UIColor{
       // return UIColor(red: 242/255, green: 233/255, blue: 170/255, alpha: 1)
         return UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
    }
}

extension UINavigationController{
    
    func setupNavigationBar() {
        self.navigationBar.barTintColor = UIColor.navBarColor()
        self.navigationBar.tintColor = UIColor.navBarItemColor()
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.navBarItemColor()
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.navBarItemColor()
        self.navigationItem.titleView?.tintColor = UIColor.navBarItemColor()

    }
}

extension BTNavigationDropdownMenu {
    
    func customizeDropDown(){
        self.menuTitleColor = UIColor.navBarItemColor()
        self.cellBackgroundColor = UIColor.navBarColor()
        self.cellTextLabelColor = UIColor.whiteColor()
        self.cellTextLabelFont = UIFont.systemFontOfSize(14)
     }
}




protocol ToBool {}
extension ToBool {
    var boolValue: Bool {
        return NSString(string: String(self)).boolValue
    }
}
extension String : ToBool{}
extension Int : ToBool{}


extension String{
    func toNSURL(imageSize : ImageSizeConstant) -> NSURL? {
        return Helper.nsurlFromStringWithImageSize(self, imageSize: imageSize)
    }
}


extension UIViewController {
    func addViewController (anyController: AnyObject) {
        if let viewController = anyController as? UIViewController {
            addChildViewController(viewController)
            view.addSubview(viewController.view)
            viewController.didMoveToParentViewController(self)
        }
    }
    
    func removeViewController (anyController: AnyObject) {
        if let viewController = anyController as? UIViewController {
            viewController.willMoveToParentViewController(nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
        }
    }
}
extension String {
    var camelCasedString: String {
        let source = self
        if source.characters.contains(" ") {
            let first = source.substringToIndex(source.startIndex.advancedBy(1))
            let cammel = NSString(format: "%@", (source as NSString).capitalizedString.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)) as String
            let rest = String(cammel.characters.dropFirst())
            return "\(first)\(rest)"
        } else {
            let first = (source as NSString).lowercaseString.substringToIndex(source.startIndex.advancedBy(1))
            let rest = String(source.characters.dropFirst())
            return "\(first)\(rest)"
        }
    }
    
    var captilizedEachWordString: String{
        return self.capitalizedStringWithLocale(NSLocale.currentLocale())
    }
}

extension UITableView {
    ///This method register cells in a tableview using strings [Make sure name of cell Class and cell identifier is same]
    func registerNibWithStrings(classStrings : String...){
        for arg: String in classStrings {
            self.registerNib(UINib(nibName: arg, bundle: nil), forCellReuseIdentifier: arg)
        }
    }
}


protocol CellForTable {}
extension CellForTable {
    static func cellFromClassType(tableView : UITableView,indexPath : NSIndexPath) -> Self {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(Self), forIndexPath: indexPath)
        return cell as! Self
    }
    
}
extension GenericFeedDetail : CellForTable {}
extension NewsFeedDetail : CellForTable{}
extension NewJoineeDetail : CellForTable{}
extension UserMessageDetail : CellForTable{}




protocol CellBackgroundProtocol{}
extension CellBackgroundProtocol where Self : UITableViewCell {
    
    static func setCellBackgroundView(cell: Self) {
        
        let imageView = UIImageView()
        imageView.image = AssetImage.RoundedCornerShadow.image
       
        cell.backgroundView = imageView
        cell.backgroundColor = UIColor.cellBackGroundColor()
        
    }
    
    
}
extension UITableViewCell : CellBackgroundProtocol{}
extension UITableViewCell {
    func setZeroInset(){
        let inset = UIEdgeInsetsZero
        self.separatorInset = inset
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = inset
    }
}


extension AssetImage {
    var image : UIImage {
        if let unwrappedImage = UIImage(named: self.rawValue){
            return unwrappedImage
        }
        else{
            print("ERROR: Asset with string '\(self.rawValue)' not found! [showing default image instead, Please verify asset string]")
            return UIImage(named: "errorImage")!
        }
    }
}


protocol UIViewLoading {}
extension UIView : UIViewLoading {}

extension UIViewLoading where Self : UIView {
    static func loadArrayFromNib() -> [Self] {
        let nibName = "\(self)".characters.split{$0 == "."}.map(String.init).last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiateWithOwner(self, options: nil) as! [Self]
    }
    static func loadFromNib() -> Self {
        let nibName = "\(self)".characters.split{$0 == "."}.map(String.init).last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiateWithOwner(self, options: nil).first as! Self
    }
    
}
extension UIImage {
    
    var decompressedImage: UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        drawAtPoint(CGPointZero)
        let decompressedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return decompressedImage
    }
    
    
    
}

extension UIView {
    func fadeIn(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 1.0
            }, completion: completion)  }
    
    func fadeOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
    
    func createActionButtons(actionBarEnabled : Bool,  actionViewHeightConstraint : NSLayoutConstraint, actionViewInitialHeight : CGFloat, actionArray : [CardAction]?,actionProperty: ActionProperty, maximumNumberOfButtonsToShow : Int?) -> [ActionButton]{
        var isTruncated : Bool = false
        var buttonArray = [ActionButton]()
        self.hidden = false
        
        guard actionBarEnabled else{
            actionViewHeightConstraint.constant = 0
            self.hidden = true
            return buttonArray
        }
        
        guard let unwrappedActionArray = actionArray else{
            actionViewHeightConstraint.constant = 0
            self.hidden = true
            return buttonArray
        }
        
        if unwrappedActionArray.contains(CardAction.UnknownAction){
            actionViewHeightConstraint.constant = 0
            self.hidden = true
            return buttonArray
        }
        
        var totalNumberOfElements : Int = unwrappedActionArray.count
        
        
        if let unwrappedMaxNumOfElementsToShow = maximumNumberOfButtonsToShow {
            if unwrappedActionArray.count > unwrappedMaxNumOfElementsToShow{
                totalNumberOfElements = unwrappedMaxNumOfElementsToShow
                isTruncated = true
            }
            else{
                totalNumberOfElements = unwrappedActionArray.count
                isTruncated = false
            }
        }
        else{
            totalNumberOfElements = unwrappedActionArray.count
            isTruncated = false
        }
        
        guard totalNumberOfElements > 0 else{
            actionViewHeightConstraint.constant = 0
            self.hidden = true
            
            return buttonArray
        }
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
        
        for subView in self.subviews {
            
            subView.removeFromSuperview()
        }
        let lineView = UIView()
        lineView.backgroundColor = ConstantColor.CWLightGray
        lineView.frame = CGRectMake(0, 0, self.bounds.width, CGFloat(1))
        self.addSubview(lineView)
        
        let actionViewWidthWithoutPaddings = self.bounds.width - (padding * CGFloat(numberOfActionButtons - 1))
        
        let widthOfEachView =  actionViewWidthWithoutPaddings / CGFloat(numberOfActionButtons)
        let heightOfEachView = actionViewInitialHeight
        
        let actionViewHeight = (heightOfEachView * CGFloat(numberOfRow)) + (padding * CGFloat(numberOfRow - 1))
        
        actionViewHeightConstraint.constant = actionViewHeight
        buttonArray.removeAll()
        for i in 0..<totalNumberOfElements{
            let viewElement = ActionButton()
            
            let widthIndex = Int(i % numberOfActionButtons)
            let heightIndex = Int(i / numberOfActionButtons)
            
            let originXOfElement =  self.bounds.origin.x +   (CGFloat(widthIndex) * (padding + widthOfEachView))
            let originYOfElement =  self.bounds.origin.y +   (CGFloat(heightIndex) * (padding + heightOfEachView))
            
            viewElement.frame = CGRectMake(originXOfElement ,originYOfElement , widthOfEachView, heightOfEachView)
            
            if isTruncated && (i == totalNumberOfElements - 1){
                let actionProp = ActionProperty()
                actionProp.actionType = CardAction.More
                actionProp.workitemId = actionProperty.workitemId
                actionProp.senderViewController = actionProperty.senderViewController
                actionProp.likedBySelf = actionProperty.likedBySelf
                viewElement.addAction(actionProp)

                
            }
            else{
                let actionProp = ActionProperty()
                actionProp.actionType = unwrappedActionArray[i]
                actionProp.workitemId = actionProperty.workitemId
                actionProp.senderViewController = actionProperty.senderViewController
                actionProp.likedBySelf = actionProperty.likedBySelf
                viewElement.addAction(actionProp)
                
            }
            
            self.addSubview(viewElement)
            buttonArray.append(viewElement)
        }
        
        return buttonArray
    }
    
    ///Attachment Stack
    func createStackOfAttachments(galleryBarEnabled : Bool, galleryViewHeightConstraint : NSLayoutConstraint,attachmentArray : [Attachment]? , numberOfElementsInEachRow : Int, maximumNumberOfElementsToShow : Int?){
        var isTruncated : Bool = false
        self.hidden = false
        
        let bottonPaddingInGalleryView = true //Set this true if padding on bottom is required
        
        guard galleryBarEnabled else{
            galleryViewHeightConstraint.constant = 0
            self.hidden = true
            return
        }
        
        guard let unwrappedAttachmentArray = attachmentArray else{
            galleryViewHeightConstraint.constant = 0
            self.hidden = true
            return
        }
        var totalNumberOfElements : Int = unwrappedAttachmentArray.count
        
        if let unwrappedMaxNumOfElementsToShow = maximumNumberOfElementsToShow {
            if unwrappedAttachmentArray.count > unwrappedMaxNumOfElementsToShow{
                totalNumberOfElements = unwrappedMaxNumOfElementsToShow
                isTruncated = true
            }
            else{
                totalNumberOfElements = unwrappedAttachmentArray.count
                isTruncated = false
            }
        }
        else{
            totalNumberOfElements = unwrappedAttachmentArray.count
            isTruncated = false
        }
        
        guard totalNumberOfElements > 0 else{
            galleryViewHeightConstraint.constant = 0
            self.hidden = true
            
            return
        }
        
        let padding : CGFloat = 8.0
        var numberOfRow = 0
        let mod = totalNumberOfElements % numberOfElementsInEachRow
        let div = Int(totalNumberOfElements / numberOfElementsInEachRow)
        
        
        if mod != 0{
            numberOfRow = div + 1
        }
        else{
            numberOfRow = div
        }
        
       let lastRowIndex = numberOfRow - 1
        let numberOfElementsInLastRow = totalNumberOfElements - (numberOfElementsInEachRow * (numberOfRow-1))
        
        
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        
        let galleryWidthWithoutPaddings = self.bounds.width - (padding * CGFloat(numberOfElementsInEachRow - 1))
        
        let widthOfEachView =  galleryWidthWithoutPaddings / CGFloat(numberOfElementsInEachRow)
        let heightOfEachView = widthOfEachView
        
        var galleryViewHeight = (heightOfEachView * CGFloat(numberOfRow)) + (padding * CGFloat(numberOfRow - 1))
        
        if bottonPaddingInGalleryView {
            galleryViewHeight = galleryViewHeight + (padding)
        }
        
        for i in 0..<totalNumberOfElements{
            let viewElement = ActionImageView()
            viewElement.contentMode = .ScaleAspectFill
            viewElement.clipsToBounds = true
            viewElement.attachmentArray = unwrappedAttachmentArray
            viewElement.selfImageIndex = i
            viewElement.addImageAction(GestureType.Tap)
            
            let xIndex = Int(i % numberOfElementsInEachRow)
            let yIndex = Int(i / numberOfElementsInEachRow)
            
            let originXOfElement =  self.bounds.origin.x +   (CGFloat(xIndex) * (padding + widthOfEachView))
            let originYOfElement =  self.bounds.origin.y +   (CGFloat(yIndex) * (padding + heightOfEachView))
            
            //            //Adding Top and Bottom padding to gallery view
            //            if topAndBottonPaddingInGalleryView  {
            //                if heightIndex == 0{
            //                    originYOfElement =  self.bounds.origin.y +   (CGFloat(heightIndex) * (padding + heightOfEachView)) + padding
            //                }
            //            }
            
            
//            if  yIndex != lastRowIndex{
                viewElement.frame = CGRectMake(originXOfElement ,originYOfElement , widthOfEachView, heightOfEachView)

//            }
            /*
            else{
                let galleryWidthWithoutPaddingsInLastRow = self.bounds.width - (padding * CGFloat(numberOfElementsInLastRow - 1))

                let widthOfEachViewInLastRow =  galleryWidthWithoutPaddingsInLastRow / CGFloat(numberOfElementsInLastRow)
                var heightOfEachViewInLastRow = widthOfEachViewInLastRow
                
                if heightOfEachViewInLastRow > galleryWidthWithoutPaddingsInLastRow / 3{
                    heightOfEachViewInLastRow  = galleryWidthWithoutPaddingsInLastRow / 3
                }
                
                 galleryViewHeight = (heightOfEachView * CGFloat(numberOfRow - 1)) + (padding * CGFloat(numberOfRow - 1)) + heightOfEachViewInLastRow
                
                let xIndexInLastRow = Int(i % numberOfElementsInLastRow)
                let yIndexInLastRow = Int(i / numberOfElementsInLastRow)
                
                let originXOfElementInLastRow =  self.bounds.origin.x +   (CGFloat(xIndexInLastRow) * (padding + widthOfEachViewInLastRow))
                let originYOfElementInLastRow =  self.bounds.origin.y +   (CGFloat(yIndexInLastRow) * (padding + heightOfEachViewInLastRow))
                
                viewElement.frame = CGRectMake(originXOfElementInLastRow ,originYOfElementInLastRow , widthOfEachViewInLastRow, heightOfEachViewInLastRow)


                
            }
            */
            
            
            
            if isTruncated && (i == totalNumberOfElements - 1){
                let numberDisplayView = UIView(frame: viewElement.bounds)
                numberDisplayView.alpha = 0.5
                numberDisplayView.frame = viewElement.bounds
                numberDisplayView.backgroundColor = ConstantColor.CWBlue
                
                let numberLabel = UILabel()
                numberLabel.numberOfLines = 0
                numberLabel.text = "+\(unwrappedAttachmentArray.count - 4)"
                numberLabel.textColor = UIColor.whiteColor()
                numberLabel.frame = CGRectMake(viewElement.bounds.midX - viewElement.bounds.width/4, viewElement.bounds.midY - viewElement.bounds.height/4, viewElement.bounds.width/2, viewElement.bounds.height/2)
                numberLabel.font = UIFont.systemFontOfSize(60)
                numberLabel.adjustsFontSizeToFitWidth = true
                numberLabel.textAlignment = .Center
                
                // image size is changed from thumbnail to medium as this function is used in detail screen  also
                viewElement.setImageWithOptionalUrlWithoutPlaceholder(unwrappedAttachmentArray[i].urlString?.toNSURL(ImageSizeConstant.Medium))
                
                viewElement.addSubview(numberDisplayView)
                viewElement.addSubview(numberLabel)
                viewElement.bringSubviewToFront(numberDisplayView)
                viewElement.bringSubviewToFront(numberLabel)
            }
            else{
                // image size is changed from thumbnail to medium as this function is used in detail screen  also

                viewElement.setImageWithOptionalUrlWithoutPlaceholder(unwrappedAttachmentArray[i].urlString?.toNSURL(ImageSizeConstant.Medium))
            }
            galleryViewHeightConstraint.constant = galleryViewHeight

            
            self.addSubview(viewElement)
        }
    }
    
    
    //Stack of Views
    func createStackOfViews(viewEnabled : Bool, viewHeightConstraint : NSLayoutConstraint,viewArray : [UIView]? , numberOfElementsInEachRow : Int, fixedHeightOfEachView : CGFloat?, maximumNumberOfElementsToShow : Int?, padding: CGFloat) -> [UIView] {
        var isTruncated : Bool = false
        self.hidden = false
        var finalViewArray = [UIView]()

        let topAndBottonPaddingInGalleryView = true //Set this true if padding on top(only) in self is required
        
        guard viewEnabled else{
            viewHeightConstraint.constant = 0
            self.hidden = true
            return finalViewArray
        }
        
        guard let unwrappedAttachmentArray = viewArray else{
            viewHeightConstraint.constant = 0
            self.hidden = true
            return finalViewArray
        }
        var totalNumberOfElements : Int = unwrappedAttachmentArray.count
        
        if let unwrappedMaxNumOfElementsToShow = maximumNumberOfElementsToShow {
            if unwrappedAttachmentArray.count > unwrappedMaxNumOfElementsToShow{
                totalNumberOfElements = unwrappedMaxNumOfElementsToShow
                isTruncated = true
            }
            else{
                totalNumberOfElements = unwrappedAttachmentArray.count
                isTruncated = false
            }
        }
        else{
            totalNumberOfElements = unwrappedAttachmentArray.count
            isTruncated = false
        }
        
        guard totalNumberOfElements > 0 else{
            viewHeightConstraint.constant = 0
            self.hidden = true
            
            return finalViewArray
        }
        
//        let padding : CGFloat = 8.0
        var numberOfRow = 0
        let mod = totalNumberOfElements % numberOfElementsInEachRow
        let div = Int(totalNumberOfElements / numberOfElementsInEachRow)
        
        if mod != 0{
            numberOfRow = div + 1
        }
        else{
            numberOfRow = div
        }
        
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        
        let galleryWidthWithoutPaddings = self.bounds.width - (padding * CGFloat(numberOfElementsInEachRow - 1))
        
        let widthOfEachView =  galleryWidthWithoutPaddings / CGFloat(numberOfElementsInEachRow)
        var heightOfEachView = widthOfEachView

        if let unwrappedHeightOfEachView = fixedHeightOfEachView {
            heightOfEachView = unwrappedHeightOfEachView
        }
        
        let galleryViewHeight = (heightOfEachView * CGFloat(numberOfRow)) + (padding * CGFloat(numberOfRow - 1))
        
        if !topAndBottonPaddingInGalleryView {
            viewHeightConstraint.constant = galleryViewHeight
        }else{
            viewHeightConstraint.constant = galleryViewHeight + (padding)
        }
        for i in 0..<totalNumberOfElements{
            let viewElement = UIView()
//            viewElement.attachmentArray = unwrappedAttachmentArray
//            viewElement.selfImageIndex = i
//            viewElement.addImageAction(GestureType.Tap)
            
            let widthIndex = Int(i % numberOfElementsInEachRow)
            let heightIndex = Int(i / numberOfElementsInEachRow)
            
            let originXOfElement =  self.bounds.origin.x +   (CGFloat(widthIndex) * (padding + widthOfEachView))
            let originYOfElement =  self.bounds.origin.y +   (CGFloat(heightIndex) * (padding + heightOfEachView))
            
            //            //Adding Top and Bottom padding to gallery view
            //            if topAndBottonPaddingInGalleryView  {
            //                if heightIndex == 0{
            //                    originYOfElement =  self.bounds.origin.y +   (CGFloat(heightIndex) * (padding + heightOfEachView)) + padding
            //                }
            //            }
            
            viewElement.frame = CGRectMake(originXOfElement ,originYOfElement , widthOfEachView, heightOfEachView)
//            unwrappedAttachmentArray[i].frame = viewElement.bounds
//            viewElement.addSubview(unwrappedAttachmentArray[i])
            
            if isTruncated && (i == totalNumberOfElements - 1){
                
                let attributedString = NSMutableAttributedString(string: "***", attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(7.0)])
                let numberLabel = UILabel(frame: viewElement.bounds)
                
                numberLabel.attributedText = attributedString
                numberLabel.textColor = UIColor.blackColor()
                numberLabel.adjustsFontSizeToFitWidth = true
                numberLabel.textAlignment = .Left
                viewElement.addSubview(numberLabel)
            }
            else {
                unwrappedAttachmentArray[i].frame = viewElement.bounds
                viewElement.addSubview(unwrappedAttachmentArray[i])
            }
         
            
            self.addSubview(viewElement)
         finalViewArray.append(viewElement)

            
        }
        return finalViewArray
    }
    
    func clipToCircularCorner(){
        self.layer.cornerRadius = self.bounds.height/2
        self.clipsToBounds = true
    }
    
    func clipToCircularSelectedCorners(corners: UIRectCorner) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: self.bounds.height/2, height: self.bounds.height/2))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
}

extension UIImageView{
    /// Use this for setting image to any imageView using OPTIONAL url (e.g. avatarUrl) and an appropriate placeholder image.
    func setImageWithOptionalUrl(url : NSURL?, placeholderImage: UIImage){
        if let unwrappedUrl = url{
            self.kf_setImageWithURL(unwrappedUrl, placeholderImage: placeholderImage)
        }
        else{
            self.image = placeholderImage
        }
    }
    
    /// Use this for setting image to any imageView using OPTIONAL url (e.g. avatarUrl) and an appropriate placeholder image.
    func setImageWithOptionalUrlWithoutPlaceholder(url : NSURL?){
        if let unwrappedUrl = url{
            self.kf_setImageWithURL(unwrappedUrl)
        }
    }
    
    func clipToCircularImageView(){
        self.layer.cornerRadius = self.bounds.width/2
        self.clipsToBounds = true
    }
    
    func setColor(color:UIColor){
        self.image!.imageWithRenderingMode(.AlwaysTemplate)
        self.tintColor = color
    }
    
}


extension _ArrayType where Generator.Element : Equatable{
    mutating func removeObject(object : Self.Generator.Element) {
        while let index = self.indexOf(object){
            self.removeAtIndex(index)
        }
    }
}

extension _ArrayType where Generator.Element : Equatable{
    mutating func indexOfObject(object : Self.Generator.Element) -> Index?{
        if let index = self.indexOf(object){
            return index
        }
        else{
            return nil
        }
    }
}

public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}

func getTopViewController() -> UIViewController? {
    let appDelegate = UIApplication.sharedApplication().delegate
    if let window = appDelegate!.window {
        return window?.visibleViewController
    }
    return nil
}





extension NSDate {
    
    public var timeAgoSimple: String {
        let components = self.dateComponents()
        
        if components.year > 0 {
            return stringFromFormat("%%d%@yr", withValue: components.year)
        }
        
        if components.month > 0 {
            return stringFromFormat("%%d%@mo", withValue: components.month)
        }
        
        // TODO: localize for other calanders
        if components.day >= 7 {
            let value = components.day/7
            return stringFromFormat("%%d%@w", withValue: value)
        }
        
        if components.day > 0 {
            return stringFromFormat("%%d%@d", withValue: components.day)
        }
        
        if components.hour > 0 {
            return stringFromFormat("%%d%@h", withValue: components.hour)
        }
        
        if components.minute > 0 {
            return stringFromFormat("%%d%@m", withValue: components.minute)
        }
        
        if components.second > 0 {
            return stringFromFormat("%%d%@s", withValue: components.second )
        }
        
        return ""
    }
    
    public var timeAgo: String {
        let components = self.dateComponents()
        
        if components.year > 0 {
            
            
             let dateString = Helper.stringForDateWithYearCorrection(self)
                return dateString
//            }else{
//                if components.year < 2 {
//                    return "Last year"
//                } else {
//                    return stringFromFormat("%%d %@years ago", withValue: components.year)
//                }
//            }
        }
        
        if components.month > 0 {
            let dateString = Helper.stringForDateWithYearCorrection(self)
                return dateString
//            }else{
//                if components.month < 2 {
//                    return "Last month"
//                } else {
//                    return stringFromFormat("%%d %@months ago", withValue: components.month)
//                }
//            }
        }
        
        if components.day >= 7 {
            let dateString = Helper.stringForDateWithYearCorrection(self)
                return dateString
//            }else{
//                let week = components.day/7
//                if week < 2 {
//                    return "Last week"
//                } else {
//                    return stringFromFormat("%%d %@weeks ago", withValue: week)
//                }
//            }
        }
        
        if components.day > 0 {
            if components.day < 2 {
//                return "Yesterday,\(Helper.stringForDate(self,format: ConstantDate.hma))"
                return "Yesterday"

            } else  {
                
                let dateString = Helper.stringForDateWithYearCorrection(self)
                    return dateString
//                }else{
//                    return stringFromFormat("%%d %@days ago", withValue: components.day)
//                }
//            }
            }
        }
        
        if components.hour > 0 {
            if components.hour < 2 {
                return "1 hr"
            } else  {
                return stringFromFormat("%%d %@hrs", withValue: components.hour)
            }
        }
        
        if components.minute > 0 {
            if components.minute < 2 {
                return "1 min"
            } else {
                return stringFromFormat("%%d %@min", withValue: components.minute)
            }
        }
        
        if components.second >= 0 {
            if components.second < 5 {
                return "Just now"
            } else {
                return stringFromFormat("%%d %@sec", withValue: components.second)
            }
        }
        if components.second < 0 {
            return "Just now"
        }
        return ""
    }
    
    private func dateComponents() -> NSDateComponents {
        let calander = NSCalendar.currentCalendar()
        return calander.components([.Second, .Minute, .Hour, .Day, .Month, .Year], fromDate: self, toDate: NSDate(), options: [])
    }
    
    private func stringFromFormat(format: String, withValue value: Int) -> String {
        let localeFormat = String(format: format, getLocaleFormatUnderscoresWithValue(Double(value)))
        return String(format: localeFormat, value)
    }
    
    private func getLocaleFormatUnderscoresWithValue(value: Double) -> String {
        guard let localeCode = NSLocale.preferredLanguages().first else {
            return ""
        }
        
        // Russian (ru) and Ukrainian (uk)
        if localeCode == "ru" || localeCode == "uk" {
            let XY = Int(floor(value)) % 100
            let Y = Int(floor(value)) % 10
            
            if Y == 0 || Y > 4 || (XY > 10 && XY < 15) {
                return ""
            }
            
            if Y > 1 && Y < 5 && (XY < 10 || XY > 20) {
                return "_"
            }
            
            if Y == 1 && XY != 11 {
                return "__"
            }
        }
        
        return ""
    }
    
    func startOfMonth(NoOfMonths : Int, currentDate : NSDate) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        if let minusOneMonthDate = dateByAddingMonths(NoOfMonths, currentDate: currentDate) {
            let minusOneMonthDateComponents = calendar.components([.Year, .Month], fromDate: minusOneMonthDate)
            
            let startOfMonth = calendar.dateFromComponents(minusOneMonthDateComponents)
            return startOfMonth
                
        }
        return nil
    }
    
    func dateByAddingMonths(monthsToAdd : Int, currentDate : NSDate) -> NSDate? {
        
        let calendar = NSCalendar.currentCalendar()
        let months = NSDateComponents()
        months.month = monthsToAdd
        return calendar.dateByAddingComponents(months, toDate: currentDate, options: [])
    }
    
     func endOfMonth(NoOfMonths : Int, currentDate : NSDate ) -> NSDate? {
        
        let calendar = NSCalendar.currentCalendar()
        if let plusOneMonthDate = dateByAddingMonths(NoOfMonths, currentDate: currentDate) {
            let plusOneMonthDateComponents = calendar.components([.Year, .Month], fromDate: plusOneMonthDate)
            
            let endOfMonth = calendar.dateFromComponents(plusOneMonthDateComponents)?.dateByAddingTimeInterval(-1)
            
            return endOfMonth
        }
        return nil
    }
    
}


