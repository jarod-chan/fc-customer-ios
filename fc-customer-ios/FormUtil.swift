//
//  UIData.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/17.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import Foundation
import XLForm

class FormUtil {
    
    let formView:XLFormViewController;
    
    init (formView:XLFormViewController){
        self.formView=formView
    }
    
    func formValues (list: [String])->[String:AnyObject]?{
        var result:[String:AnyObject]?=[String:AnyObject]()
        for tag in list{
            let key=tag
            if let value:AnyObject = self.formView.form.formRowWithTag(key)?.value?.valueData(){
                result![key] = value
            }else{
                result![key] = ""
            }
            
        }
        var resultData:[String:AnyObject]?=[String:AnyObject]()
        resultData!["app_counselor_id"]=Defaults.counselor?.id
        resultData!["data"]=result
        return resultData
    }
    
}