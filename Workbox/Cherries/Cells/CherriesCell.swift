//
//  CherriesCell.swift
//  Workbox
//
//  Created by Anagha Ajith on 14/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class CherriesCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var cellAppCategory : CherryCategory?
    
    //MARK: - View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D, forRow row: Int) {
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        contentView.backgroundColor = UIColor.tableViewBackGroundColor()
        cellAppCategory = CherryCategory(rawValue: row)
        collectionView.reloadData()
    }
}


    
