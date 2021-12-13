//
//  CWTextField.swift
//  Workbox
//
//  Created by Chetan Anand on 04/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import UIKit

class CWTextField: UITextField {

    var fieldType : FieldType = FieldType.TextType
    var currentIndexPath = NSIndexPath()

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func caretRectForPosition(position: UITextPosition) -> CGRect {
        if (fieldType == FieldType.DateType) || (fieldType == FieldType.PickerType) {

        return CGRect.zero
        }
        else{
            return super.caretRectForPosition(position)
        }
    }
    
    override func selectionRectsForRange(range: UITextRange) -> [AnyObject] {
        if (fieldType == FieldType.DateType) || (fieldType == FieldType.PickerType) {

        return []
        }
        else{
            return super.selectionRectsForRange(range)
        }
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if (fieldType == FieldType.DateType) || (fieldType == FieldType.PickerType) {
            // Disable copy, select all, paste
            if action == #selector(NSObject.copy(_:)) || action == #selector(NSObject.selectAll(_:)) || action == #selector(NSObject.paste(_:)) {
                return false
            }
        }
        // Default
        return super.canPerformAction(action, withSender: sender)
    }
}
