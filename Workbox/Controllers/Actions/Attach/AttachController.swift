//
//  AttachController.swift
//  Workbox
//
//  Created by Anagha Ajith on 05/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import ALTextInputBar

protocol AttachControllerProtocol : NSObjectProtocol {
    func attachmentDone(attachments : [UIImage]) -> Void;
}

class AttachController: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate,ALTextInputBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var attachButton: UIButton!

    var imagePicker = UIImagePickerController()
    var pickedImages = [UIImage]()
    let kPadding : CGFloat = 10.0
    var attachmentCount : Int? = 0
    let navigationBarAppearance = UINavigationBar.appearance()
    let navigationBarHeight : CGFloat = 64.0
    let textInputBar = ALTextInputBar()
//    var rightButton : UIButton?
    var delegate : AttachControllerProtocol?
    
    //MARK : - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Do any additional setup after loading the view.
        print("Attach Controller Loaded")
        imagePicker.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        textInputBar.frame.size.width = view.bounds.size.width
        textInputBar.textView.hidden = true
        textInputBar.showTextViewBorder = false
    
        textInputBar.textView.userInteractionEnabled = false
        configureInputBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    
    override func viewWillAppear(animated: Bool) {
         createNavBar()
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return textInputBar
        }
    }
    
    // This is also required
    override func canBecomeFirstResponder() -> Bool {
        
        return true
    }
    
    func configureInputBar() {
        
        let leftButton = UIButton(frame: CGRectMake(0, 0, 30, 30))
//        rightButton = UIButton(frame: CGRectMake(0, 0, 30, 30))
        leftButton.setImage(AssetImage.attach.image, forState: UIControlState.Normal)
//        rightButton!.setImage(UIImage(named: "send"), forState: UIControlState.Normal)
        
        leftButton.addTarget(self, action: #selector(AttachController.attachButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        rightButton!.addTarget(self, action: Selector("sendButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        textInputBar.showTextViewBorder = false
        textInputBar.leftView = leftButton
//        textInputBar.rightView = rightButton
//        textInputBar.backgroundColor = UIColor(white: 0.95, alpha: 1)
        textInputBar.addSubview(textInputBar.leftView!)
    }
    
    
    //MARK: - Function to format navigation bar
    func createNavBar() {

        navigationController?.navigationBar.barTintColor = UIColor.navBarColor()
        navigationController?.navigationBar.topItem?.title = "Attachments"
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let leftButton = UIBarButtonItem(title: "Cancel", style:   UIBarButtonItemStyle.Plain, target: self, action: #selector(AttachController.cancelButtonPressed(_:)))
        leftButton.tintColor = UIColor.whiteColor()
        let rightButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AttachController.doneButtonPressed(_:)))
        rightButton.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.rightBarButtonItem = rightButton

    }
    
    
    //Button action for Done
    func doneButtonPressed(sender: UIBarButtonItem){
//        delegate?.attachmentDone(pickedImages)
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    //Button action for Cancel
    func cancelButtonPressed(sender: UIBarButtonItem){
//        delegate?.attachmentCancelled()
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    //Button action for delete photo
    func deleteButtonPressed(button : UIButton) {
        attachmentCount = attachmentCount! - 1
        pickedImages.removeAtIndex(button.tag)
        collectionView.reloadData()
    }
    
    //MARK: - Button action when attach icon pressed
    func attachButtonPressed(sender: UIButton) {
        
        textInputBar.textView.resignFirstResponder()
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
       
        //Alert action to open camera
        let takePhoto = UIAlertAction(title: NSLocalizedString("takePhotoActionTitle", comment: ""), style: .Default, handler: { (action) -> Void in
            if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
                if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                    self.imagePicker.allowsEditing = true
                    self.imagePicker.sourceType = .Camera
                    self.presentViewController(self.imagePicker, animated: true, completion: {})
                } else {
                    print("Rear camera doesn't exist")
                }
            } else {
                print("Camera inaccessable")
            }
        })
        
        //Alert action to attach from photos
        let attachPhoto = UIAlertAction(title: NSLocalizedString("attachFromPhotos", comment: ""), style: .Default, handler: {
            (action) -> Void in
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.imagePicker.allowsEditing = true
            self.navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
            self.presentViewController(self.imagePicker, animated : true, completion : nil)
        })
        
        //Alert action to attach documents
        let  attachDocuments = UIAlertAction(title: NSLocalizedString("attachDocuments", comment: ""), style: .Default) { (action) -> Void in // To attach documents
        }
        
        //Cancel action sheet
        let cancel = UIAlertAction(title: NSLocalizedString("cancelActionTitle", comment: ""), style: .Cancel, handler: { (action) -> Void in
            print("Cancel Button Pressed")
        })
        
        alertController.addAction(takePhoto)
        alertController.addAction(attachPhoto)
        alertController.addAction(attachDocuments)
        alertController.addAction(cancel)
        presentViewController(alertController, animated: true, completion: nil)

    }
}

//MARK: - Extensions
extension AttachController: UICollectionViewDataSource{
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let sectionHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "sectionHeader", forIndexPath: indexPath) as! AttachCollectionHeaderView
        sectionHeader.sectionHeaderTitle.text = "PHOTOS"
        return sectionHeader
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("attachCell", forIndexPath: indexPath) as! AttachCell
        cell.createCell(pickedImages[indexPath.row])
        cell.formatDeleteButton()
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(AttachController.deleteButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return pickedImages.count
    }
}

extension AttachController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
     
        let size = CGSize(width: (view.frame.size.width - 3*kPadding)/2 , height: 130) // To resize cell based on the screen size
        return size
    }
 
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        let sectionInset = UIEdgeInsetsMake(0, kPadding, kPadding, kPadding)
        return sectionInset
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return kPadding
    }
}


extension AttachController: UIImagePickerControllerDelegate, UIGestureRecognizerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        pickedImages.append( info[UIImagePickerControllerEditedImage] as! UIImage )
        attachmentCount = attachmentCount! + 1
        self.dismissViewControllerAnimated(true, completion: nil)
        collectionView.insertItemsAtIndexPaths([NSIndexPath.init(forItem: attachmentCount! - 1, inSection: 0)])
        collectionView.reloadData()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {

        dismissViewControllerAnimated(true, completion: nil)
    }
}
