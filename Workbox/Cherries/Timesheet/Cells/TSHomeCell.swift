//
//  TSHomeCell.swift
//  Workbox
//
//  Created by Chetan Anand on 19/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

protocol CopyButtonPressedDelegate {
    func copyButtonPressed(index: Int)
    func  projectButtonPressed(projectName:String,index:Int)
}

class TSHomeCell: UITableViewCell {

    @IBOutlet weak var leaveOrHolidayLabel: UILabel!
    @IBOutlet weak var progressView : UIProgressView!
    @IBOutlet weak var chipsView : UIView!
    @IBOutlet weak var hoursClockedLabel: UILabel!
    @IBOutlet weak var cherryImageView: UIImageView!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var copyLargeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var chipsViewHeightConstraint: NSLayoutConstraint!
    
    var kNumberOfItems  = 0
    var tsHomecontroller = TSHomeController()
    var isLeaveOrHoliday:Bool?
    let kHeightOfChips = 22
    var selectedIndexPath = Int()
    let kWidthOfChips = 50
    let kPadding  = 8
    let kCornerRadius : CGFloat = 5.0
    let kBorderWidth : CGFloat = 1.0
    let chipsColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1)
    var delegate = CopyButtonPressedDelegate?()
    var currentIndex:Int?
    var tsStatus: TSStatus? = nil
//    var optionalsFields = [String]()
    
    override func awakeFromNib() {
//        tsHomecontroller.delegate = self
        super.awakeFromNib()

        copyButton.setImage(AssetImage.copyDay.image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        copyButton.imageView?.tintColor = UIColor.navBarColor()
        UITableViewCell.setCellBackgroundView(self)
        leaveOrHolidayLabel.text = "Tap to add new task"
        leaveOrHolidayLabel.textColor = UIColor.navBarColor()
        progressView.setProgress(0, animated: false)
    }
    
    func updateCell(timesheet: Timesheet){
        
        if tsStatus == TSStatus.Approved || tsStatus == TSStatus.Submitted {
            copyButton.enabled = false
            copyLargeButton.enabled = false
        }
        else {
            copyButton.enabled = true
            copyLargeButton.enabled = true
        }
        
        if timesheet.projects == nil {
            isLeaveOrHoliday = true
        }
        
        var projectNamesWithFilledTasks = [String]()
        
        setHourLableEnabled(Parser.isElementEnabled(forType: CardType.TimesheetType, forSubtype: CardSubtype.HomeType, optionalFieldString: "dayLimit"))
        setCopybuttonEnabled(Parser.isElementEnabled(forType: CardType.TimesheetType, forSubtype: CardSubtype.HomeType, optionalFieldString: "copy"))
        setTimebarEnabled(Parser.isElementEnabled(forType: CardType.TimesheetType, forSubtype: CardSubtype.HomeType, optionalFieldString: "timeBar"))
        
        
        var count = 0
        if let nonEmptyProjects = timesheet.projects{
            isLeaveOrHoliday = false
            for project in nonEmptyProjects{
                //tasks is empty
                if let tasks:[TSTask] = project.tasks{
                    for task in tasks {
                        if let submittedHours = task.submittedHours{
                        if let taskSubmittedHoursValueInFloat = Float(submittedHours){
                                if taskSubmittedHoursValueInFloat > 0{
                                    count += 1
                                    
                                    if let projectName = project.name {
                                        projectNamesWithFilledTasks.append(projectName)
                                    }
                                    else
                                    {
                                        projectNamesWithFilledTasks.append(project.id!)
                                    }
                                    
                                    break
                            }
                        }
                        }
                    }
                }
            }
            if let submittedHours = timesheet.submittedHours{
            if  let timesheetSubmittedHoursInFloat = Float(submittedHours){
                if let allocatedHours = timesheet.allocatedHours{
                if let timesheetAllocatedHoursInFloat = Float(allocatedHours){
                    var progress:Float = 0
                    if  timesheetAllocatedHoursInFloat != 0{
                         progress = (timesheetSubmittedHoursInFloat/timesheetAllocatedHoursInFloat)
                    }
                     progressView.setProgress(progress, animated: false)
                    
                    if progress >= 1{
                         progressView.progressTintColor = UIColor.greenColor()
                    }
                    else{
                        progressView.progressTintColor = UIColor.orangeColor()
                    }
                }
                }
            }
            }
            kNumberOfItems = count

        }
        
        
        if let workingDay = timesheet.isWorkingDay where workingDay == true {
            leaveOrHolidayLabel.text = "Tap to add task"
        }
        else {
            leaveOrHolidayLabel.text = timesheet.nonWorkingDayType?.capitalizedString
        }
        
        
        updateProjectChips(projectNamesWithFilledTasks,isLeaveOrHoliday:isLeaveOrHoliday!)
        
        print(timesheet.submittedHours)
        print("\n")
         let hours = timesheet.submittedHours ?? "0"
            if let timeInFloat = Float(hours){
                let  h = Int(timeInFloat / 60)
                let m = Int(timeInFloat % 60)
                hoursClockedLabel.text =  (String(h) + "h " + String(m)) + "m"
                
            if hours == "0" {
                hoursClockedLabel.text = "0h 0m"
                progressView.setProgress(0, animated: true)
            }
        }
        else{
            print("timesheet submitted hours is Zero")
        }
        print(hoursClockedLabel.text)
        dateLabel.text = Helper.stringForDate(timesheet.date, format: "EEEE, dd MMM")

        cherryImageView.image = AssetImage.clock.image        
    }
    
    func setHourLableEnabled(isEnabled : Bool){
        hoursClockedLabel.hidden = !isEnabled
        cherryImageView.hidden = !isEnabled
    }
    func setTimebarEnabled(isEnabled : Bool){
        progressView.hidden = !isEnabled
    }
    func setCopybuttonEnabled(isEnabled : Bool){
        copyButton.hidden = !isEnabled
    }
    
    func updateProjectChips(projectNames:[String],isLeaveOrHoliday:Bool) {
        progressView.layer.cornerRadius = kCornerRadius
        progressView.clipsToBounds = true

        let temp:CGFloat = CGFloat((kNumberOfItems + 1)/2 * kHeightOfChips)
        var chipsViewHeight:CGFloat = CGFloat(temp + CGFloat((kNumberOfItems)/2 * kPadding))
        if kNumberOfItems < 2 {
            chipsViewHeight += CGFloat(kPadding)
        }
        if kNumberOfItems == 0{
            chipsViewHeight = CGFloat(kPadding) + CGFloat(kHeightOfChips)
        }
        
        chipsViewHeightConstraint.constant = chipsViewHeight
        
        for subView in chipsView.subviews as [UIView] {
            subView.removeFromSuperview()
        }

        
        leaveOrHolidayLabel.hidden = false
        if kNumberOfItems > 0 {
            
            leaveOrHolidayLabel.hidden = true
            
            for i in 0...(kNumberOfItems-1) {
                if i%2 == 0{
                    let leftProjectButton = UIButton()
                    leftProjectButton.setTitle(projectNames[i], forState: .Normal)
                    leftProjectButton.setTitleColor(chipsColor, forState: .Normal)
                    leftProjectButton.titleLabel?.textAlignment = .Center
                    leftProjectButton.titleLabel?.lineBreakMode = .ByTruncatingMiddle
                    leftProjectButton.titleLabel?.font = UIFont.systemFontOfSize(12)
                    leftProjectButton.layer.borderWidth = kBorderWidth
                    leftProjectButton.layer.borderColor = chipsColor.CGColor
                    leftProjectButton.layer.cornerRadius = kCornerRadius
                    leftProjectButton.tag = i
                    chipsView.addSubview(leftProjectButton)
                    leftProjectButton.addTarget(self, action: #selector(ProjectButtonPressed(_:)), forControlEvents: .TouchDown)
                    leftProjectButton.frame = CGRectMake(chipsView.bounds.origin.x, chipsView.bounds.origin.y + CGFloat(((i) * (kHeightOfChips + kPadding)/2)), ConstantUI.cardWidth/2 - CGFloat(kWidthOfChips), CGFloat(kHeightOfChips))
                }
                else{
                    let rightProjectButton = UIButton()
                    rightProjectButton.setTitle(projectNames[i], forState: .Normal)
                    rightProjectButton.setTitleColor(chipsColor, forState: .Normal)
                    rightProjectButton.titleLabel?.textColor = chipsColor
                    rightProjectButton.titleLabel?.font = UIFont.systemFontOfSize(12)
                    rightProjectButton.titleLabel?.textAlignment = .Center
                    rightProjectButton.titleLabel?.lineBreakMode = .ByTruncatingMiddle
                    rightProjectButton.layer.borderWidth = kBorderWidth
                    rightProjectButton.layer.borderColor = chipsColor.CGColor
                    rightProjectButton.layer.cornerRadius = kCornerRadius
                    chipsView.addSubview(rightProjectButton)
                    rightProjectButton.tag = i
                    rightProjectButton.addTarget(self, action: #selector(ProjectButtonPressed(_:)), forControlEvents: .TouchDown)
                    rightProjectButton.frame = CGRectMake(ConstantUI.cardWidth/2 - CGFloat(kWidthOfChips - kPadding), chipsView.bounds.origin.y + CGFloat(((i-1) * (kHeightOfChips + kPadding)/2) ), ConstantUI.cardWidth/2 - CGFloat(kWidthOfChips), CGFloat(kHeightOfChips))
                    
                }
                
            }
           
        }
    }
   
    func ProjectButtonPressed(sender:UIButton){
        let projectName = sender.titleLabel?.text
        delegate?.projectButtonPressed(projectName ?? "",index:currentIndex!)
    }
    
    func getIndexPathForRow(index: Int) {
        copyButton.tag = index
        currentIndex = index
    }
    
    @IBAction func copyButtonPressed(sender: AnyObject) {
        delegate?.copyButtonPressed(copyButton.tag)
    }
    
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
}
