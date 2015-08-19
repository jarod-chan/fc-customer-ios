//
//  ListCustomerController.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/18.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD


class ListCustomerController:UIViewController,UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    
    var state:String!

    var progressHUD:MBProgressHUD!
    var customerList=[JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressHUD=MBProgressHUD(view:self.view)
        self.view.addSubview(self.progressHUD)
        
        self.progressHUD.mode = .Indeterminate
        self.progressHUD.show(true)
        
        
        Alamofire.request(.GET,Router("customer/list/\(state)"),parameters:["app_counselor_id":Defaults.counselor!.id])
            .responseJSON { _, _, ret,error in
                
                let json=JSON(ret!);
                for(index:String,subJson:JSON) in json{
                    self.customerList.append(subJson)
                }
                self.tableView.reloadData();
                self.progressHUD.hide(true)
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return customerList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("customerCell") as! UITableViewCell
        
        var customer=self.customerList[indexPath.row]
        
        var titleLable=cell.viewWithTag(1) as! UILabel
        var detailLable=cell.viewWithTag(2) as! UILabel
        
        var name=customer["name"].stringValue
        var remark=customer["remark"].stringValue.trim();
        var title="客户：\(name)";
        if (!remark.isEmpty){
            title=title+"(\(remark))"
        }
        titleLable.text=title
        
        var update_at=customer["update_at"].stringValue
        detailLable.text="更新时间：\(update_at)"
    
        
        return cell
    }

}
