//
//  ViewController.swift
//  DocPreview
//
//  Created by Athul Sai on 21/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import UIKit
import QuickLook


class ViewController: UIViewController ,QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    var fileName = String()
    var fileType = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func viewPDF(sender: UIButton) {
        fileName = "wireframe_doc"
        fileType = "pdf"
        let preview = QLPreviewController()
        preview.dataSource = self
        self.presentViewController(preview, animated: true, completion: nil)
    }
    
    @IBAction func viewPNG(sender: UIButton) {
        fileName = "Agent"
        fileType = "png"
        let preview = QLPreviewController()
        preview.dataSource = self
        self.presentViewController(preview, animated: true, completion: nil)
    }
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType)
        let url = NSURL.fileURLWithPath(path!)
        
        return url
    }


}

