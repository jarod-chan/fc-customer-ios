//
//  SelectOption.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/14.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import Foundation
import XLForm

class SelectOption: NSObject, XLFormOptionObject {
    let text:String
    let value:AnyObject
    
    init (value:AnyObject,text:String){
        self.text=text
        self.value=value
    }
    
    func formDisplayText() -> String{
        return self.text
    }

    func formValue() -> AnyObject{
        return self.value
    }
    
}