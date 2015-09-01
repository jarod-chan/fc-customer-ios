//
//  ViewDealrecordController.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/31.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit
import XLForm
import MBProgressHUD
import SwiftyJSON
import Alamofire

class ViewDealrecordController:XLFormViewController {
    
    var customerId:Int!
    var dealrecord:JSON!=JSON([String:JSON]())
    
    var progressHUD:MBProgressHUD!
    var deleteSection:XLFormSectionDescriptor!
    
    // 是否有佣金记录，如果有的话就无法删除
    var haveCommission=false
    
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
        
        section = XLFormSectionDescriptor.formSectionWithTitle("成交记录")
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag:"sellproject", rowType: XLFormRowDescriptorTypeInfo, title: "小区")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:"building", rowType: XLFormRowDescriptorTypeInfo, title: "楼栋")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:"buildingunit", rowType: XLFormRowDescriptorTypeInfo, title: "单元")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:"room", rowType: XLFormRowDescriptorTypeInfo, title: "房间")
        section.addFormRow(row)
        
        section = XLFormSectionDescriptor.formSection()
        section.hidden=true
        self.deleteSection=section
        form.addFormSection(section)
        
        row=XLFormRowDescriptor(tag:nil, rowType:XLFormRowDescriptorTypeButton, title: "删除")
        row.cellConfig["textLabel.color"] = UIColor.redColor()
        row.action.formSelector = "doDeleteDealrecord:"
        section.addFormRow(row)

        
        self.form = form
        
    }
    
    func doDeleteDealrecord(sender: XLFormRowDescriptor) {
        if(self.progressHUD.alpha>0){
            return
        }
        let id=self.dealrecord["id"].intValue
        
        self.progressHUD.mode = .Indeterminate
        self.progressHUD.show(true)
        
        
        Alamofire.request(.POST, Router("customer/\(customerId)/dealrecord/\(id)/delete"),parameters:[app_counselor_id:Defaults.counselor!.id])
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
        
        
        helper.run(1)
        let id=self.dealrecord["id"].intValue
        
        helper.netLoad("customer/\(customerId)/dealrecord/\(id)/havecommission") { json in
            self.haveCommission=json["result"].boolValue;
            if(self.haveCommission){
                self.form.formSectionAtIndex(0)?.footerTitle="该成交记录存在佣金记录，无法删除或者修改。"
            }else{
                self.deleteSection.hidden=false
            }
        }
        


        
    }

    
    func initData(){
        
        let util=FormUtil(formView:self)
        
        util.setValue("sellproject"){ _ in self.dealrecord["extension","room","project_name"].stringValue}
        util.setValue("building"){ _ in self.dealrecord["extension","room","building_name"].stringValue}
        util.setValue("buildingunit"){ _ in self.dealrecord["extension","room","buildunit_name"].stringValue}
        util.setValue("room"){ _ in self.dealrecord["extension","room","roomName"].stringValue}
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.progressHUD=MBProgressHUD(view:self.view)
        self.view.addSubview(self.progressHUD)
        self.initSelectAlertView()
        
    }
    
   
}