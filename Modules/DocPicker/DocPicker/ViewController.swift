//
//  ViewController.swift
//  DocPicker
//
//  Created by Athul Sai on 22/12/15.
//  Copyright © 2015 Incture Technologies. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleImportMenuPressed(sender: AnyObject) {
        let importMenu = UIDocumentMenuViewController(documentTypes: [kUTTypeText as NSString as String], inMode: .Import)
        importMenu.delegate = self
        importMenu.addOptionWithTitle("Create New Document", image: nil, order: .First, handler: { print("New Doc Requested") })
        presentViewController(importMenu, animated: true, completion: nil)
    }
    
    @IBAction func handleImportPickerPressed(sender: AnyObject) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeText as NSString as String], inMode: .Import)
        documentPicker.delegate = self
        presentViewController(documentPicker, animated: true, completion: nil)
    }
    
    // MARK:- UIDocumentMenuDelegate
    func documentMenu(documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        presentViewController(documentPicker, animated: true, completion: nil)
    }
    
    // MARK:- UIDocumentPickerDelegate
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        // Do something
        var fileText = NSString()
        do {
            fileText = try NSString(contentsOfFile: url.path!, encoding: NSUTF8StringEncoding)
        }
        catch {/* error handling here */}
        self.textView.text = fileText as String
        //print(url)
    }



}

