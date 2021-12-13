//
//  ImageViewer.swift
//  Workbox
//
//  Created by Chetan Anand on 17/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
// 


// MARK: - ImageViewer
// Its is a wrapper class around SKPhotoBrowser


/* 
USAGES :

*** For Multiple Image ***
- Create collection of images and thumbnail in viewDidLoad or awakeFromNib etc, something like this :

for i in 0...9{
let photo = Photo(url: "http://www.gstatic.com/webp/gallery/\((i).jpg")
photo.caption = "This is the caption"
imagesCollection.photos.append(photo)
imagesCollection.thumbnails.append(testImages[i])
}

- Call showMultiImageViewer on an event, lets say, didSelectItemAtIndexPath in a collection view:

ImageViewer.sharedInstance.showMultiImageViewer( originImage, index: indexPath.row % 5, collectionOfImages: imagesCollection, viewToOriginate: cell)



*** For Single Image ***
- create a Photo object using an Image or the Url

let photo = Photo(url: "http://www.gstatic.com/webp/gallery/1.jpg")
OR         let photo = Photo(image: profileImage.image!)
photo.caption = "This is the caption on Single Image"

- Display image Viewer like this using showSingleImageViewer:
ImageViewer.sharedInstance.showSingleImageViewer(profileImage.image!,imageToShow: photo, viewToOriginate: profileImage)


*/



import UIKit
import SKPhotoBrowser


protocol PresentPhotoProtocol : NSObjectProtocol {
    func loadPhotoPresentationScreen(controller: UIViewController) -> Void;
}


class ImageViewer {
    
    weak var delegate: PresentPhotoProtocol?

    static let sharedInstance = ImageViewer()
    private init() {}
    


   
    func showMultiImageViewer(originImage : UIImage, index : Int, collectionOfImages : PhotoCollection, viewToOriginate : UIView){
        
        
        var imageArray = [SKPhoto]()
        
        for photoItem in collectionOfImages.photos{
            // Try not to add photos and url both in a collectionOfImages.
            // If in case this happens, then implementation below should be modified accordingly.
            
            if let url = photoItem.photoURL{
                let photo = SKPhoto.photoWithImageURL(url)
                if let cap = photoItem.caption{
                    photo.caption = cap
                }
                imageArray.append(photo)
            }
            
            if let photoAdded = photoItem.photo{
                let photo = SKPhoto.photoWithImage(photoAdded)
                if let cap = photoItem.caption{
                    photo.caption = cap
                }
                imageArray.append(photo)
            }
        
        }
        
        let browser = SKPhotoBrowser(originImage: originImage, photos: imageArray, animatedFromView: viewToOriginate)
        browser.initializePageIndex(index)
        delegate?.loadPhotoPresentationScreen(browser)

    }
    
    func showSingleImageViewer(thumbnailImage : UIImage, imageToShow : Photo, viewToOriginate : UIView){
        
        var imageArray = [SKPhoto]()

            if let url = imageToShow.photoURL{
                let photo = SKPhoto.photoWithImageURL(url)
                if let cap = imageToShow.caption{
                    photo.caption = cap
                }
                imageArray.append(photo)
            }
            else{
                if let photoAdded = imageToShow.photo{
                    let photo = SKPhoto.photoWithImage(photoAdded)
                    if let cap = imageToShow.caption{
                        photo.caption = cap
                    }
                    imageArray.append(photo)
                }
            }

        let browser = SKPhotoBrowser(originImage: thumbnailImage, photos: imageArray, animatedFromView: viewToOriginate)
        browser.initializePageIndex(0)
        delegate?.loadPhotoPresentationScreen(browser)


        
    }

    
}
