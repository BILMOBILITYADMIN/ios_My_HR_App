//
//  Widget.swift
//  Workbox
//
//  Created by Pavan Gopal on 16/06/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation
import UIKit

class Widget {
    
    var lastModifiedDate : NSDate?
    var cherryType : String?
    var type : CardType?
    
    var title: String
    var description: String
    var image: UIImage
    
    class func allPhotos() -> [Widget] {
        var photos = [Widget]()
        if let URL = NSBundle.mainBundle().URLForResource("WidgetData", withExtension: "plist") {
            if let photosFromPlist = NSArray(contentsOfURL: URL) {
                for dictionary in photosFromPlist {
                    let photo = Widget(dictionary: dictionary as! NSDictionary)
                    photos.append(photo)
                }
            }
        }
        return photos
    }
    

    
    init(title: String, description: String, image: UIImage) {
        self.title = title
        self.description = description
        self.image = image
    }
    
    convenience init(dictionary: NSDictionary) {
        let title = dictionary["Caption"] as? String
        let description = dictionary["Comment"] as? String
        let photo = dictionary["Photo"] as? String
        let image = UIImage(named: photo!)
        self.init(title: title!, description: description!, image: image!)
    }
    
    func heightForComment(font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: description).boundingRectWithSize(CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return ceil(rect.height)
    }

}