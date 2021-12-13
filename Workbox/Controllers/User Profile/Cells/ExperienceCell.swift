
//
//  ExperienceViewCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 11/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class ExperienceCell: UITableViewCell {
    
 @IBOutlet var cellImageView: UIImageView!
//  @IBOutlet var experienceCompanyImageView : UIImageView!
    @IBOutlet var experienceDesignation: UILabel!
    @IBOutlet var experienceCompanyName: UILabel!
    @IBOutlet var experienceDuration: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCellData(data : UserExperience) {
        experienceCompanyName.text = (Helper.lengthOfStringWithoutSpace(data.companyName) > 0) ? data.companyName : ""
        experienceDesignation.text = (Helper.lengthOfStringWithoutSpace(data.designation) > 0) ? data.designation : ""
        let fromDate = Helper.stringForDate(data.fromDate, format: "MMM yyyy")
        let toDate = Helper.stringForDate(data.toDate, format: "MMM yyyy")
        if  Helper.lengthOfStringWithoutSpace(fromDate) > 0 {
            if   Helper.lengthOfStringWithoutSpace(toDate) > 0{
                experienceDuration.text = "\(fromDate) - \(toDate)"

            }
            else{
                experienceDuration.text = "\(fromDate) - Present"

            }
        }
        
    }
    
    func createCellImageView(index : NSInteger, count: NSInteger) {
        var image : UIImage
        let myInsets : UIEdgeInsets = UIEdgeInsetsMake(16,16 ,16,16 )
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
