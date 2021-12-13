//
//  TSViewController.swift
//  Workbox
//
//  Created by Chetan Anand on 19/02/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class TSViewController: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let nib = UINib(nibName: String(TSHomeCell), bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: String(TSHomeCell))
        
        self.tableView.estimatedRowHeight = 33
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Table View Delegate And Datasource Extension
extension TSViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(String(TSHomeCell)) as! TSHomeCell
        return cell
    }
    
}
