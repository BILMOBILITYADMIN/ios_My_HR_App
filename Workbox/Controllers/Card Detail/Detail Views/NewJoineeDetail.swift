//
//  NewJoineeDetail.swift
//  Workbox
//
//  Created by Chetan Anand on 28/01/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class NewJoineeDetail: UITableViewCell {
    
    
    @IBOutlet weak var newJoineeImage : UIImageView!
    @IBOutlet weak var newJoineeLabel : UILabel!
    @IBOutlet weak var newJoineeSubLabel : UILabel!
    @IBOutlet weak var numberOfLikesLabel : UILabel!
    @IBOutlet weak var cardActionView: UIView!
    
//    let actionArray = Parser.fetchActions(forType: CardType.FeedType  ,forSubtype: CardSubtype.NewJoineeType, forCardStatus: nil)

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        actionArray.removeObject(CardAction.Comment)

    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    ///Updating Cell Data
    func updateCellWithData(cellData : NewJoinee?,sentBy : UIViewController){
        
        guard let unwrappedCellData = cellData else{
            return
        }
        var actionProp = ActionProperty()
        actionProp.workitemId = unwrappedCellData.id
        actionProp.likedBySelf = unwrappedCellData.likedBySelf
        actionProp.senderViewController = sentBy
        

        newJoineeLabel.text = unwrappedCellData.titleString
        newJoineeSubLabel.text = unwrappedCellData.contentString
//        numberOfLikesLabel.text = Helper.likeAndCommentString(unwrappedCellData.likeCountInt, numberOfComments: nil, likesOrComments: LikesOrComments.Like)
    }
}
