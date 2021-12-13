//
//  FormModel.swift
//  Workbox
//
//  Created by Chetan Anand on 05/05/16.
//  Copyright © 2016 Incture Technologies. All rights reserved.
//

import Foundation

enum FieldType : String {
    case DateType
    case TextType
    case PickerType
    case NumberType
    case PhoneNumberType
    
}
struct CellStructure {
    var cellTitle = ""
    var cellType : FieldType = FieldType.TextType
    var cellOptions = NSArray()
    var value : String?
}