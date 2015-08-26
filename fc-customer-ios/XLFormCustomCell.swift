//
//  XLFormCustomCell.swift
//  XLForm ( https://github.com/xmartlabs/XLForm )
//
//  Copyright (c) 2014-2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
import XLForm

let XLFormRowDescriptorTypeCustom = "XLFormRowDescriptorTypeCustom"

class XLFormCustomCell : XLFormBaseCell {
    var leftLable:UILabel!
    var rightLable:UILabel!
  
    
    override func configure() {
        super.configure()
        leftLable=UILabel(frame:CGRectMake(15, 11, 136, 21))
        leftLable.font=UIFont(name: "System", size: 17.0)
        leftLable.textAlignment = NSTextAlignment.Left
        leftLable.autoresizingMask=UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleHeight;
        self.addSubview(leftLable)
        
        rightLable=UILabel(frame:CGRectMake(158, 11, 154, 21))
        rightLable.font=UIFont(name: "System", size: 17.0)
        rightLable.textAlignment = NSTextAlignment.Left
        rightLable.autoresizingMask=UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleHeight;
        self.addSubview(rightLable)
    }
    
    override func update() {
        super.update()
        // override
//        self.textLabel!.text = self.rowDescriptor.value != nil ? self.rowDescriptor.value as? String : "Am a custom cell, select me!"
    }
    
    
    override func formDescriptorCellDidSelectedWithFormController(controller: XLFormViewController!) {
        
        // custom code here
        // i.e new behaviour when cell has been selected
//        self.rowDescriptor.value = self.rowDescriptor.value as? String == "I can do any custom behaviour..." ? "Am a custom cell, select me!" : "I can do any custom behaviour..."
//        self.update()
//        controller.tableView .selectRowAtIndexPath(nil, animated: true, scrollPosition: UITableViewScrollPosition.None)
    }
    
}
