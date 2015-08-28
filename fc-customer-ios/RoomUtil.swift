//
//  RoomUtil.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/28.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import Foundation
import XLForm
import SwiftyJSON
import MBProgressHUD
import Alamofire

class RoomUtil {
    
    let formView:XLFormViewController;
    var progressHUD:MBProgressHUD!
    
    init (formView:XLFormViewController){
        self.formView=formView
    }
    
    init (formView:XLFormViewController,progressHUD:MBProgressHUD){
        self.formView=formView
        self.progressHUD=progressHUD
    }

    
    //对eas的id进行url编码，因为eas的房间id会出项特殊字符
    static func urlEndecord(str:String)->String{
        var CFString = CFURLCreateStringByAddingPercentEscapes(nil,str, nil, "!*'();:@&=+$,/?%#[]\" ", kCFStringEncodingASCII);
        return "\(CFString)"
    }
    
    //设置选择选项
    func setOption(data:JSON,dataName:String,rowName:String){
        if data[dataName] != nil {
            var row=self.formView.form.formRowWithTag(rowName)!;
            var arr=[SelectOption] ()
            for (_,subJson) in  data[dataName]{
                arr.append(SelectOption(value:subJson["id"].stringValue,text:subJson["name"].stringValue))
            }
            row.selectorOptions=arr
            self.formView.reloadFormRow(row)
        }
    }
    
    //设置选择选项
    func setOption(data:JSON,rowName:String){
        if data != nil {
            var row=self.formView.form.formRowWithTag(rowName)!;
            var arr=[SelectOption] ()
            for (_,subJson) in  data{
                arr.append(SelectOption(value:subJson["id"].stringValue,text:subJson["name"].stringValue))
            }
            row.selectorOptions=arr
            self.formView.reloadFormRow(row)
        }
    }
    
    //从网络加载选项数据
    func netLoad(module:String,parameters:[String: AnyObject]? = nil,dealResult:(JSON)->Void){
        self.progressHUD.mode = .Indeterminate
        self.progressHUD.show(true)
        Alamofire.request(.GET,Router.homeURLString+module,parameters:parameters)
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