//
//  AttachCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 05/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class AttachCell: UICollectionViewCell {
    
    @IBOutlet weak var attachImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    //Function to create cell in collectionview
    func createCell(pickedImage : UIImage){

        attachImageView.image = pickedImage
        attachImageView.contentMode = UIViewContentMode.ScaleAspectFill
        attachImageView.clipsToBounds = true
    }
    
    //Function to format delete button
    func formatDeleteButton(){
        deleteButton.layer.cornerRadius = 10.0
        deleteButton.clipsToBounds = true
        deleteButton.layer.borderWidth = 1.0
        deleteButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
}
