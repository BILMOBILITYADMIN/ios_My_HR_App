//
//  CherriesCollectionCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 15/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class CherriesCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var appTitleLabel: UILabel!
    
    @IBOutlet var appIconImageView: UIImageView!
    
    //Function to customize collection cell
    
    func updateCollectionCell(data : Cherries,imageName:String) {
        
        /*   if data.cherryName == CherryName.Performance.rawValue {
         appTitleLabel.text = "Champion Score Card"
         }
         else {
         appTitleLabel.text = data.cherryName
         }
         */
        appTitleLabel.text = data.displayString
        
        appTitleLabel.numberOfLines = 3
        
        appIconImageView.image = UIImage(named: imageName) // replace the image names here
        appIconImageView.layer.cornerRadius = 20
        appIconImageView.clipsToBounds = true
    }
}

