import XLForm


class AddCustomerController : XLFormViewController {
    
    var hideMore=true;
    
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
        section.addFormRow(row)
        
        
        row = XLFormRowDescriptor(tag: Tags.Remark.rawValue, rowType: XLFormRowDescriptorTypeText, title: "备注")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Phone.rawValue, rowType: XLFormRowDescriptorTypePhone, title: "电话")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.CounselorId.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title:"顾问")
        row.selectorOptions = ["Option 1", "Option 2", "Option 3", "Option 4", "Option 5"]
        row.value = "Option 3"
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.State.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title:"状态")
        row.selectorOptions = ["Option 1", "Option 2", "Option 3", "Option 4", "Option 5"]
        row.value = "Option 3"
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:nil, rowType: XLFormRowDescriptorTypeButton, title:"更多>>")
         row.action.formSelector = "didTouchButton:"
        section.addFormRow(row)
        
        
        row = XLFormRowDescriptor(tag: Tags.QQ.rawValue, rowType: XLFormRowDescriptorTypeText, title: "qq")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Email.rawValue, rowType: XLFormRowDescriptorTypeEmail, title: "邮箱")
        row.addValidator(XLFormValidator.emailValidator())
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Weixin.rawValue, rowType: XLFormRowDescriptorTypeText, title: "微信")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.From.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title:"来源")
        row.selectorOptions = ["Option 1", "Option 2", "Option 3", "Option 4", "Option 5"]
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Way.rawValue, rowType:XLFormRowDescriptorTypeSelectorAlertView, title:"途径")
        row.selectorOptions = ["Option 1", "Option 2", "Option 3", "Option 4", "Option 5"]
        row.value = "Option 3"
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag:"counselor_name",rowType:XLFormRowDescriptorTypeInfo, title:"登记人")
        row.value="张三"
        section.addFormRow(row)

        
        self.form = form
        displayHideMore()
        
    }
    
    func didTouchButton(sender: XLFormRowDescriptor) {
        self.hideMore = !self.hideMore;
        displayHideMore()
        
    }
    
    func displayHideMore(){
        
        var QQ=self.form.formRowWithTag(Tags.QQ.rawValue)!
        QQ.hidden=self.hideMore
        var Email=self.form.formRowWithTag(Tags.Email.rawValue)!
        Email.hidden=self.hideMore
        var Weixin=self.form.formRowWithTag(Tags.Weixin.rawValue)!
        Weixin.hidden=self.hideMore
        var From=self.form.formRowWithTag(Tags.From.rawValue)!
        From.hidden=self.hideMore
        var Way=self.form.formRowWithTag(Tags.Way.rawValue)!
        Way.hidden=self.hideMore
        var counselor_name=self.form.formRowWithTag("counselor_name")!
        counselor_name.hidden=self.hideMore
    
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"保存",style: UIBarButtonItemStyle.Plain, target: self, action: "savePressed:")
        
        //UIBarButtonItem(title: <#String?#>, style: UIBarButtonItemStyle, target: <#AnyObject?#>, action: <#Selector#>)
    }
    
    func savePressed(button: UIBarButtonItem)
    {
        let validationErrors : Array<NSError> = self.formValidationErrors() as! Array<NSError>
        if (validationErrors.count > 0){
            self.showFormValidationError(validationErrors.first)
            return
        }
        self.tableView.endEditing(true)
        let alertView = UIAlertView(title: "Valid Form", message: "No errors found", delegate: self, cancelButtonTitle: "OK")
        alertView.show()
    }
    
}
