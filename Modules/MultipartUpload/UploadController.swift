//
//  UploadController.swift
//  Workbox
//
//  Created by Chetan Anand on 15/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire

class UploadController: NSObject {
    

    
     func UploadUsingAlamofire(){
        
        // Loading image from Assets
        let   myImage = UIImage(named: "image1")

        
        //Loading image from mainBundle
        if let fileURL = NSBundle.mainBundle().URLForResource("bgImage", withExtension: "jpg") {
            if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
                
                
                
        //Performing multipart upload
                Alamofire.upload(
                    .POST,
                    "http://dev.cherrywork.in/multipart/upload",
                    multipartFormData: { multipartFormData in
                        multipartFormData.appendBodyPart(fileURL: fileURL, name: "Image1")
                        
                        //Unwrapping myImage before uploading
                        if let someImage = myImage {
                            if let imageData = UIImageJPEGRepresentation(someImage, 0.5) {
                                    multipartFormData.appendBodyPart(data: imageData, name: "Image2")
                            }
                        }

                    },
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                            case .Success(let upload, _, _):
                                upload.responseJSON { response in
                                print(response)
                            }
                            case .Failure(let encodingError):
                                print(encodingError)
                        }
                    }
                )
                
            }
        }
        else{
            
            print("File not found")
        }
        
        
    }
}
    