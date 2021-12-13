//
//  PoPrCell.swift
//  Workbox
//
//  Created by Pavan Gopal on 20/06/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class PoPrCell: UITableViewCell {

    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateCell(key:String?,value:String?){
        titleLabel.text = key?.capitalizedString
        detailLabel.text = value
    }
}
