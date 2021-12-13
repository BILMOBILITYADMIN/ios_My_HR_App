//
//  SettingsCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 21/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {

    @IBOutlet weak var settingsIcon: UIImageView!
    @IBOutlet weak var settingsLabel: UILabel!
 
    @IBOutlet weak var SettingsSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        if let isSet = UserDefaults.isSetTouchId(){
        SettingsSwitch.setOn(isSet, animated: false)
        }
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func settingsSwitchValueChanged(sender: AnyObject) {
        
       if sender.on == true{
        UserDefaults.setTouchIdSettings(true)
        
        }
       else{
        UserDefaults.setTouchIdSettings(false)

        }
    }
  
    
}
