//
//  CertificationCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 12/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class CertificationCell: UITableViewCell {
    @IBOutlet var cellImageView: UIImageView!

    @IBOutlet var certificationTitle: UILabel!
    @IBOutlet var instituteName: UILabel!
    @IBOutlet var certificationDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func updateCellData(data : UserCertification) {
        
        certificationDate.text = Helper.stringForDate(data.certificationDate, format: "MMM yyyy")
        certificationTitle.text = data.certificationTitle
        instituteName.text = data.instituteName
    }
    
    
    func createCellImageView(index : NSInteger, count: NSInteger) {
        let myInsets : UIEdgeInsets = UIEdgeInsetsMake(16,16 ,16,16 )
        var image : UIImage
        switch index {
            case (count - 1):
                image = AssetImage.Slice3.image


            default:
                image = AssetImage.Slice2.image

        }
        image = image.resizableImageWithCapInsets(myInsets)
        cellImageView.image = image
    }
}
