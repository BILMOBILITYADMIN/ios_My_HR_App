//
//  TSCopyOverlayController.swift
//  Workbox
//
//  Created by Pavan Gopal on 19/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

protocol TSCopyOverlayControllerDelegate {
    func removeTaskController()
    func tasksToCopyFromIndexToIndices(fromIndex: Int, toIndices: [Int])
    func updateProjectsInTimesheet(updatedProjects : [TSProject], atIndex: Int)
}

// Optional delegate methods
extension TSCopyOverlayControllerDelegate{
  
    func updateProjectsInTimesheet(updatedProjects : [TSProject], atIndex: Int) {
        
    }
    
    func tasksToCopyFromIndexToIndices(fromIndex: Int, toIndices: [Int]) {
        
    }
}

class TSCopyOverlayController: UIViewController {

    @IBOutlet weak var tableViewHeaderRadioButton: UIButton!
    @IBOutlet weak var tableViewHeaderLabel: UILabel!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var didExecute : Bool = false
    var ktableViewFooterViewHeight:CGFloat = 40
    var delegate : TSCopyOverlayControllerDelegate?
    var days : [String]!
     var selectedRows = [Int]()
    var isTableViewHeaderRadioButtonPressed = false
    var timesheetProjects : [TSProject]?
    var isSelectRow : Bool = false
    var indexOfTimesheetToBeCopied : Int?
    var updatedProjectAtIndex: Int = 0
    var controllerObject : TSTaskSelectController?
    
   
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("load:", selectedRows)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setUpTableView() -> UIView{
        tableView.layer.cornerRadius = 5
        tableView.clipsToBounds = true
        
         let tableViewFooterView = UIView(frame:CGRectMake(0, 0, tableView.frame.size.width, ktableViewFooterViewHeight))
        let horizontalLineSeparator = UIView(frame: CGRectMake(0,0,tableView.frame.size.width,1))
        horizontalLineSeparator.backgroundColor = UIColor.lightGrayColor()
    
        let cancelButton = UIButton(frame: CGRectMake(0,1,tableViewFooterView.frame.size.width / 2,ktableViewFooterViewHeight))
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.tintColor = UIColor.navBarColor()
        cancelButton.setTitleColor(UIColor.navBarColor(), forState: .Normal)
        cancelButton.addTarget(self, action: #selector(TSCopyOverlayController.cancelButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        
        let verticalLineSeparator = UIView(frame: CGRectMake(cancelButton.frame.size.width + 1,0,1,cancelButton.frame.size.height))
        verticalLineSeparator.backgroundColor = UIColor.lightGrayColor()
        
        let doneButton = UIButton(frame: CGRectMake(tableViewFooterView.frame.size.width / 2 + 1 ,1,tableViewFooterView.frame.size.width / 2 - 1,ktableViewFooterViewHeight ))
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.setTitleColor(UIColor.navBarColor(), forState: .Normal)
        doneButton.tintColor = UIColor.navBarColor()
        doneButton.addTarget(self, action: #selector(TSCopyOverlayController.doneButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        
        tableViewFooterView.addSubview(verticalLineSeparator)
        tableViewFooterView.addSubview(horizontalLineSeparator)
        tableViewFooterView.addSubview(cancelButton)
        tableViewFooterView.addSubview(doneButton)

        tableViewHeaderRadioButton.addTarget(self, action: #selector(TSCopyOverlayController.tableViewHeaderRadioButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        tableViewFooterView.backgroundColor = UIColor.whiteColor()
        return tableViewFooterView
    }
    
    func tableViewHeaderRadioButtonPressed(sender:UIButton){

        if isTableViewHeaderRadioButtonPressed == true {
            isTableViewHeaderRadioButtonPressed = false
            selectedRows.removeAll()
            selectedRows.append(indexOfTimesheetToBeCopied!)
            tableViewHeaderRadioButton.setImage(UIImage(named: "Unchecked_checkBox"), forState: UIControlState.Normal)
        }
            
        else {
              isTableViewHeaderRadioButtonPressed = true
                for i in 0  ..< days.count  {
                    if selectedRows.contains(i) {
                    
                    }
                    else
                    {
                        selectedRows.append(i)
                    }
            }
             tableViewHeaderRadioButton.setImage(UIImage(named: "Checked_checkBox"), forState: UIControlState.Normal)
        }
        tableView.reloadData()
    }
    
    func copyButtonForIndexPressed(index : Int) {

        selectedRows.removeAll()
        indexOfTimesheetToBeCopied = index
        selectedRows.append(index)
        tableView.reloadData()

        isTableViewHeaderRadioButtonPressed = false
        tableViewHeaderRadioButton.setImage(UIImage(named: "Unchecked_checkBox"), forState: UIControlState.Normal)
    }
    
    func cancelButtonPressed(){
        print("cancel ButtonPressed")
        removeViewController(self)
    }
    
    func doneButtonPressed() {
        
        removeViewController(self)
        selectedRows.removeAtIndex(0)
        
        if let updatedProjects = timesheetProjects {
  
            delegate?.updateProjectsInTimesheet (updatedProjects, atIndex: indexOfTimesheetToBeCopied!)
        }
        
        delegate?.removeTaskController()
        delegate?.tasksToCopyFromIndexToIndices(indexOfTimesheetToBeCopied!, toIndices: selectedRows)
    }

  
}

//MARK: - Extension
extension TSCopyOverlayController :UITableViewDataSource,UITableViewDelegate{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let daysCount = days?.count{
        return daysCount
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return setUpTableView()
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell  = tableView.dequeueReusableCellWithIdentifier("WeekSelectionOverlayCell", forIndexPath: indexPath) as! WeekSelectionOverlayCell

        cell.daylabel.text = days?[indexPath.row]
        cell.checkButton.userInteractionEnabled = false
        cell.daylabel.text = days[indexPath.row]
        
        if indexPath.row == indexOfTimesheetToBeCopied {
            cell.userInteractionEnabled = false
        }
        else {
            cell.userInteractionEnabled = true
            
        }
        if selectedRows.contains(indexPath.row) == true {
            cell.checkButton.setImage(UIImage(named: "Checked_checkBox"), forState: .Normal)
        }
        else {
            cell.checkButton.setImage(UIImage(named: "Unchecked_checkBox"), forState: .Normal)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let shouldSelect : Bool = !selectedRows.contains(indexPath.row)
        
        if shouldSelect {
            selectedRows.append(indexPath.row)
        }
        else {
            selectedRows.removeAtIndex(selectedRows.indexOf(indexPath.row)!)
        }
        tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: indexPath.row, inSection: indexPath.section)], withRowAnimation: UITableViewRowAnimation.None)
        
        if selectedRows.count == days.count {
            isTableViewHeaderRadioButtonPressed = true
            tableViewHeaderRadioButton.setImage(UIImage(named: "Checked_checkBox"), forState: UIControlState.Normal)
        }
        else {
            isTableViewHeaderRadioButtonPressed = false
            tableViewHeaderRadioButton.setImage(UIImage(named: "Unchecked_checkBox"), forState: UIControlState.Normal)
        }
        tableView.reloadData()
    }
}
