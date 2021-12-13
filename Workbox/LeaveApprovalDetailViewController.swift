//
//  LeaveApprovalDetailViewController.swift
//  Workbox
//
//  Created by Chetan Anand on 25/04/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class LeaveApprovalDetailViewController: UIViewController {

    var leaveApprovalData : LeaveApproval?
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var leaveTypeLabel: UILabel!
    @IBOutlet weak var numberOfDaysLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var actionViewHeightConstraint: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.hidden = true
        tableView.estimatedRowHeight = 33
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerNibWithStrings(String(LeaveDetail))
        
        
        userNameLabel.text = leaveApprovalData?.leaveSubmittedBy?.displayName ?? ""
        leaveTypeLabel.text = leaveApprovalData?.leaveName ?? ""
        numberOfDaysLabel.text = leaveApprovalData?.leaveDuration ?? ""
        userAvatarImageView.clipToCircularCorner()
        userAvatarImageView.setImageWithOptionalUrl(leaveApprovalData?.leaveSubmittedBy?.avatarURLString?.toNSURL(ImageSizeConstant.Thumbnail), placeholderImage: AssetImage.ProfileImage.image)

        // Do any additional setup after loading the view.
        var actionButtonViewArray = [UIView]()

        let approveButton = ActionButton()
        var approveActProp = ActionProperty()
        approveActProp.workitemId = leaveApprovalData?.id
        approveActProp.actionType = CardAction.Approve
        approveActProp.senderViewController = self
        approveButton.addAction(approveActProp)
        Helper.setBorderForButtons(approveButton, color: ConstantColor.CWBlue)
        
        actionButtonViewArray.append(approveButton)
        
        let rejectButton = ActionButton()
        var rejectActProp = ActionProperty()
        rejectActProp.workitemId = leaveApprovalData?.id
        rejectActProp.actionType = CardAction.Reject
        rejectActProp.senderViewController = self
        rejectButton.addAction(rejectActProp)
        Helper.setBorderForButtons(rejectButton, color: ConstantColor.CWBlue)
        
        actionButtonViewArray.append(rejectButton)
        
         Helper.layoutButtons(true, actionView: actionView, actionViewHeightConstraint: actionViewHeightConstraint, actionViewInitialHeight: actionViewHeightConstraint.constant, viewArray: actionButtonViewArray, maximumNumberOfButtonsToShow: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
 

    

}


// MARK: - Table View Delegate And Datasource Extension
extension LeaveApprovalDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(String(LeaveDetail), forIndexPath: indexPath) as! LeaveDetail
        cell.updateCellWithData(leaveApprovalData, sentBy: self)
        return cell
        
    }
}




