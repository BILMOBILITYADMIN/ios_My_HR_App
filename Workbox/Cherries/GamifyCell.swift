//
//  GamifyCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 25/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class GamifyCell: UITableViewCell {

    @IBOutlet weak var levelContestConstraint: NSLayoutConstraint!

    @IBOutlet weak var contestMilestoneConstraint: NSLayoutConstraint!
    @IBOutlet weak var contestMilestonePlaceholderConstraint: NSLayoutConstraint!
    @IBOutlet weak var levelContestPlaceholderConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var milestonePlaceholder: UILabel!
    @IBOutlet weak var contestPlaceholder: UILabel!
    @IBOutlet weak var levelPlaceHolder: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var milestoneLabel: UILabel!
    @IBOutlet weak var userDesignation: UILabel!
    @IBOutlet weak var userProfilePic: UIImageView!

    @IBOutlet weak var contestLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var userDisplayName: UILabel!
    
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        
    }
    var milestone :String?
    var contest : String?
    var level : String?
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        UITableViewCell.setCellBackgroundView(self)
   
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateCellData(gamifyUser:GamifyUser){
        milestone = gamifyUser.milestone
        level = gamifyUser.level
        contest = gamifyUser.contest
        userDesignation.text = gamifyUser.designation
        userDisplayName.text = gamifyUser.displayName
        userProfilePic.clipToCircularImageView()
        userProfilePic.setImageWithOptionalUrl(gamifyUser.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: UIImage(named: "profile_icon")!)
        
            var progress:Float = 0
        
            progress = Float(gamifyUser.progress) / 1000
            progressView.setProgress(progress, animated: false)
            
            if progress <= 0.5{
                progressView.progressTintColor = ConstantColor.CWRed
            }
            else if progress >= 1{
                progressView.progressTintColor = ConstantColor.CWGreen
            }
            else{
                progressView.progressTintColor = ConstantColor.CWBlue

        }
        let progressInString = String(gamifyUser.progress) ?? ""
        print(progressInString)
        progressLabel.text = progressInString + "/1000"
        
          setLevelEnabled(Parser.isElementEnabled(forType: CardType.Gamify, forSubtype: CardSubtype.Leaderboard, optionalFieldString: "level"))
        
        setMilestoneEnabled(Parser.isElementEnabled(forType: CardType.Gamify, forSubtype: CardSubtype.Leaderboard, optionalFieldString: "milestone"))
        
        setContestEnabled(Parser.isElementEnabled(forType: CardType.Gamify, forSubtype: CardSubtype.Leaderboard, optionalFieldString: "contest"))
        
        }
    
    
    
    func setLevelEnabled(isEnabled : Bool){
        milestoneLabel.hidden = true
        milestonePlaceholder.hidden = true
        if !isEnabled{
            contestLabel.text = milestone
            contestPlaceholder.text = "Milestone"
            levelLabel.text = contest
            levelPlaceHolder.text = "Contest"
        }
        if !Parser.isElementEnabled(forType: CardType.Gamify, forSubtype: CardSubtype.Leaderboard, optionalFieldString: "contest") && !Parser.isElementEnabled(forType: CardType.Gamify, forSubtype: CardSubtype.Leaderboard, optionalFieldString: "level"){
            contestPlaceholder.hidden = true
            contestLabel.hidden = true
             levelLabel.text = milestone
            levelPlaceHolder.text = "Milestone"
        }

    }
    
    
    func setMilestoneEnabled(isEnabled : Bool){
        milestoneLabel.hidden = !isEnabled
        milestonePlaceholder.hidden = !isEnabled
        if !isEnabled{
            levelLabel.text = level
            contestLabel.text = contest
        }
    }
    
    func setContestEnabled(isEnabled : Bool){
        milestoneLabel.hidden = true
        milestonePlaceholder.hidden = true
        if !isEnabled{
            contestLabel.text = milestone
            contestPlaceholder.text = "Milestone"
            levelLabel.text = level
        }
    }
}
