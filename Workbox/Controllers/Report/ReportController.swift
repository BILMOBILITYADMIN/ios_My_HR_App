//
//  ReportController.swift
//  Workbox
//
//  Created by Anagha Ajith on 30/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

protocol ReportControllerDelegate {
    func leftSideMenuTapped()
}

class ReportController: UIViewController {
    var cardViewController : CardViewController?
    
    @IBOutlet weak var tableView: UITableView!
    var delegate : ReportControllerDelegate?
    var arrayOfRowNumbers  = [1,3,5]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: String(Report01Card), bundle: nil), forCellReuseIdentifier: String(Report01Card))
        tableView.registerNib(UINib(nibName: String(Report02Card), bundle: nil), forCellReuseIdentifier: String(Report02Card))
        tableView.registerNib(UINib(nibName: String(Report03Card), bundle: nil), forCellReuseIdentifier: String(Report03Card))
        
//        tableView.registerNib(UINib(nibName: String(BPMApprovalDetailCell), bundle: nil), forCellReuseIdentifier: String(BPMApprovalDetailCell))

       self.tableView.estimatedRowHeight = 64
        self.tableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
        
        let messageLabel = UILabel(frame: CGRectMake(0,self.view.frame.height/2 - 64,self.view.frame.width, 40))
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.textColor = UIColor.grayColor()
        messageLabel.font = UIFont.boldSystemFontOfSize(18)
        messageLabel.text = "No Reports"
        
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.userInteractionEnabled = false
        self.tableView.backgroundColor = UIColor.tableViewBackGroundColor()
        messageLabel.backgroundColor = UIColor.clearColor()
        self.tableView.addSubview(messageLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
       createNavBar()
    }
    
    func showSideMenu() {
        delegate?.leftSideMenuTapped()
    }

    
    func createNavBar() {
        navigationItem.title = "Reports"
        self.navigationController?.setupNavigationBar()
        
        let menuItem = UIBarButtonItem.init(image: UIImage.init(named: "sideNav"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ReportController.showSideMenu))
        
        let notificationButton : UIButton = Helper.createNotificationBadge(UserDefaults.badgeCount())
        notificationButton.addTarget(self, action: #selector(ReportController.notificationButtonPressed), forControlEvents: .TouchUpInside)
        let notificationItem = UIBarButtonItem.init(customView: notificationButton)
        
//        let addItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(ReportController.createTaskFeed))

        navigationItem.leftBarButtonItem = menuItem
        navigationItem.rightBarButtonItems = [notificationItem]
    }
    
    func createTaskFeed() {
        ActionController.instance.createTaskFeed()
    }
    
    func notificationButtonPressed() {
        ActionController.instance.notificationButtonPressed()
        
    }
}

extension ReportController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        

            
            let card1 = tableView.dequeueReusableCellWithIdentifier(String(Report01Card), forIndexPath: indexPath) as! Report01Card
            
            let messageLabel = UILabel(frame: CGRectMake(0,self.view.frame.height/2 - 64,self.view.frame.width, 40))
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.textColor = UIColor.grayColor()
            messageLabel.font = UIFont.boldSystemFontOfSize(18)
            messageLabel.text = "No Reports"
            
            self.tableView.separatorColor = UIColor.clearColor()
            self.tableView.userInteractionEnabled = false
            self.tableView.addSubview(messageLabel)
            
            return card1

        
    
    
}
}