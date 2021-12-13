//
//  BPMDetailController.swift
//  Workbox
//
//  Created by Pavan Gopal on 20/06/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class BPMDetailController: UIViewController {

    
    
    var bpmTaskDetailObject : BPMTaskDetail?
    var DisplayValues : [String]?
    var KeyValues : [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       KeyValues = bpmTaskDetailObject?.ContentData?.allKeys as? [String]
       DisplayValues = bpmTaskDetailObject?.ContentData?.allValues as? [String]
        
        self.navigationItem.title = bpmTaskDetailObject?.type
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
}


extension BPMDetailController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if DisplayValues?.count > 0{
        return (DisplayValues?.count)!
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let PoPrDetailCell  = tableView.dequeueReusableCellWithIdentifier("PoPrDetailCell", forIndexPath: indexPath) as UITableViewCell
        
//        if indexPath.row == 0 {
//            PoPrDetailCell.accessoryType = .DisclosureIndicator
//        }
//        else{
//            PoPrDetailCell.accessoryType = .None
//        }
        PoPrDetailCell.textLabel?.text = (KeyValues?[indexPath.row])?.capitalizedString
        PoPrDetailCell.detailTextLabel?.text = DisplayValues?[indexPath.row]
        
        return PoPrDetailCell
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.row == 0 {
//            let bpmDetailsController = UIStoryboard.POPRStoryboard().instantiateViewControllerWithIdentifier(String(BPMDetailController)) as! BPMDetailController
//            self.navigationController?.pushViewController(bpmDetailsController, animated: true)
//        }
//    }
}