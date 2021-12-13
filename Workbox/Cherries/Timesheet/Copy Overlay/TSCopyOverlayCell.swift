//
//  WeekSelectionOverlayCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 20/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class WeekSelectionOverlayCell: UITableViewCell {

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var daylabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
