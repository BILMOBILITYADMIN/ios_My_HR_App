//
//  CWTextInputView.swift
//  Workbox
//
//  Created by Chetan Anand on 18/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import ALTextInputBar
import BSImagePicker
import Photos


public class CWTextInputView: ALTextInputBar {
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    var actionProperty : ActionProperty?
    
//    var attachViewController =  UIStoryboard.othersStoryboard().instantiateViewControllerWithIdentifier(String(AttachController)) as! AttachController
    var attachViewController =  BSImagePickerViewController()
    
    
    var badgeLabel : UILabel!
    var attachments = [UIImage]()
    var selectedAssetIds = [String]()

    
    //    init(leftButtonEnabled : Bool){
    //        super.init(frame: )
    //        commonInit()
    //
    //    }
    
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
        attachments.removeAll()
        
        badgeLabel = UILabel(frame: CGRectMake(29, -2, 18, 18))
        badgeLabel.text = "0"
        badgeLabel.textAlignment = NSTextAlignment.Center
        badgeLabel.textColor = UIColor.whiteColor()
        badgeLabel.layer.backgroundColor  = UIColor(red: 39/255.0, green: 147/255.0, blue: 246/255.0, alpha: 1.0).CGColor
        
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.width/2
        badgeLabel.clipsToBounds = true
        
        leftViewWithBadge.addSubview(leftButton)
        leftViewWithBadge.addSubview(badgeLabel)
        
        
        leftButton.setImage(AssetImage.attach.image, forState: UIControlState.Normal)
        rightButton.setImage(AssetImage.send.image, forState: UIControlState.Normal)
        
        leftButton.addTarget(self, action: #selector(CWTextInputView.presentAttachmentController), forControlEvents: UIControlEvents.TouchUpInside)
        
        rightButton.addTarget(self, action: #selector(CWTextInputView.actionOnWorkitem), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.showTextViewBorder = true
        self.leftView = leftViewWithBadge
        self.rightView = rightButton
        //        self.frame = CGRectMake(0, view.frame.size.height - textInputBar.defaultHeight, view.frame.size.width, textInputBar.defaultHeight)
        self.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        
        
        
        
    }
    
    
    func addAction(actionProp : ActionProperty?, placeholderText : String, leftViewEnabled : Bool, textBarEnabled : Bool){
        
        actionProperty = actionProp
        //        self.textView.hidden = false
        textView.userInteractionEnabled = true
        
        self.textView.placeholder = placeholderText
        if !leftViewEnabled {
            self.leftView = nil
        }
        if !textBarEnabled {
            //            self.textView.hidden = true
            self.showTextViewBorder = false
            textView.userInteractionEnabled = false
            
        }
        
    }
    
    
    func presentAttachmentController(){
        
        self.attachments.removeAll()
        let selectedAssets = PHAsset.fetchAssetsWithLocalIdentifiers(selectedAssetIds, options: nil)
        
        let attachViewController = BSImagePickerViewController()
        attachViewController.takePhotos = true
        attachViewController.maxNumberOfSelections = 6
        attachViewController.defaultSelections = selectedAssets


        if let topVC = getTopViewController(){
            topVC.bs_presentImagePickerController(attachViewController, animated: true,
                                                  select:
                { (asset: PHAsset) -> Void in
                    print("Selected: \(asset)")
                    self.selectedAssetIds.append(asset.localIdentifier)
                    
                }, deselect: { (asset: PHAsset) -> Void in
                    print("Deselected: \(asset)")
                    
                }, cancel: { (assets: [PHAsset]) -> Void in
                    print("Cancel: \(assets)")
                    self.selectedAssetIds.removeAll()
                    self.attachments.removeAll()
                    dispatch_async(dispatch_get_main_queue()) {
                        self.badgeLabel.text = String(self.attachments.count)
                    }
                    
                    
                }, finish: { (assets: [PHAsset]) -> Void in
                    print("Finish: \(assets)")
                    let manager = PHImageManager.defaultManager()
                    let options = PHImageRequestOptions()
                    options.resizeMode = PHImageRequestOptionsResizeMode.Exact
                    options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
                    
                   
                    dispatch_async(dispatch_get_main_queue()) {
                        for asset in assets{
                            manager.requestImageForAsset(asset,
                                targetSize: CGSize(width: 512, height: 512),
                                contentMode: .AspectFit,
                            options: options) { (result, _) in
                                self.attachments.append(result!)
                                self.badgeLabel.text = String(self.attachments.count)

                            }
                        }
                       /*
                        //Get image and set it's size
                        let image = self.attachments[0]
                        let newSize = CGSize(width: 100, height: 100)
                        
                        //Resize image
                        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
                        let imageResized = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        //Create attachment text with image
                        var attachment = NSTextAttachment()
                        attachment.image = imageResized
                        var attachmentString = NSAttributedString(attachment: attachment)
                        var myString = NSMutableAttributedString(string: self.textView.text)
                        myString.appendAttributedString(attachmentString)
                        self.textView.placeholder = ""
                        self.textView.attributedText = myString
 */
                    }
                    
                }, completion: nil)
        }
    }
    
    func actionOnWorkitem(){
        guard let unwrappedActionProperty = actionProperty else{
            print("unwrappedActionProperty nil on  CWTextInputView")
            return
        }
        guard let unwrappedActionType = unwrappedActionProperty.actionType else{
            print("unwrappedActionType nil on  CWTextInputView")
            return
        }
        if unwrappedActionType == CardAction.Comment{
            var actionProp = ActionProperty()
            actionProp = unwrappedActionProperty
            actionProp.actionType = CardAction.Comment
            actionProp.text = self.textView.text
            actionProp.attachments = attachments
            
            ActionController.instance.comment(actionProp)
            self.textView.resignFirstResponder()
            self.textView.placeholder = "Type here"
            self.textView.text = String()
        }
        else if unwrappedActionType == CardAction.Reject{
            
            var actionProp = ActionProperty()
            actionProp = unwrappedActionProperty
            actionProp.actionType = CardAction.Reject
            actionProp.text = self.textView.text
            actionProp.attachments = attachments
            
            ActionController.instance.RejectWithReason(actionProp)
            self.textView.resignFirstResponder()
            self.textView.placeholder = "Reason for rejection"
            self.textView.text = String()
            
        }
        attachments.removeAll()
        selectedAssetIds.removeAll()
        badgeLabel.text = String(attachments.count)

//        attachViewController = UIStoryboard.othersStoryboard().instantiateViewControllerWithIdentifier(String(AttachController)) as! AttachController


    }
    
}
