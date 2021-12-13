//
//  CWTextInputView.swift
//  Workbox
//
//  Created by Chetan Anand on 18/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import ALTextInputBar


public class CWTextInputView: ALTextInputBar, AttachControllerProtocol {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    var actionProperty : ActionProperty?

    let attachViewController =  UIStoryboard.othersStoryboard().instantiateViewControllerWithIdentifier("AttachController") as! AttachController
    
    var badgeLabel : UILabel!
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        let leftButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        let rightButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        let leftViewWithBadge = UIView(frame: CGRectMake(0, 0, 44, 44))
        
        badgeLabel = UILabel(frame: CGRectMake(29, -2, 18, 18))
        badgeLabel.text = "0"
        badgeLabel.textAlignment = NSTextAlignment.Center
        badgeLabel.textColor = UIColor.whiteColor()
        badgeLabel.layer.backgroundColor  = UIColor(red: 39/255.0, green: 147/255.0, blue: 246/255.0, alpha: 1.0).CGColor
        
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.width/2
        badgeLabel.clipsToBounds = true
        
        leftViewWithBadge.addSubview(leftButton)
        leftViewWithBadge.addSubview(badgeLabel)
        
        
        leftButton.setImage(AssetImage.InsertPhoto.image, forState: UIControlState.Normal)
        rightButton.setImage(AssetImage.Send.image, forState: UIControlState.Normal)
        
        leftButton.addTarget(self, action: "presentAttachmentController", forControlEvents: UIControlEvents.TouchUpInside)
        
        rightButton.addTarget(self, action: "actionCommentOnWorkitem", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.showTextViewBorder = true
        self.leftView = leftViewWithBadge
        self.rightView = rightButton
        //        self.frame = CGRectMake(0, view.frame.size.height - textInputBar.defaultHeight, view.frame.size.width, textInputBar.defaultHeight)
        self.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
    }
    
    
    func addAction(onWorkitem : String?, sentByViewController : UIViewController?){
        actionProperty = ActionProperty(typeOfAction: CardAction.Comment, idOfWorkitem: onWorkitem, sentFromViewController: sentByViewController)
    }
    
    func attachmentDone(attachments: [UIImage]) {
        print("UPDATE BADGE \(attachments.count)")
        badgeLabel.text = String(attachments.count)
        self.hidden = false
        
    }
    func attachmentCancelled() {
        self.hidden = false
    }
    
    func presentAttachmentController(){
        attachViewController.delegate = self
        self.hidden = true
        ActionController.instance.presentAttachmentController(attachViewController)
    }
    
    func actionCommentOnWorkitem(){

        guard let unwrappedActionProperty = actionProperty else{
            print("unwrappedActionProperty nil on  CWTextInputView")
            return
        }
        ActionController.instance.comment(unwrappedActionProperty, commentText: self.textView.text)
        self.textView.resignFirstResponder()
        self.textView.placeholder = "Type here"
        self.textView.text = String()
    }
    
}
