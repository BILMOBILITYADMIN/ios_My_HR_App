//
//  ActionButton.swift
//  Workbox
//
//  Created by Chetan Anand on 12/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class ActionButton: UIButton {
    
    var actionProperty : ActionProperty?
    
    
    func addAction(actionProperty : ActionProperty){
        self.actionProperty = actionProperty
        self.setTitleColor(UIColor.grayColor(), forState: .Normal)
        
        self.addTarget(self, action: #selector(ActionButton.actionButtonTapped), forControlEvents: UIControlEvents.TouchUpInside)
        
        if let unwrappedDisplayString = actionProperty.actionType?.displayString {
            self.setTitle(" \(unwrappedDisplayString.uppercaseString)", forState: .Normal)
            self.titleLabel?.font = UIFont.boldSystemFontOfSize(12)
        }

        if let unwrappedDisplayColor = actionProperty.actionType?.displayColor(actionProperty){
            self.setTitleColor(unwrappedDisplayColor, forState: .Normal)
        }
    }
    
    
    
    func actionButtonTapped(){
        ActionController.instance.actionOnActionButtonTapped(self)
    }
    
    

}
