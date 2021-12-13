//
//  NotificationController.swift
//  Workbox
//
//  Created by Anagha Ajith on 23/03/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire

class NotificationController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var dummyArray = ["ajhsjhsahdkjhfskdhFKgjkvkjSFKDJFKJsdvkjgskjDVKjsgdkjvkJSDVKJsvkjdvkjsDVJVsdjkasjgdjkagfgkahfkvkhfLI KG LDVGLIKVutiutiruybciyr;oiyqv;ci;oirbyc;oivyoqtiorvtoto", "sdgkVDJFKfdkjfKDFKJd \n jGDGjkdgiugDJGsudtougDKJOID\n kjdgoigDKJHSOGlsjfbhsaf\n hkjhidgfkjgaufgobaskjloaihgckjbakjchliuahsnvkhajvgiuqgfjbkjgliugajfnbsyxtvjhbqw \n jas igaug aguig aliug iuagk \n akjglgafgaf \n \n \n ajgifagkjfgliaug end.","hello"]
    
var notification = Notification()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationFetch()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        createNavBar()
    }
    
    
    func createNavBar() {
        
        navigationController?.navigationBar.barTintColor = UIColor.navBarColor()
        navigationController?.navigationBar.topItem?.title = "Notifications"
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        let backButton = UIBarButtonItem(image: AssetImage.back.image, style: .Plain, target: self, action: "backButtonPressed:")
        backButton.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func backButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func notificationFetch() {
        
        Alamofire.request(Router.NotificationFetch()).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                
                print(response)
                
                
                
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                
                
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    print("Error Occured: JSON Without success")
                    return
                }
                
                
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func notificationRead() {
        Alamofire.request(Router.NotificationRead(id: "56a0b08b811822f6125feaa6")).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON")
                print(response)
                guard let jsonData = JSON as? NSDictionary else{
                    print("Incorrect JSON from server : \(JSON)")
                    return
                }
                
                guard jsonData[kServerKeyStatus]?.lowercaseString == kServerKeySuccess else{
                    print("Error Occured: JSON Without success")
                    return
                }
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

extension NotificationController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(String(NotificationCell), forIndexPath: indexPath) as! NotificationCell
        cell.updateCell(dummyArray[indexPath.row])
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyArray.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        notificationRead()
    }
    
}