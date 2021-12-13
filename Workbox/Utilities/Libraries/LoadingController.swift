//
//  LoadingController.swift
//  Workbox
//
//  Created by Pavan Gopal on 12/04/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class LoadingController: UIViewController {

    @IBOutlet weak var blockerView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var overlayView: UIView!
    
    static let instance = LoadingController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overlayView.hidden = true
        // Do any additional setup after loading the view.
    }
    
    
    private init() {
        super.init(nibName: nil, bundle: nil)
//        print("SINGLETON INITIALIZED: LoadingController")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLoadingForSender(sender:UIViewController){
        setSuperView(sender)
        overlayView.hidden = true
        activityIndicatorView.startAnimating()
    }
    
    func showLoadingWithOverlayForSender(sender:UIViewController,cancel:Bool){
        if cancel{
            showLoadingWithUserInteractionForSender(sender)
        }
        else{
            showLoadingForSender(sender)
        }
//        overlayView.hidden = false
    }
    
    
    func showLoadingWithUserInteractionForSender(sender:UIViewController){
        setSuperViewWithUserInteraction(sender)
        blockerView.hidden = true
        overlayView.hidden = true
        activityIndicatorView.startAnimating()
    }
    
    func setSuperViewWithUserInteraction(sender:UIViewController){
        if (LoadingController.instance.view.superview == nil){
            if(sender.isKindOfClass(UIViewController)){
                let senderController:UIViewController = sender
                senderController.view.addSubview(LoadingController.instance.view)
                LoadingController.instance.view.frame = senderController.view.bounds
            }
        }
    }
    
    func setSuperView(sender:UIViewController){
        if (LoadingController.instance.view.superview == nil){
            if(sender.isKindOfClass(UIViewController)){
                let senderController:UIViewController = sender
                UIApplication.sharedApplication().keyWindow?.addSubview(LoadingController.instance.view)
                LoadingController.instance.view.frame = senderController.view.bounds
            }
        }
    }
    
    func hideLoadingView(){
        if activityIndicatorView != nil && overlayView != nil{
            activityIndicatorView.stopAnimating()
            overlayView.hidden = false
            LoadingController.instance.view.removeFromSuperview()
        }
    }
}
