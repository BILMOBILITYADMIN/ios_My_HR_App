//
//  ActionImageView.swift
//  Workbox
//
//  Created by Pavan Gopal on 31/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity

class ActionImageView: UIImageView {
    
    var userIDToPerformAction = String()
    var userToPerformAction = User()
    var isLoading = false
    var user : User?
    
    //For Collection of images
    var attachmentArray  = [Attachment]()
    var selfImageIndex : Int = 0
    
    func addImageAction(gestureType : GestureType){
        
        if gestureType == .Tap{
            self.userInteractionEnabled = true
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        }
        else if gestureType == .LongPress{
            self.userInteractionEnabled = true
            guard let unwrappedUser = user else{
                return
            }
            userToPerformAction = unwrappedUser
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ActionImageView.handleLongPress(_:)))
            longPress.minimumPressDuration = 1.0
            longPress.allowableMovement = 100.0
            self.addGestureRecognizer(longPress)
        }
    }
    
    func handleTap(){
        print("HandleTap")
        var photoArray = [Photo]()
        
        for i in 0..<attachmentArray.count{
            photoArray.append(Photo(urlString: attachmentArray[i].urlString, image: self.image!, captionString: attachmentArray[i].attachmentName))
        }
        
        ImageViewer.sharedInstance.showMultiImageViewer(self.image!, index: selfImageIndex, collectionOfImages: photoArray, viewToOriginate: self)

    }
    
    func handleLongPress(sender : UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizerState.Began{
            ActionController.instance.presentRadialMenuViewController(userToPerformAction)
        }
    }

}

