//
//  RightMenuController.swift
//  Workbox
//
//  Created by mobinius on 1/25/17.
//  Copyright © 2017 Incture Technologies. All rights reserved.
//

import UIKit


protocol RightMenuControllerDeleagte {
    func updateExpandedState()
    func itemSelected(type : CardType,selectedIndexPath: NSIndexPath)
}

class RightMenuController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dismissView: UIView!
    
    @IBOutlet weak var tableViewxConstraint: NSLayoutConstraint!
    
    var delegate : RightMenuControllerDeleagte?
    
    var staticArray = [CardType.All,CardType.CSC,CardType.Performance,CardType.LMS,CardType.Recruitment]
    var currentIndex = NSIndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 33
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissTapped(_:)))
        dismissView.addGestureRecognizer(tapRecognizer)
        view.backgroundColor = UIColor.clearColor()
        view.opaque = false
        dismissView.backgroundColor = UIColor.clearColor()
        
        self.tableView.layer.shadowOpacity = 0.8
        tableViewxConstraint.constant = -self.tableView.frame.width
        
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        tableView.backgroundColor = UIColor.tableViewBackGroundColor()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.tableViewxConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }

     func dismissTapped(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.tableViewxConstraint.constant = -self.tableView.frame.width
            self.view.layoutIfNeeded()
            self.delegate?.updateExpandedState()
            }, completion: {finished in
                
                self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
    
    func dismissTapped(){
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.tableViewxConstraint.constant = -self.tableView.frame.width
            self.view.layoutIfNeeded()
            }, completion: {finished in
                self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
    
}

extension RightMenuController : UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staticArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("rightMenuCell", forIndexPath: indexPath)
        cell.textLabel?.text = staticArray[indexPath.row].rawValue
        cell.backgroundColor = UIColor.tableViewCellBackGroundColor()
        cell.textLabel?.textColor = UIColor.darkGrayColor()
        cell.accessoryType = (currentIndex == indexPath) ? .Checkmark : .None
        cell.textLabel?.font = (currentIndex == indexPath) ? UIFont.boldSystemFontOfSize(UIFont.systemFontSize()) : UIFont.systemFontOfSize(UIFont.systemFontSize())
        
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissTapped()
        delegate?.updateExpandedState()
      //  delegate?.itemSelected(staticArray[indexPath.row],selectedIndexPath: indexPath)
        
    }
}