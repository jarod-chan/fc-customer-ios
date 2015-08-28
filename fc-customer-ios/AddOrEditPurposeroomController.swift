//
//  AddOrEditPurposeroomController.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/27.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit
import XLForm
import MBProgressHUD
import SwiftyJSON
import Alamofire

class AddOrEditPurposeroomController: XLFormViewController  {
    
    var customerId:Int!
    var purposeroom:JSON!=JSON([String:JSON]())
    
    var progressHUD:MBProgressHUD!
    var deleteSection:XLFormSectionDescriptor!
    
    private enum Tag : String {
        case room_id = "room_id"
        case level = "level"
        case reason = "reason"
        
        
        static let allValues = {
            [room_id, level, reason].map
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
        
        section = XLFormSectionDescriptor.formSectionWithTitle("意向房源")
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
        
        section = XLFormSectionDescriptor.formSection()
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag:Tag.level.rawValue, rowType: XLFormRowDescriptorTypeSelectorAlertView, title: "意向级别")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:Tag.reason.rawValue, rowType: XLFormRowDescriptorTypeText, title: "考虑因素")
        section.addFormRow(row)
        
        section = XLFormSectionDescriptor.formSection()
        section.hidden=true
        self.deleteSection=section
        form.addFormSection(section)
        
        row=XLFormRowDescriptor(tag:nil, rowType:XLFormRowDescriptorTypeButton, title: "删除")
        row.cellConfig["textLabel.color"] = UIColor.redColor()
        row.action.formSelector = "doDeletePurposeroom:"
        section.addFormRow(row)
        
        self.form = form
        
    }
    
    func doDeletePurposeroom(sender: XLFormRowDescriptor) {
        if(self.progressHUD.alpha>0){
            return
        }
        let id=self.purposeroom["id"].intValue
        
        self.progressHUD.mode = .Indeterminate
        self.progressHUD.show(true)
        
        
        Alamofire.request(.POST, Router("customer/\(customerId)/purposeroom/\(id)/delete"),parameters:[app_counselor_id:Defaults.counselor!.id])
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
                        
                        util.netLoad("selroom/buildingunit?val=\(idParam)&roomstatus=Onshow"){json in
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
                        
                        util.netLoad("selroom/room?val=\(idParam)&roomstatus=Onshow"){json in
                            util.setOption(json, rowName: "room_id")
                        }
                    }
                }
            
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
        
        
        helper.run(2)
        
        let stringKeyAndValue:(String,JSON)->(AnyObject,String)={
            _,json in
            return (json["key"].stringValue,json["name"].stringValue)
        }
        
        helper.netLoadSelect(Tag.level.rawValue,module:"syenum",parameters:["type_key":"purposeroom_level"],translate:stringKeyAndValue)
        
        var appendStr="";
        if let room_id=self.purposeroom["room_id"].string{
            appendStr="?room_id="+RoomUtil.urlEndecord(room_id)
        }
        
        let util=RoomUtil(formView:self);
        helper.netLoad("room/selectoption"+appendStr) { json in
            util.setOption(json, dataName: "sellprojectSet", rowName: "sellproject")
            util.setOption(json, dataName: "buildingSet", rowName: "building")
            util.setOption(json, dataName: "buildingSet", rowName: "building")
            util.setOption(json, dataName: "buildingunitSet", rowName: "buildingunit")
            util.setOption(json, dataName: "roomSet", rowName: "room_id")
        }

        
    }
    
    func initData(){
        
        let util=FormUtil(formView:self)
        
        let stringSelect:(String,XLFormRowDescriptor)->AnyObject?={
            tag,row in
            if let selectOptions=row.selectorOptions as? [SelectOption]{
                var first=selectOptions[0]
                for option in selectOptions{
                    if option.value as! String == self.purposeroom[tag].stringValue{
                        return option;
                    }
                }
                return first;
            }
            return nil
        }
        util.setValue(Tag.level.rawValue,translate:stringSelect)
        
        
        if let room = self.purposeroom?["extension","room"]{
            util.setValue("sellproject"){
                tag,row in
                if let selectOptions=row.selectorOptions as? [SelectOption]{
                    for option in selectOptions{
                        if option.value as! String == room["projectid"].stringValue{
                            return option;
                        }
                    }
                }
                return nil
            }
            
            util.setValue("building"){
                tag,row in
                if let selectOptions=row.selectorOptions as? [SelectOption]{
                    for option in selectOptions{
                        if option.value as! String == room["buildingid"].stringValue{
                            return option;
                        }
                    }
                }
                return nil
            }
            
            util.setValue("buildingunit"){
                tag,row in
                if let selectOptions=row.selectorOptions as? [SelectOption]{
                    for option in selectOptions{
                        if option.value as! String == room["buildunitid"].stringValue{
                            return option;
                        }
                    }
                }
                return nil
            }
            
            util.setValue(Tag.room_id.rawValue){
                tag,row in
                if let selectOptions=row.selectorOptions as? [SelectOption]{
                    for option in selectOptions{
                        if option.value as! String == room["roomid"].stringValue{
                            return option;
                        }
                    }
                }
                return nil
            }
        }
        
        let stringSetVal:(String,XLFormRowDescriptor)->AnyObject?={tag,_ in return self.purposeroom[tag].stringValue}
        util.setValue(Tag.reason.rawValue,translate:stringSetVal)
        
        
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
        if let id=self.purposeroom["id"].int{
            param=["id":id]
        }
        var parameters=FormUtil(formView:self).formValues(Tag.allValues(),param:param)
        
        
        Alamofire.request(.POST, Router("customer/\(customerId)/purposeroom/save"), parameters: parameters,encoding:.JSON)
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
                        var temp:JSON=self.purposeroom
                        temp["id"]=JSON(returnId)
                        self.purposeroom=temp
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
        if let customer_id=self.purposeroom["id"].int{
            self.deleteSection.hidden=false
        }
    }
}
