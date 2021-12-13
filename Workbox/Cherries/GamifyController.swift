//
//  GamifyController.swift
//  Workbox
//
//  Created by Pavan Gopal on 25/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire

class GamifyController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var usersData = [GamifyUser]()
    var refreshControl = UIRefreshControl()
    var request: Alamofire.Request?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        ActionController.instance.downloadAndUpdateConfiguration()
        
        let closeItem = UIBarButtonItem.init(image: AssetImage.cross.image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GamifyController.closeButtonPressed))
        navigationItem.leftBarButtonItems = [closeItem]
               refreshControl.addTarget(self, action:#selector(GamifyController.handleRefresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)

        getGamifyUser()
        tableView.registerNib(UINib(nibName: String(GamifyCell), bundle: nil), forCellReuseIdentifier: String(GamifyCell))
        tableView.estimatedRowHeight = 170
        tableView.rowHeight = UITableViewAutomaticDimension
        setupNavigationBar()

        // Do any additional setup after loading the view.
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        isLoading = false
        self.request?.cancel()
        
        getGamifyUser()

//        else {
//            refreshControl.endRefreshing()
//        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeButtonPressed(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.topItem?.title = "LeaderBoard"
        self.navigationController?.setupNavigationBar()

    }
    
    func getGamifyUser(){
        LoadingController.instance.showLoadingWithOverlayForSender(self, cancel: true)
        
       self.request =  Alamofire.request(Router.GetGamifyUser()).responseJSON { response in
            LoadingController.instance.hideLoadingView()
        self.refreshControl.endRefreshing()

            switch response.result {
            case .Success(let JSON):
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    let message = jsonData[kServerKeyMessage]?.lowercaseString
                    
                    let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    
                    if let senderController =   getTopViewController(){
                        senderController.presentViewController(alertController, animated: true, completion: nil)
                    }
                    print("Error Occured: JSON Without success")
                    return
                }
                
                
                guard let jsonDataDictionaryArray = jsonData.valueForKey("data") as? [NSDictionary] else{
                    print("Cannot cast JSON to Dictionary: \(JSON)")
                    return
                }
                
               self.usersData = jsonDataDictionaryArray.flatMap{ GamifyUser(dictionaryData: $0)} 
                self.tableView.reloadData()
                
                if self.refreshControl.refreshing
                {
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                }
                else {
                    self.tableView.reloadData()
                    
                }
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                var message = error.localizedDescription
                if error.code == 403 {
                    message = "Session Expired"
                }
                let alertController = UIAlertController.init(title: "An error occured", message:message , preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
}

extension GamifyController:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let gamifyCell = tableView.dequeueReusableCellWithIdentifier(String(GamifyCell), forIndexPath: indexPath) as! GamifyCell
        gamifyCell.updateCellData(usersData[indexPath.row])
        
        return gamifyCell
    }
}
