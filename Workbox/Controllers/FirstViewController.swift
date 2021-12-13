//
//  FirstViewController.swift
//  Workbox
//
//  Created by Ratan D K on 01/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import UIKit
import Alamofire
import ReachabilitySwift

class FirstViewController: UIViewController {
    
    var appContainer: AppContainer?
    var reachability: Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if UserDefaults.isConfigured() == false {
//            launchConfigure()
//        }
//        else 
        if (UserDefaults.accessToken() == nil) {
            launchLogin()
        }
        else {
            launchTabBarController()
        }
        
        ImageViewer.sharedInstance.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        //declare this inside of viewWillAppear
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstViewController.reachabilityChanged(_:)),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            print("Network reachable")

            ActionController.instance.syncOfflineActions()

        } else {
            print("Network not reachable")
        }
    }
    
    // MARK: - Launchers
    
    func launchConfigure() {
        let configureController = UIStoryboard.loginStoryboard().instantiateViewControllerWithIdentifier(String(ConfigureController)) as! ConfigureController
        addViewController(configureController)
        
        configureController.configureCompletionHandler = {() -> Void in
            self.removeViewController(configureController)
            self.launchLogin()
        }
    }
    
    func launchLogin() {
        let loginController = UIStoryboard.loginStoryboard().instantiateViewControllerWithIdentifier(String(LoginController)) as! LoginController
        let nc = UINavigationController.init(rootViewController: loginController)
        addViewController(nc)
        
        loginController.loginCompletionHandler = {() -> Void in
            self.removeViewController(nc)
            self.launchTabBarController()
        }
    }
    
    func launchTabBarController() {
        appContainer = AppContainer()
        appContainer?.delegate = self
        addViewController(appContainer!)
    }
}


// MARK: - Extensions

extension FirstViewController: SideMenuControllerDelegate {
    func logoutHandler() {
        Helper.clearAllDB()
        removeViewController(appContainer!)
        UserDefaults.setAccessToken(nil)
        UserDefaults.setLoggedInEmail(nil)
        UserDefaults.setLoggedInName(nil)
        UserDefaults.setUserId(nil)
        UserDefaults.setIsConfigurationDownloaded(false)
        launchLogin()
    }
}

extension FirstViewController: PresentPhotoProtocol{
    func loadPhotoPresentationScreen(controller: UIViewController) {
        if let topVC = getTopViewController(){
            topVC.presentViewController(controller, animated: true, completion: nil)
        }
    }
}
