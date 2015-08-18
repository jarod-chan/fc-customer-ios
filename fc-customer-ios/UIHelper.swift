//
//  UIHelper.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/14.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import Foundation
import XLForm
import Alamofire
import SwiftyJSON
import MBProgressHUD

class UIHelper {
    
    let formView:XLFormViewController
    var loadNum:Int=0
    var isLoadError:Bool=false;
    var progressHUD:MBProgressHUD!
    
    init(formView:XLFormViewController){
        self.formView=formView
    }
    
    func startLoad(n:Int,progressHUD:MBProgressHUD){
        self.isLoadError=false
        self.loadNum=n
        self.progressHUD = progressHUD
        self.progressHUD.mode = .Indeterminate
        self.progressHUD.show(true)
    }
    
    
    func netLoadSelect(tag:String,module:String,parameters:[String: AnyObject]? = nil,translate:(String,JSON,inout Int)->(AnyObject,String)){
    
        var formRow=formView.form.formRowWithTag(tag)!;
        Alamofire.request(.GET,Router(module),parameters:parameters)
            .responseJSON { _, _, ret,error in
        
                if(error != nil){
                   self.isLoadError=true
                }else{
                    var json = JSON(ret!)
                    var arr=[SelectOption] ()
                    var defSelectOptionIndex = 0
                    for(index: String,subJson:JSON) in json{
                        let (value:AnyObject,text:String)=translate(index,subJson,&defSelectOptionIndex)
                        arr.append(SelectOption(value:value, text: text))
                    }
                    formRow.selectorOptions=arr
                    formRow.value=arr[defSelectOptionIndex]
                    self.formView.reloadFormRow(formRow)
                }
                self.doFinishCall()
                
        }
        
    }
    
    private func doFinishCall(){
        self.loadNum--
        if(self.loadNum==0){
            if(self.isLoadError){
                self.progressHUD!.labelText = "网络错误"
                self.progressHUD!.mode = .Text
            }else{
                self.progressHUD!.hide(true)
            }
        }
    }
    
    
}
