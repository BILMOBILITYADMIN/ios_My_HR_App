//
//  DetailCommentCell.swift
//  Workbox
//
//  Created by Chetan Anand on 22/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class DetailCommentCell: UITableViewCell {
    
    
    @IBOutlet weak var userProfileImage : UIImageView!
    @IBOutlet weak var userNameLabel : UILabel!
    @IBOutlet weak var commentLabel : UILabel!
    @IBOutlet weak var commentTimeLabel: UILabel!
    
    @IBOutlet weak var attachmentView : UIView!
    @IBOutlet weak var attachmentViewHeightConstraint: NSLayoutConstraint!
    
    let kHeightOfAttachment = 50
    let kPadding  = 8
    let kCornerRadius : CGFloat = 5.0
    let kBorderWidth : CGFloat = 1.0
    let chipsColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1)
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        userProfileImage.layer.cornerRadius = userProfileImage.bounds.width/2
//        userProfileImage.clipsToBounds = true
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
//    func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D, forRow row: Int) {
//        collectionView.delegate = dataSourceDelegate
//        collectionView.dataSource = dataSourceDelegate
//        collectionView.tag = row
//        collectionView.reloadData()
//    }
    
//    func hideAttachmentView(value : Bool){
//        if value{
//            collectionViewHeightConstraint.constant = 0
//        }
//        else{
//            collectionViewHeightConstraint.constant = collectionViewHeightInitialValue
//            
//        }
//    }
    
    ///Updating Cell Data
    func updateCellWithData(cellData : Comment?){
        
        guard let unwrappedCellData = cellData else{
            return
        }
        userProfileImage.setImageWithOptionalUrl(unwrappedCellData.commentedBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)
        
        userNameLabel.text = unwrappedCellData.commentedBy?.displayName
        commentLabel.text = unwrappedCellData.commentText
//        commentTimeLabel.text = Helper.stringFromDateInHumanReadableFormat(unwrappedCellData.createdAt, dateStype: .ShortStyle, timeStyle: .NoStyle)
        commentTimeLabel.text = unwrappedCellData.createdAt?.timeAgo
        
        
//        setAttachments(unwrappedCellData.attachments)
        attachmentView.createStackOfAttachments(true, galleryViewHeightConstraint: attachmentViewHeightConstraint, attachmentArray: unwrappedCellData.attachments, numberOfElementsInEachRow: 3, maximumNumberOfElementsToShow: nil)
        
    }
    
}


