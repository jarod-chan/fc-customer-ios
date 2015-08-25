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
    
    func formValues (list: [String],param:[String:AnyObject]=[String:AnyObject]())->[String:AnyObject]?{
        var result:[String:AnyObject]?=param 
        for tag in list{
            let key=tag
            if let value:AnyObject = self.formView.form.formRowWithTag(key)?.value?.valueData(){
                result![key] = value
            }else{
                result![key] = ""
            }
            
        }
        var resultData:[String:AnyObject]?=[String:AnyObject]()
        resultData![app_counselor_id]=Defaults.counselor?.id
        resultData!["data"]=result
        return resultData
    }
    

    
    func setValue(tag:String,translate:(String,XLFormRowDescriptor)->AnyObject?){
        if let row=self.formView.form.formRowWithTag(tag) {
            row.value=translate(tag,row)
            self.formView.reloadFormRow(row)
        }
    }
    
}