//
//  AddDealrecordController.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/29.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit
import XLForm
import MBProgressHUD
import SwiftyJSON
import Alamofire

class AddDealrecordController:XLFormViewController {
    
    var customerId:Int!
    var progressHUD:MBProgressHUD!
    
    private enum Tag : String {
        case room_id = "room_id"
        
        static let allValues = {
            [room_id].map
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
        
        section = XLFormSectionDescriptor.formSectionWithTitle("成交记录")
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag:"sellproject", rowType: XLFormRowDescriptorTypeSelectorAlertView, title: "小区")
        row.action.description
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:"building", rowType: XLFormRowDescriptorTypeSelectorAlertView, title: "楼栋")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:"buildingunit", rowType: XLFormRowDescriptorTypeSelectorAlertView, title: "单元")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:Tag.room_id.rawValue, rowType: XLFormRowDescriptorTypeSelectorAlertView, title: "房间")
        row.required=true
        section.addFormRow(row)
        
        
        self.form = form
        
    }
    
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        // 当数据还没加载完成时，不处理改变事件，代码赋值时，会触发该事件
        if self.progressHUD.alpha>0 {
            return
        }
        if(oldValue !== newValue){
            let tag=formRow.tag!
            if tag == "sellproject" || tag == "building" || tag == "buildingunit"{
                let sellproject=self.form.formRowWithTag("sellproject")!
                let building=self.form.formRowWithTag("building")!
                let buildingunit=self.form.formRowWithTag("buildingunit")!
                let room_id=self.form.formRowWithTag("room_id")!
                
                let util=RoomUtil(formView: self,progressHUD: self.progressHUD)
                
                if let selValue=newValue as? SelectOption{
                    let idParam=RoomUtil.urlEndecord(selValue.value as! String)
                    if tag == "sellproject"{
                        building.selectorOptions=nil
                        building.value=nil
                        buildingunit.selectorOptions=nil
                        buildingunit.value=nil
                        room_id.selectorOptions=nil
                        room_id.value=nil
                        
                        
                        util.netLoad("selroom/building?val=\(idParam)"){json in
                            util.setOption(json, rowName: "building")
                        }
                    }else if tag == "building"{
                        buildingunit.selectorOptions=nil
                        buildingunit.value=nil
                        room_id.selectorOptions=nil
                        room_id.value=nil
                        
                        util.netLoad("selroom/buildingunit?val=\(idParam)&roomstatus=Purchase"){json in
                            let type=json["type"].stringValue
                            if type == "unit" {
                                util.setOption(json["arr"], rowName: "buildingunit")
                            }else if type == "room"{
                                util.setOption(json["arr"], rowName: "room_id")
                            }
                        }
                    }else if tag == "buildingunit"{
                        room_id.selectorOptions=nil
                        room_id.value=nil
                        
                        util.netLoad("selroom/room?val=\(idParam)&roomstatus=Purchase"){json in
                            util.setOption(json, rowName: "room_id")
                        }
                    }
                }
                
            }
        }
    }
    
    
    func initSelectAlertView(){
        let util=RoomUtil(formView: self,progressHUD: self.progressHUD)
        util.netLoad("selroom/sellproject"){json in
            util.setOption(json, rowName: "sellproject")
        }
        
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
        
        
        var parameters=FormUtil(formView:self).formValues(Tag.allValues())
        
        
        Alamofire.request(.POST, Router("customer/\(customerId)/dealrecord/save"), parameters: parameters,encoding:.JSON)
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
                        self.progressHUD.labelText = "保存成功"
                        self.progressHUD.mode = .Text
                        self.progressHUD.completionBlock={
                            self.progressHUD.completionBlock=nil
                            self.navigationController?.popViewControllerAnimated(true)
                        }

                        self.progressHUD.hide(true, afterDelay: 2)
                    }
                }else{
                    
                    var message=json["message"].string!
                    self.progressHUD.labelText = message
                    self.progressHUD.mode = .Text
                    self.progressHUD.hide(true, afterDelay: 2)
                }
        }
        
        
    }
    
 


}