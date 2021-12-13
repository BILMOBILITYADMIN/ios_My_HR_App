//
//  CircularMenuController.swift
//  Workbox
//
//  Created by Anagha Ajith on 15/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit


class CircularMenuController: UIViewController, RadialButtonDelegate {

    var label = UILabel()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action: "showMenu:")
        view.backgroundColor = UIColor.whiteColor()
        label = UILabel(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        label.backgroundColor = UIColor.lightGrayColor()
        label.layer.cornerRadius = 25
        label.clipsToBounds = true
        label.userInteractionEnabled = true
        label.text = ""
        label.addGestureRecognizer(gesture)
        view.addSubview(label)

    
    }
    
    func generateButtons() -> [ALRadialMenuButton] {
        
        var buttons = [ALRadialMenuButton]()
        for _ in 0..<5 {
            let button = ALRadialMenuButton(frame: CGRectMake(0, 0, 60, 60))
            button.layer.cornerRadius = 30
            button.layer.borderColor = UIColor.grayColor().CGColor
            button.layer.borderWidth = 2
            button.clipsToBounds = true
            
            buttons.append(button)
        }
        return buttons
    }
    
    func showMenu(sender: UITapGestureRecognizer) {
        let point :CGPoint = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2)
        let rad = ALRadialMenu()
            .setButtons(generateButtons())
            .setDelay(0.05)
            .setAnimationOrigin(point)
            .presentInView(view)
        rad.delegate = self
    }
    
    func getButtonIndex(i : Int) {
        print(i)
    }
    
}

