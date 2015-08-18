import XLForm
import Alamofire
import SwiftyJSON
import MBProgressHUD

class AddCustomerController : XLFormViewController {
    
    private var menuSection:XLFormSectionDescriptor!
    
    private var progressHUD:MBProgressHUD!
    
    
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
        
        form = XLFormDescriptor(title: "新增客户")
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
        row.value=Defaults.counselor!.name
        row.hidden = "$showMore==0"
        section.addFormRow(row)
        
        section = XLFormSectionDescriptor.formSection()
        section.hidden=true
        menuSection=section
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag:nil, rowType: XLFormRowDescriptorTypeButton, title: "意向信息")
        row.action.formSegueIdenfifier = "NativeEventNavigationViewControllerSegue"
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:nil, rowType: XLFormRowDescriptorTypeButton, title: "意向房源")
        row.action.formSegueIdenfifier = "NativeEventNavigationViewControllerSegue"
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:nil, rowType: XLFormRowDescriptorTypeButton, title: "跟进记录")
        row.action.formSegueIdenfifier = "NativeEventNavigationViewControllerSegue"
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag:nil, rowType: XLFormRowDescriptorTypeButton, title: "成交记录")
        row.action.formSegueIdenfifier = "NativeEventNavigationViewControllerSegue"
        section.addFormRow(row)
        
        self.form = form
        
        
    }
    
    
    func initSelectAlertView(){
        let helper=UIHelper(formView:self)
        
        helper.startLoad(4,progressHUD:self.progressHUD)
        
        helper.netLoadSelect(Tags.CounselorId.rawValue,module:"counselor"){
            (index,json:JSON,defaultIndex) in
            let id=json["id"].intValue
            if(id == Defaults.counselor!.id){
                defaultIndex=index.toInt()!
            }
            return (json["id"].intValue,json["name"].stringValue)
        }
        
        helper.netLoadSelect(Tags.State.rawValue,module:"customer/states"){
            (_,json,_) in
            return (json["key"].stringValue,json["name"].stringValue)
        }
        
        helper.netLoadSelect(Tags.From.rawValue,module:"syenum",parameters:["type_key":"customer_from"]){
            (_,json,_) in
            return (json["key"].stringValue,json["name"].stringValue)
        }
        
        helper.netLoadSelect(Tags.Way.rawValue,module:"syenum",parameters:["type_key":"customer_way"]){
            (_,json,_) in
            return (json["key"].stringValue,json["name"].stringValue)
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
        var parameters=FormUtil(formView:self).formValues(Tags.allValues())
        

        
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
                    println(json)
                    self.menuSection.hidden=false;
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
    
}
