//
//  InrecordController.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/25.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON
import Alamofire

class InrecordController: UIViewController,UITableViewDataSource {
    
    var customerId:Int!
    var progressHUD:MBProgressHUD!
    
    var inrecordList:[JSON]!=[JSON]()
    
    @IBOutlet weak var tableView: UITableView!
   
    override func viewWillAppear(animated: Bool) {
        self.loadDate()
    }
    
    func loadDate(){
        self.progressHUD=MBProgressHUD(view:self.view)
        self.view.addSubview(self.progressHUD)
        
        self.progressHUD.mode = .Indeterminate
        self.progressHUD.show(true)
        
        
        Alamofire.request(.GET,Router("customer/\(customerId)/inrecord"),parameters:[app_counselor_id : Defaults.counselor!.id])
            .responseJSON { _, _, ret,error in
                self.inrecordList.removeAll(keepCapacity: true)
                let json=JSON(ret!);
                for(index:String,subJson:JSON) in json{
                    self.inrecordList.append(subJson)
                }
                self.tableView.reloadData();
                self.progressHUD.hide(true)
                
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return self.inrecordList.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 5;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellData=self.inrecordList[indexPath.section]
        let index=indexPath.row
        
        
        if index>0{
            var cell:UITableViewCell!
            switch index{
            case 1:
                cell = getReuseTableCell("inrecordInfo")
                var firstLabel=cell.viewWithTag(1) as! UILabel
                var secondLabel=cell.viewWithTag(2) as! UILabel
                firstLabel.text="跟进人："+cellData["extension","updater_name"].stringValue
                secondLabel.text="跟进日期："+cellData["extension","updater_date"].stringValue
            case 2:
                cell = getReuseTableCell("inrecordText")
                var firstLabel=cell.viewWithTag(1) as! UILabel
                firstLabel.text="跟进方式："+cellData["extension","type_name"].stringValue
            case 3:
                cell = getReuseTableCell("inrecordText")
                var firstLabel=cell.viewWithTag(1) as! UILabel
                firstLabel.text="跟进说明："+cellData["description"].stringValue
            case 4:
                cell = getReuseTableCell("inrecordText")
                var firstLabel=cell.viewWithTag(1) as! UILabel
                firstLabel.text="跟进结果："+cellData["result"].stringValue
            default:
                println("index:\(index) out of array")
            }
            return cell
        }
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("inrecordId") as! UITableViewCell
        var idLabel=cell.viewWithTag(1) as! UILabel
        idLabel.text=String(cellData["id"].intValue)
        return cell
        
    }
    
    func getReuseTableCell(indentifier:String)->UITableViewCell{
        return self.tableView.dequeueReusableCellWithIdentifier(indentifier) as! UITableViewCell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let vc=segue.destinationViewController as? AddOrEditInrecordController{
            let indentifier=segue.identifier;
            if indentifier == "addInrecord"{
                vc.customerId=self.customerId
                vc.inrecord=JSON(["id":NSNull(), "extension":["updater_name":Defaults.counselor!.name]])

            }else if indentifier == "editInrecord"{
                var indexPath=self.tableView.indexPathForSelectedRow()
                if let sectionIndex=indexPath?.section {
                    vc.customerId=self.customerId
                    vc.inrecord=self.inrecordList[sectionIndex]
                }
            }
        }
    }
}
