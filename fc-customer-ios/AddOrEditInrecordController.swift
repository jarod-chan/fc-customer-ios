//
//  AddOrEditInrecordController.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/25.
//  Copyright (c) 2015年 jarod. All rights reserved.
//
import UIKit
import XLForm
import MBProgressHUD
import SwiftyJSON
import Alamofire

class AddOrEditInrecordController: XLFormViewController {
    
    var customerId:Int!
    var inrecord:JSON!=JSON([String:JSON]())
    
    var progressHUD:MBProgressHUD!
    var deleteSection:XLFormSectionDescriptor!
    
    private enum Tag : String {
        case type = "type"
        case description = "description"
        case result = "result"

        
        static let allValues = {
            [type, description, result].map
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
        
        section = XLFormSectionDescriptor.formSectionWithTitle("跟进记录")
        form.addFormSection(section)
        
        
        row = XLFormRowDescriptor(tag:"inrecordInfo", rowType: XLFormRowDescriptorTypeCustom)
        row.cellClass=XLFormCustomCell.self
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:Tag.type.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title: "跟进方式")
        row.required=true
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:Tag.description.rawValue, rowType: XLFormRowDescriptorTypeTextView, title: "跟进说明")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:Tag.result.rawValue, rowType: XLFormRowDescriptorTypeTextView, title: "跟进成果")
        row.required=true
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
        let id=self.inrecord["id"].intValue
        
        self.progressHUD.mode = .Indeterminate
        self.progressHUD.show(true)
        
        
        Alamofire.request(.POST, Router("customer/\(customerId)/inrecord/\(id)/delete"),parameters:[app_counselor_id:Defaults.counselor!.id])
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
        
        let stringKeyAndValue:(String,JSON)->(AnyObject,String)={
            _,json in
            return (json["key"].stringValue,json["name"].stringValue)
        }
        
        helper.netLoadSelect(Tag.type.rawValue,module:"inrecord/typeenum",translate:stringKeyAndValue)
        
    }
    
    func initData(){
        
        let util=FormUtil(formView:self)
        
        let stringSelect:(String,XLFormRowDescriptor)->AnyObject?={
            tag,row in
            if let selectOptions=row.selectorOptions as? [SelectOption]{
                var first=selectOptions[0]
                for option in selectOptions{
                    if option.value as! String == self.inrecord[tag].stringValue{
                        return option;
                    }
                }
                return first;
            }
            return nil
        }
        util.setValue(Tag.type.rawValue,translate:stringSelect)
        let stringSetVal:(String,XLFormRowDescriptor)->AnyObject?={tag,_ in return self.inrecord[tag].stringValue}
        util.setValue(Tag.description.rawValue,translate:stringSetVal)
        util.setValue(Tag.result.rawValue,translate:stringSetVal)
        
        let row = self.form.formRowWithTag("inrecordInfo")!
        row.cellConfig["leftLable.text"] = "跟进人："+inrecord["extension","updater_name"].stringValue
        row.cellConfig["rightLable.text"] = "跟进日期："+inrecord["extension","updater_date"].stringValue
        self.reloadFormRow(row)

        
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
        if let id=self.inrecord["id"].int{
            param=["id":id]
        }
        var parameters=FormUtil(formView:self).formValues(Tag.allValues(),param:param)
        
        
        Alamofire.request(.POST, Router("customer/\(customerId)/inrecord/save"), parameters: parameters,encoding:.JSON)
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
                        var temp:JSON=self.inrecord
                        temp["id"]=JSON(returnId)
                        self.inrecord=temp
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
        if let customer_id=self.inrecord["id"].int{
            self.deleteSection.hidden=false
        }
    }


}