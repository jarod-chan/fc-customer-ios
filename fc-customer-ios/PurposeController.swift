//
//  PurposeController.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/21.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import SwiftyJSON

class PurposeController:UIViewController,UITableViewDataSource{
    
    var customerId:Int!
    var progressHUD:MBProgressHUD!
    
    var purposeList:[JSON]!=[JSON]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        self.loadDate()
    }
    
    func loadDate(){
        self.progressHUD=MBProgressHUD(view:self.view)
        self.view.addSubview(self.progressHUD)
        
        self.progressHUD.mode = .Indeterminate
        self.progressHUD.show(true)
        
        
        Alamofire.request(.GET,Router("customer/\(customerId)/purpose"),parameters:[app_counselor_id : Defaults.counselor!.id])
            .responseJSON { _, _, ret,error in
                self.purposeList.removeAll(keepCapacity: true)
                let json=JSON(ret!);
                for(index:String,subJson:JSON) in json{
                    self.purposeList.append(subJson)
                }
                self.tableView.reloadData();
                self.progressHUD.hide(true)
                
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return self.purposeList.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 8;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellData=self.purposeList[indexPath.section]
        let index=indexPath.row
        
        
        if index>0{
            let cell = self.tableView.dequeueReusableCellWithIdentifier("purposeContent") as! UITableViewCell
            var firstLabel=cell.viewWithTag(1) as! UILabel
            var secondLabel=cell.viewWithTag(2) as! UILabel
            switch index{
            case 1:
                firstLabel.text="客户级别："+cellData["extension","khjb"].stringValue
                secondLabel.text="意向强度："+cellData["extension","yxqd"].stringValue
            case 2:
                firstLabel.text="购房动机："+cellData["extension","gfdj"].stringValue
                secondLabel.text="住宅类型："+cellData["extension","zzlx"].stringValue
            case 3:
                firstLabel.text="户型类型:"+cellData["extension","hxlx"].stringValue
                secondLabel.text="面积:"+cellData["mj"].stringValue
            case 4:
                firstLabel.text="单价:"+cellData["dj"].stringValue
                secondLabel.text="总价:"+cellData["zj"].stringValue
            case 5:
                firstLabel.text="地段:"+cellData["dd"].stringValue
                secondLabel.text="楼层:"+cellData["extension","jzfg"].stringValue
            case 6:
                firstLabel.text="精装修:"+cellData["extension","jzx"].stringValue
                secondLabel.text="优惠力度:"+cellData["extension","yhld"].stringValue
            case 7:
                firstLabel.text="开盘时间:"+cellData["kpsj"].stringValue
                secondLabel.text="学区房:"+cellData["extension","xqf"].stringValue
            default:
                println("index:\(index) out of array")
            }
            return cell
        }
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("purposeId") as! UITableViewCell
        var idLabel=cell.viewWithTag(1) as! UILabel
        idLabel.text=String(cellData["id"].intValue)
        return cell
    
    }
    
 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
 
        if let vc=segue.destinationViewController as? AddOrEditPurposeController{
            let indentifier=segue.identifier;
            if indentifier == "addPurpose"{
                vc.customerId=self.customerId
            }else if indentifier == "editPurpose"{
                var indexPath=self.tableView.indexPathForSelectedRow()
                if let sectionIndex=indexPath?.section {
                    vc.customerId=self.customerId
                    vc.purpose=self.purposeList[sectionIndex]
                }
            }
        }
    }
    
    

}
