//
//  Service.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/29.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import Foundation
import XLForm
import SwiftyJSON
import MBProgressHUD
import Alamofire

class Service {
    var formView:XLFormViewController!
    var progressHUD:MBProgressHUD!
    
    init (formView:XLFormViewController){
        self.formView=formView
    }
    
    init (formView:XLFormViewController,progressHUD:MBProgressHUD){
        self.formView=formView
        self.progressHUD=progressHUD
    }
    
    init(progressHUD:MBProgressHUD){
        self.progressHUD=progressHUD
    }
    
    //从网络加载选项数据
    func netLoad(module:String,parameters:[String: AnyObject]? = nil,dealResult:(JSON)->Void){
        self.progressHUD.mode = .Indeterminate
        self.progressHUD.show(true)
        Alamofire.request(.GET,Router(module),parameters:parameters)
            .responseJSON { _, _, ret,error in
                if(error != nil){
                    self.progressHUD.labelText = "网络错误"
                    self.progressHUD.mode = .Text
                    self.progressHUD.hide(true, afterDelay: 2)
                }else{
                    var json = JSON(ret!)
                    dealResult(json)
                    self.progressHUD.hide(true)
                }
                
        }
    }

}