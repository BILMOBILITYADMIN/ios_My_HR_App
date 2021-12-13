//
//  TextFieldCell.swift
//  Workbox
//
//  Created by Chetan Anand on 03/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {

    @IBOutlet weak var dataTextField: CWTextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
