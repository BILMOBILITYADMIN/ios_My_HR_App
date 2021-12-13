//
//  SubscriptionCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 20/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class SubscriptionCell: UITableViewCell {
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var subtypeLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        followLabel.backgroundColor = .clearColor()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func createCell(subArray : Subscription) {
        
        var isMandatory : Bool = false
        if let mandatorySubscription = subArray.mandatory {
            if mandatorySubscription == true {
                isMandatory = true
            }
            else {
                isMandatory = false
            }
        }
        
        subtypeLabel.font = UIFont.systemFontOfSize(14)
        subtypeLabel.textColor = UIColor.lightGrayColor()
        
        followLabel.layer.borderWidth = 1.0
        followLabel.clipToCircularCorner()
        followLabel.layer.borderColor = UIColor.navBarColor().CGColor
        
        if let cardtype = subArray.subtype as String? {
            if let isSubscribed = subArray.subscribed as Bool? {
                
                subtypeLabel.text = cardtype.captilizedEachWordString
                if isMandatory == false {
                    UIView.animateWithDuration(0.6, delay: 0.0, options: .CurveLinear, animations: {
                        
                        if isSubscribed {
                            
                            self.followLabel.text = "  UNSUBSCRIBE  \u{200c}"
                            self.followLabel.layer.backgroundColor = UIColor.whiteColor().CGColor
                            self.followLabel.textColor = .navBarColor()
                        }
                            
                        else {
                            
                            self.followLabel.text = "  SUBSCRIBE  \u{200c}"
                            self.followLabel.layer.backgroundColor = UIColor.navBarColor().CGColor
                            self.followLabel.textColor = .whiteColor()
                        }
                        }, completion: nil )
                }
                    
                else {
                    
                    self.followLabel.layer.borderColor = UIColor.lightGrayColor().CGColor
                    self.followLabel.textColor = UIColor.lightGrayColor()
                    followLabel.layer.borderWidth = 1.0
                    followLabel.clipToCircularCorner()
                    
                }
            }
        }
    }
}






