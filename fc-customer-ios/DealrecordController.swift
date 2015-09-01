//
//  DealrecordController.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/28.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON
import Alamofire

class DealrecordController: UIViewController,UITableViewDataSource  {
    
    var customerId:Int!
    var progressHUD:MBProgressHUD!
    
    var dealrecordList:[JSON]!=[JSON]()
    
    @IBOutlet weak var tableView: UITableView!

    
    override func viewWillAppear(animated: Bool) {
        self.progressHUD=MBProgressHUD(view:self.view)
        self.view.addSubview(self.progressHUD)

        self.loadDate()
    }
    
    func loadDate(){
        
        Service(progressHUD: self.progressHUD).netLoad("customer/\(customerId)/dealrecord",parameters:[app_counselor_id : Defaults.counselor!.id]){
            json in
            self.dealrecordList.removeAll(keepCapacity: true) 
            for(index:String,subJson:JSON) in json{
                self.dealrecordList.append(subJson)
            }
            self.tableView.reloadData();
        }

    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return self.dealrecordList.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 5+self.dealrecordList[section]["extension","room","payList"].count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellData=self.dealrecordList[indexPath.section]
        let index=indexPath.row
        
        if index>0{
            var cell:UITableViewCell!
            switch index{
            case 1:
                cell = getReuseTableCell("dealrecordText")
                var firstLabel=cell.viewWithTag(1) as! UILabel
                firstLabel.text="："+cellData["extension","type_name"].stringValue
                let roomarr=[
                    cellData["extension","room","project_name"].stringValue,
                    cellData["extension","room","building_name"].stringValue,
                    cellData["extension","room","buildunit_name"].stringValue,
                    cellData["extension","room","roomName"].stringValue
                    ].reduce(""){ (sum, x) -> String in
                        return sum+x
                }

                firstLabel.text="房间："+roomarr
            case 2:
                cell = getReuseTableCell("dealrecordInfo")
                var firstLabel=cell.viewWithTag(1) as! UILabel
                var secondLabel=cell.viewWithTag(2) as! UILabel
                firstLabel.text="客户："+cellData["extension","room","customer"].stringValue
                secondLabel.text="状态："+cellData["extension","room","purchaseState"].stringValue
            case 3:
                cell = getReuseTableCell("dealrecordInfo")
                var firstLabel=cell.viewWithTag(1) as! UILabel
                var secondLabel=cell.viewWithTag(2) as! UILabel
                firstLabel.text="总价："+cellData["extension","room","contractTotalAmount"].stringValue
                secondLabel.text="未付："+cellData["extension","room","totalUnRevAmount"].stringValue
            case 4:
                cell = getReuseTableCell("payTitle")
                var firstLabel=cell.viewWithTag(1) as! UILabel
                firstLabel.text="收款明细"
            default:
                cell = getReuseTableCell("payItem")
                let payItem=cellData["extension","room","payList",index-5]
                
                var firstLabel=cell.viewWithTag(1) as! UILabel
                var secondLabel=cell.viewWithTag(2) as! UILabel
                var thridLabel=cell.viewWithTag(3) as! UILabel
                firstLabel.text=payItem["moneyDefine"].stringValue
                secondLabel.text=payItem["revAmount"].stringValue
                thridLabel.text=payItem["revDate"].stringValue
            }
            return cell
        }
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("dealrecordId") as! UITableViewCell
        var idLabel=cell.viewWithTag(1) as! UILabel
        idLabel.text=String(cellData["id"].intValue)
        return cell
        
    }
    
    func getReuseTableCell(indentifier:String)->UITableViewCell{
        return self.tableView.dequeueReusableCellWithIdentifier(indentifier) as! UITableViewCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indentifier=segue.identifier;
        if indentifier == "addDealrecord"{
            if let vc=segue.destinationViewController as? AddDealrecordController{
                vc.customerId=self.customerId
            }
        }else if indentifier == "viewDealrecord"{
            var indexPath=self.tableView.indexPathForSelectedRow()
            if let sectionIndex=indexPath?.section {
                if let vc=segue.destinationViewController as? ViewDealrecordController{
                                    vc.customerId=self.customerId
                                    vc.dealrecord=self.dealrecordList[sectionIndex]
                }
            }
        }

        

    }

}
