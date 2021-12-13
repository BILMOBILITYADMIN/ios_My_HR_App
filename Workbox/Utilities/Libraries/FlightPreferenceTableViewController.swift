







//USAGES EXAMPLE 
//Use it in a table view controller like this.




/*
//
//  FlightPreferenceTableViewController.swift
//  Workbox
//
//  Created by Chetan Anand on 04/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit


class FlightPreferenceTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    struct EnteredData {
        //Section 1 , Note: This sould be a different model, But as of now hardcoding it
        var journeyType = ""
        var tripType = ""
        var visaType = ""
        var costCenter = ""
        var purpose = ""
        var from = ""
        var to = ""
        var departure = ""
    }
    
    var dataStructureArray = [[CellStructure]()]
    
    var enteredData = EnteredData()
    
    
    // keep track which indexPath points to the cell with UIDatePicker
    var datePickerIndexPath: NSIndexPath?
    var picker: UIPickerView!
    var  datePicker : UIDatePicker!
    let toolBar = UIToolbar()
    
    var currentIndexPath = NSIndexPath()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        tableView.registerNibWithStrings(String(TextFieldCell))
        
        tableView.estimatedRowHeight = 33
        tableView.rowHeight = UITableViewAutomaticDimension
        //Configure Picker
        picker = UIPickerView(frame: CGRectMake(0, 0, view.frame.width, 144))
        picker.backgroundColor = .whiteColor()
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        
        //Configure DatePicker
        datePicker = UIDatePicker(frame: CGRectMake(0, 0, view.frame.width, 144))
        datePicker.setDate(NSDate(), animated: true)
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        //Configure ToolBar
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = ConstantColor.CWBlue
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(doneButtonPressedOnPicker(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(cancelButtonPressedOnPicker(_:)))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        
        
        setFlightPreference()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function to set up the navigation bar along with buttons.
    func setupNavigationBar() {
        
        self.navigationController?.navigationBar.barTintColor = UIColor.navBarColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(saveButtonPressed(_:)))
        
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    
    func setFlightPreference(){
        //Configure Cells
        dataStructureArray.removeAll()
        dataStructureArray.append([CellStructure]())
        
        dataStructureArray[0].append(CellStructure(cellTitle: "Meal Type", cellType: FieldType.PickerType, cellOptions: ["Continental"], value: ""))
        dataStructureArray[0].append(CellStructure(cellTitle: "Smoking", cellType: FieldType.PickerType, cellOptions: ["Yes", "Non-Smoking"], value: ""))
        dataStructureArray[0].append(CellStructure(cellTitle: "Seat Position", cellType: FieldType.PickerType, cellOptions: ["Window", "Middle"], value: ""))
        dataStructureArray[0].append(CellStructure(cellTitle: "Airline", cellType: FieldType.PickerType, cellOptions: ["Spicejet", "Indigo", "Air India"], value: ""))
        
        
        tableView.reloadData()
    }
    
    
    func cancelButtonPressed(sender: UIBarButtonItem){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveButtonPressed(sender: UIBarButtonItem){
        self.view.endEditing(true)
        
        let alertController = UIAlertController(title: "Saved Successfully", message: "Sent for approval to your manager", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func doneButtonPressedOnPicker(sender: UIBarButtonItem){
        
        self.view.endEditing(true)
    }
    func cancelButtonPressedOnPicker(sender: UIBarButtonItem){
        self.view.endEditing(true)
        let cell = tableView.cellForRowAtIndexPath(currentIndexPath) as! TextFieldCell
        cell.dataTextField.text = nil
        
    }
    
    func datePickerValueChanged(sender : UIDatePicker){
        let cell = tableView.cellForRowAtIndexPath(currentIndexPath) as! TextFieldCell
        cell.dataTextField.text = Helper.stringForDate(sender.date, format: ConstantDate.dMMMMyyyy)
    }
    
    
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dataStructureArray.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return dataStructureArray[section].count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellData = dataStructureArray[indexPath.section][indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(String(TextFieldCell), forIndexPath: indexPath) as! TextFieldCell
        cell.dataTextField.delegate = self
        cell.dataTextField.fieldType = cellData.cellType
        cell.dataTextField.placeholder = cellData.cellTitle
        cell.dataTextField.currentIndexPath = indexPath
        return cell
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.becomeFirstResponder()
        
        let cwTextField = textField as! CWTextField
        currentIndexPath = cwTextField.currentIndexPath
        picker.reloadAllComponents()
        switch cwTextField.fieldType {
        case .PickerType:
            print("PickerType")
            textField.inputView = picker
            textField.inputAccessoryView = toolBar
            textField.text = dataStructureArray[currentIndexPath.section][currentIndexPath.row].cellOptions[0] as? String
            
        case .TextType:
            print("Text Type")
            textField.text = dataStructureArray[currentIndexPath.section][currentIndexPath.row].cellOptions[0] as? String
            
        case .NumberType:
            print("NumberType")
            textField.keyboardType = .NumberPad
            textField.text = dataStructureArray[currentIndexPath.section][currentIndexPath.row].cellOptions[0] as? String
            
        case .PhoneNumberType:
            print("PhoneNumberType")
            textField.keyboardType = .PhonePad
            textField.text = dataStructureArray[currentIndexPath.section][currentIndexPath.row].cellOptions[0] as? String
            
        case .DateType:
            print("DateType")
            textField.text = Helper.stringForDate(dataStructureArray[currentIndexPath.section][currentIndexPath.row].cellOptions[0] as? NSDate, format: ConstantDate.dMMMMyyyy)
            textField.inputView = datePicker
            textField.inputAccessoryView = toolBar
        }
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        
        let cwTextField = textField as! CWTextField
        guard let enteredText = cwTextField.text else{
            return
        }
        
        switch cwTextField.currentIndexPath.section {
        case 0:
            switch cwTextField.currentIndexPath.row {
            case 0:
                enteredData.journeyType = enteredText
            case 1:
                enteredData.tripType = enteredText
            case 2:
                enteredData.visaType = enteredText
            case 3:
                enteredData.costCenter = enteredText
            case 4:
                enteredData.purpose = enteredText
            default:
                print("")
            }
        case 1:
            switch cwTextField.currentIndexPath.row {
            case 0:
                enteredData.from = enteredText
            case 1:
                enteredData.to = enteredText
            case 2:
                enteredData.departure = enteredText
            default:
                print("")
            }
        default:
            print("")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print(textField.text)
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataStructureArray[currentIndexPath.section][currentIndexPath.row].cellOptions.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return dataStructureArray[currentIndexPath.section][currentIndexPath.row].cellOptions[row] as? String
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cell = tableView.cellForRowAtIndexPath(currentIndexPath) as! TextFieldCell
        cell.dataTextField.text = dataStructureArray[currentIndexPath.section][currentIndexPath.row].cellOptions[row] as? String
        
    }
    
}
 
 */
