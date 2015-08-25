//
//  AddOrEditPurposeController.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/21.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit
import XLForm
import MBProgressHUD
import SwiftyJSON
import Alamofire

class AddOrEditPurposeController: XLFormViewController {
    var customerId:Int!
    var purpose:JSON!=JSON([String:JSON]())
    
    var progressHUD:MBProgressHUD!
    var deleteSection:XLFormSectionDescriptor!

    private enum Tag : String {
        case khjb = "khjb"
        case yxqd = "yxqd"
        case gfdj = "gfdj"
        case zzlx = "zzlx"
        case hxlx = "hxlx"
        
        case mj = "mj"
        case dj = "dj"
        case zj = "zj"
        case dd = "dd"
        case jzfg = "jzfg"
        
        case jzx = "jzx"
        case yhld = "yhld"
        case kpsj = "kpjs"
        case xqf = "xqf"
        
        static let allValues = {
            [khjb, yxqd, gfdj,zzlx,hxlx,mj,dj,zj,dd,jzfg,jzx,yhld,kpsj,xqf].map
                { (tag:Tag)->String in
                    return tag.rawValue}
        }
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    func initializeForm() {
        
        let form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        form = XLFormDescriptor()
        form.assignFirstResponderOnShow = false
        
        section = XLFormSectionDescriptor.formSection()
        form.addFormSection(section)
        
        
        row = XLFormRowDescriptor(tag: Tag.khjb.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title: "客户级别")
        row.required=true
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tag.yxqd.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title: "意向强度")
        row.required=true
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tag.gfdj.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title: "购房动机")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tag.zzlx.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title: "住宅类型")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tag.hxlx.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title: "户型类型")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tag.mj.rawValue, rowType: XLFormRowDescriptorTypeText, title: "面积")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tag.dj.rawValue, rowType: XLFormRowDescriptorTypeText, title: "单价")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tag.zj.rawValue, rowType: XLFormRowDescriptorTypeText, title: "总价")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tag.dd.rawValue, rowType: XLFormRowDescriptorTypeText, title: "地段")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tag.jzfg.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title: "楼层")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tag.jzx.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title: "精装修")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tag.yhld.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title: "优惠力度")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tag.kpsj.rawValue, rowType:XLFormRowDescriptorTypeText, title: "开盘时间")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tag.xqf.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title: "学区房")
        section.addFormRow(row)
        
        section = XLFormSectionDescriptor.formSection()
        section.hidden=true
        self.deleteSection=section
        form.addFormSection(section)
        
        row=XLFormRowDescriptor(tag:nil, rowType:XLFormRowDescriptorTypeButton, title: "删除")
        row.cellConfig["textLabel.color"] = UIColor.redColor()
        row.action.formSelector = "doDeletePurpose:"
        section.addFormRow(row)
       
        self.form = form
        
    }
    
    func doDeletePurpose(sender: XLFormRowDescriptor) {
        if(self.progressHUD.alpha>0){
            return
        }
        let id=self.purpose["id"].intValue
        
        self.progressHUD.mode = .Indeterminate
        self.progressHUD.show(true)
       
        
        Alamofire.request(.POST, Router("customer/\(customerId)/purpose/\(id)/delete"),parameters:[app_counselor_id:Defaults.counselor!.id])
            .responseJSON { _, _, ret,error in
                if(error != nil){
                    println(error)
                    self.progressHUD.labelText = "网络错误"
                    self.progressHUD.mode = .Text
                    self.progressHUD.hide(true, afterDelay: 2)
                    return;
                }
                
                var json = JSON(ret!)
                var result = json["result"].bool!
                if result {
                    self.progressHUD.labelText = "删除成功"
                    self.progressHUD.mode = .Text
                    self.progressHUD.completionBlock={
                        self.progressHUD.completionBlock=nil
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                     self.progressHUD.hide(true, afterDelay: 2)
                }else{
                    
                    var message=json["message"].string!
                    self.progressHUD.labelText = message
                    self.progressHUD.mode = .Text
                    self.progressHUD.hide(true, afterDelay: 2)
                }
        }


    }
    
    func initSelectAlertView(){
        let helper=UIHelper(formView:self)
        
        helper.start={
            self.progressHUD.mode = .Indeterminate
            self.progressHUD.show(true)
        }
        
        helper.finish={
            isError in
            if(isError){
                self.progressHUD.labelText = "网络错误"
                self.progressHUD.mode = .Text
                self.progressHUD.hide(true, afterDelay: 2)
            }else{
                self.initData()
                self.progressHUD.hide(true)
            }
        }
        
        
        helper.run(9)
        
        let stringKeyAndValue:(String,JSON)->(AnyObject,String)={
            _,json in
            return (json["key"].stringValue,json["name"].stringValue)
        }
        
        helper.netLoadSelect(Tag.khjb.rawValue,module:"syenum",parameters:["type_key":"purpose_khjb"],translate:stringKeyAndValue)
        
        helper.netLoadSelect(Tag.yxqd.rawValue,module:"syenum",parameters:["type_key":"purpose_yxqd"],translate:stringKeyAndValue)
        
        helper.netLoadSelect(Tag.gfdj.rawValue,module:"syenum",parameters:["type_key":"purpose_gfdj"],translate:stringKeyAndValue)
        
        helper.netLoadSelect(Tag.zzlx.rawValue,module:"syenum",parameters:["type_key":"purpose_zzlx"],translate:stringKeyAndValue)
        
        helper.netLoadSelect(Tag.hxlx.rawValue,module:"syenum",parameters:["type_key":"purpose_hxlx"],translate:stringKeyAndValue)
        
        
        helper.netLoadSelect(Tag.jzfg.rawValue,module:"syenum",parameters:["type_key":"purpose_jzfg"],translate:stringKeyAndValue)
        
        helper.netLoadSelect(Tag.jzx.rawValue,module:"syenum",parameters:["type_key":"purpose_jzx"],translate:stringKeyAndValue)
        
        helper.netLoadSelect(Tag.yhld.rawValue,module:"syenum",parameters:["type_key":"purpose_yhld"],translate:stringKeyAndValue)
        
        helper.netLoadSelect(Tag.xqf.rawValue,module:"syenum",parameters:["type_key":"purpose_xqf"],translate:stringKeyAndValue)
    }
    
    func initData(){
        
        
        let util=FormUtil(formView:self)
        
        let stringSelect:(String,XLFormRowDescriptor)->AnyObject?={
            tag,row in
            if let selectOptions=row.selectorOptions as? [SelectOption]{
                var first=selectOptions[0]
                for option in selectOptions{
                    if option.value as! String == self.purpose[tag].stringValue{
                        return option;
                    }
                }
                return first;
            }
            return nil
        }
        util.setValue(Tag.khjb.rawValue,translate:stringSelect)
        util.setValue(Tag.yxqd.rawValue,translate:stringSelect)
        util.setValue(Tag.gfdj.rawValue,translate:stringSelect)
        util.setValue(Tag.zzlx.rawValue,translate:stringSelect)
        util.setValue(Tag.hxlx.rawValue,translate:stringSelect)
        
        let stringSetVal:(String,XLFormRowDescriptor)->AnyObject?={tag,_ in return self.purpose[tag].stringValue}
        
        util.setValue(Tag.mj.rawValue,translate:stringSetVal)
        util.setValue(Tag.dj.rawValue,translate:stringSetVal)
        util.setValue(Tag.zj.rawValue,translate:stringSetVal)
        util.setValue(Tag.dd.rawValue,translate:stringSetVal)

        
        util.setValue(Tag.jzfg.rawValue,translate:stringSelect)
        util.setValue(Tag.jzx.rawValue,translate:stringSelect)
        util.setValue(Tag.yhld.rawValue,translate:stringSelect)
        
        util.setValue(Tag.kpsj.rawValue,translate:stringSetVal)
        
        let noDefaultSelect:(String,XLFormRowDescriptor)->AnyObject?={
            tag,row in
            if let selectOptions=row.selectorOptions as? [SelectOption]{
                for option in selectOptions{
                    if option.value as! String == self.purpose[tag].stringValue{
                        return option;
                    }
                }
            }
            return nil
        }
        
        util.setValue(Tag.xqf.rawValue,translate:noDefaultSelect)
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.resetViewController()
        self.progressHUD=MBProgressHUD(view:self.view)
        self.view.addSubview(self.progressHUD)
        initSelectAlertView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"保存",style: UIBarButtonItemStyle.Plain, target: self, action: "savePressed:")
        
    }
    
    func savePressed(button: UIBarButtonItem)
    {
        
        if(self.progressHUD.alpha>0){
            return
        }
        
        let array = self.formValidationErrors();
        for errorItem in array {
            let error = errorItem as! NSError
            let validationStatus : XLFormValidationStatus = error.userInfo![XLValidationStatusErrorKey] as! XLFormValidationStatus
            
            if let cell = self.tableView.cellForRowAtIndexPath(self.form.indexPathOfFormRow(validationStatus.rowDescriptor)!) {
                cell.backgroundColor = UIColor.orangeColor()
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    cell.backgroundColor = UIColor.whiteColor()
                })
            }
            
        }
        
        if(array.count>0){
            return;
        }
        self.tableView.endEditing(true)
        
        
        self.progressHUD.mode = .Indeterminate
        self.progressHUD.show(true)
        

        
        var param=[String:AnyObject]()
        if let id=self.purpose["id"].int{
            param=["id":id]
        }
        var parameters=FormUtil(formView:self).formValues(Tag.allValues(),param:param)
        
        
        Alamofire.request(.POST, Router("customer/\(customerId)/purpose/save"), parameters: parameters,encoding:.JSON)
            .responseJSON { _, _, ret,error in
                if(error != nil){
                    println(error)
                    self.progressHUD.labelText = "网络错误"
                    self.progressHUD.mode = .Text
                    self.progressHUD.hide(true, afterDelay: 2)
                    return;
                }
                
                var json = JSON(ret!)
                var result = json["result"].bool!
                if result {
                    if let returnId=json["data","id"].int{
                        //struct 结构体无法直接改变值
                        var temp:JSON=self.purpose
                        temp["id"]=JSON(returnId)
                        self.purpose=temp
                    }
                    self.resetViewController()
                    self.progressHUD.labelText = "保存成功"
                    self.progressHUD.mode = .Text
                    self.progressHUD.hide(true, afterDelay: 2)
                    
                }else{
                    
                    var message=json["message"].string!
                    self.progressHUD.labelText = message
                    self.progressHUD.mode = .Text
                    self.progressHUD.hide(true, afterDelay: 2)
                }
        }
        
        
    }
    
    func resetViewController(){
        if let customer_id=self.purpose["id"].int{
            self.deleteSection.hidden=false
        }
    }

}
