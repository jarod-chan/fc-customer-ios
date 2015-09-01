import XLForm
import Alamofire
import SwiftyJSON
import MBProgressHUD

class AddOrEditCustomerController : XLFormViewController {
    
    private var menuSection:XLFormSectionDescriptor!
    
    private var progressHUD:MBProgressHUD!
    
    var customer:JSON!
    
    
    private enum Tags : String {
        case Name = "name"
        case Remark = "remark"
        case Phone = "phone"
        case CounselorId="counselor_id"
        case State="state"
        
        case QQ="qq"
        case Email = "email"
        case Weixin = "weixin"
        case From="from"
        case Way="way"
        
        static let allValues = {
            [Name, Remark, Phone,CounselorId,State,QQ,Email,Weixin,From,Way].map
                { (tag:Tags)->String in
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
        
        form = XLFormDescriptor(title: "")
        form.assignFirstResponderOnShow = false
        
        section = XLFormSectionDescriptor.formSectionWithTitle("客户信息")
        form.addFormSection(section)
        

        row = XLFormRowDescriptor(tag: Tags.Name.rawValue, rowType: XLFormRowDescriptorTypeText, title: "姓名")
        row.cellConfigAtConfigure["textField.placeholder"] = "必填"
        row.required = true
        section.addFormRow(row)
        
        
        row = XLFormRowDescriptor(tag: Tags.Remark.rawValue, rowType: XLFormRowDescriptorTypeText, title: "备注")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Phone.rawValue, rowType: XLFormRowDescriptorTypePhone, title: "电话")
        row.cellConfigAtConfigure["textField.placeholder"] = "必填"
        row.required = true
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.CounselorId.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title:"顾问")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.State.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title:"状态")
        row.required=true
        section.addFormRow(row)

        
        row = XLFormRowDescriptor(tag:"showMore", rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "显示更多")
        row.value = 0
        section.addFormRow(row)
        
        
        row = XLFormRowDescriptor(tag: Tags.QQ.rawValue, rowType: XLFormRowDescriptorTypeText, title: "qq")
        row.hidden = "$showMore==0"
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Email.rawValue, rowType: XLFormRowDescriptorTypeEmail, title: "邮箱")
        row.addValidator(XLFormValidator.emailValidator())
         row.hidden = "$showMore==0"
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Weixin.rawValue, rowType: XLFormRowDescriptorTypeText, title: "微信")
         row.hidden = "$showMore==0"
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.From.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title:"来源")
         row.hidden = "$showMore==0"
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Way.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title:"途径")
         row.hidden = "$showMore==0"
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:"counselor_name",rowType:XLFormRowDescriptorTypeInfo, title:"登记人")
        row.hidden = "$showMore==0"
        section.addFormRow(row)
        
        section = XLFormSectionDescriptor.formSection()
        section.hidden=true
        menuSection=section
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag:nil, rowType: XLFormRowDescriptorTypeButton, title: "意向信息")
        row.action.formSegueIdenfifier = "purposeController"
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:nil, rowType: XLFormRowDescriptorTypeButton, title: "意向房源")
        row.action.formSegueIdenfifier = "purposeroomController"
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:nil, rowType: XLFormRowDescriptorTypeButton, title: "跟进记录")
        row.action.formSegueIdenfifier = "inrecordController"
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag:nil, rowType: XLFormRowDescriptorTypeButton, title: "成交记录")
        row.action.formSegueIdenfifier = "dealrecordController"
        section.addFormRow(row)
        
        self.form = form
        
        
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
        
        
        helper.run(5)
        
        
        helper.netLoadSelect(Tags.CounselorId.rawValue,module:"counselor"){
            _,json in
            return (json["id"].intValue,json["name"].stringValue)
        }
        
        helper.netLoadSelect(Tags.State.rawValue,module:"customer/states"){
            _,json in
            return (json["key"].stringValue,json["name"].stringValue)
        }
        
        helper.netLoadSelect(Tags.From.rawValue,module:"syenum",parameters:["type_key":"customer_from"]){
            _,json in
            return (json["key"].stringValue,json["name"].stringValue)
        }
        
        helper.netLoadSelect(Tags.Way.rawValue,module:"syenum",parameters:["type_key":"customer_way"]){
            _,json in
            return (json["key"].stringValue,json["name"].stringValue)
        }
        
        var counselor_id=customer["counselor_id"].intValue
        helper.netLoadText("counselor_name",module:"counselor/\(counselor_id)"){
            row,json in
            row.value=json["name"].stringValue
        }
        
        
    }
    
    func initData(){
        let util=FormUtil(formView:self)
        let stringSetVal:(String,XLFormRowDescriptor)->AnyObject?={tag,_ in return self.customer[tag].stringValue}
        
        util.setValue(Tags.Name.rawValue,translate:stringSetVal)
        util.setValue(Tags.Remark.rawValue,translate:stringSetVal)
        util.setValue(Tags.Phone.rawValue,translate:stringSetVal)
        
        let intSelect:(String,XLFormRowDescriptor)->AnyObject?={
            tag,row in
            if let selectOptions=row.selectorOptions as? [SelectOption]{
                var first=selectOptions[0]
                for option in selectOptions{
                    if option.value as! Int == self.customer[tag].intValue{
                        return option;
                    }
                }
                return first;
            }
            return nil
        }
        
        let stringSelect:(String,XLFormRowDescriptor)->AnyObject?={
            tag,row in
            if let selectOptions=row.selectorOptions as? [SelectOption]{
                var first=selectOptions[0]
                for option in selectOptions{
                    if option.value as! String == self.customer[tag].stringValue{
                        return option;
                    }
                }
                return first;
            }
            return nil
        }
        
        util.setValue(Tags.CounselorId.rawValue,translate:intSelect)
        util.setValue(Tags.State.rawValue,translate:stringSelect)
        
        util.setValue(Tags.QQ.rawValue,translate:stringSetVal)
        util.setValue(Tags.Email.rawValue,translate:stringSetVal)
        util.setValue(Tags.Weixin.rawValue,translate:stringSetVal)
        
        util.setValue(Tags.Way.rawValue,translate:stringSelect)
        util.setValue(Tags.From.rawValue,translate:stringSelect)
        
        if Defaults.counselor!.isSale() {
            let row = self.form.formRowWithTag(Tags.CounselorId.rawValue)
            if var selectOptions=row?.selectorOptions  as? [SelectOption]{
                selectOptions = selectOptions.filter({option in
                    let counselorId=self.customer[Tags.CounselorId.rawValue].intValue;
                    if option.value as! Int == counselorId{
                        return true
                    }
                    return false
                })
                row?.selectorOptions = selectOptions
            }
            self.reloadFormRow(row)
        }
        
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
        if let id=self.customer["id"].int{
            param=["id":id]
        }
        var parameters=FormUtil(formView:self).formValues(Tags.allValues(),param:param)
        
        
        Alamofire.request(.POST, Router("customer/save"), parameters: parameters,encoding:.JSON)
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
                        var temp:JSON=self.customer
                        temp["id"]=JSON(returnId)
                        self.customer=temp
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

        if let customer_id=self.customer["id"].int{
            self.title = self.customer["name"].stringValue
            self.menuSection.hidden=false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indentifier=segue.identifier;
        switch indentifier! {
        case "purposeController":
            if let vc=segue.destinationViewController as? PurposeController{
                vc.customerId=self.customer["id"].intValue
            }
        case "purposeroomController":
            if let vc=segue.destinationViewController as? PurposeroomController{
                vc.customerId=self.customer["id"].intValue
            }
        case "inrecordController":
            if let vc=segue.destinationViewController as? InrecordController{
                vc.customerId=self.customer["id"].intValue
            }
        case "dealrecordController":
            if let vc=segue.destinationViewController as? DealrecordController{
                vc.customerId=self.customer["id"].intValue
            }
        default:
            println("segue:\(indentifier) do nothing")
        }
    }
    
}
