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

    
    init(formView:XLFormViewController){
        self.formView=formView
    }
    
    var start:()->Void={}
    var finish:(Bool)->Void={(isError:Bool) in}
    
    
    func run(n:Int){
        self.isLoadError=false
        self.loadNum=n
        self.start()
    }
    
    
    func netLoadSelect(tag:String,module:String,parameters:[String: AnyObject]? = nil,translate:(String,JSON)->(AnyObject,String)){
    
        var formRow=formView.form.formRowWithTag(tag)!;
        Alamofire.request(.GET,Router(module),parameters:parameters)
            .responseJSON { _, _, ret,error in
        
                if(error != nil){
                   self.isLoadError=true
                }else{
                    var json = JSON(ret!)
                    var arr=[SelectOption] ()
                    for(index: String,subJson:JSON) in json{
                        let (value:AnyObject,text:String)=translate(index,subJson)
                        arr.append(SelectOption(value:value, text: text))
                    }
                    formRow.selectorOptions=arr
                    self.formView.reloadFormRow(formRow)
                }
                self.doFinishCall()
                
        }
        
    }
    
    
    func netLoadText(tag:String,module:String,parameters:[String: AnyObject]? = nil,dealResult:(XLFormRowDescriptor,JSON)->Void){
        
        var formRow=formView.form.formRowWithTag(tag)!;
        Alamofire.request(.GET,Router(module),parameters:parameters)
            .responseJSON { _, _, ret,error in
                
                if(error != nil){
                    self.isLoadError=true
                }else{
                    var json = JSON(ret!)
                    dealResult(formRow,json)
                    self.formView.reloadFormRow(formRow)
                }
                self.doFinishCall()
                
        }
        
    }
    
    private func doFinishCall(){
        self.loadNum--
        if(self.loadNum==0){
            self.finish(isLoadError)
        }
    }
    
    
}
