//
//  Purposeroom.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/21.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON
import Alamofire

class PurposeroomController: UIViewController,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var customerId:Int!
    var progressHUD:MBProgressHUD!
    
    var purposeroomList:[JSON]!=[JSON]()
    

    
    override func viewWillAppear(animated: Bool) {
        self.loadDate()
    }
    
    func loadDate(){
        self.progressHUD=MBProgressHUD(view:self.view)
        self.view.addSubview(self.progressHUD)
        
        self.progressHUD.mode = .Indeterminate
        self.progressHUD.show(true)
        
 
        Alamofire.request(.GET,Router("customer/\(customerId)/purposeroom"))
            .responseJSON { _, _, ret,error in
                if(error != nil){
                    println(error)
                    self.progressHUD.labelText = "网络错误"
                    self.progressHUD.mode = .Text
                    self.progressHUD.hide(true, afterDelay: 2)
                    return;
                }
                self.purposeroomList.removeAll(keepCapacity: true)
                let json=JSON(ret!);
                for(index:String,subJson:JSON) in json{
                    self.purposeroomList.append(subJson)
                }
                self.tableView.reloadData();
                self.progressHUD.hide(true)
                
        }
    }
    

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return self.purposeroomList.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 4;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellData=self.purposeroomList[indexPath.section]
        let index=indexPath.row
        
        
        if index>0{
            var cell:UITableViewCell!
            switch index{
            case 1:
                cell = getReuseTableCell("purposeroomText")
                var firstLabel=cell.viewWithTag(1) as! UILabel
                let roomarr=[
                    cellData["extension","room","project_name"].stringValue,
                    cellData["extension","room","building_name"].stringValue,
                    cellData["extension","room","buildingunit_name"].stringValue,
                    cellData["extension","room","room_name"].stringValue
                ].reduce(""){ (sum, x) -> String in
                        return sum+x
                }
                
                firstLabel.text="房间："+roomarr
                
            case 2:
                cell = getReuseTableCell("purposeroomInfo")
                var firstLabel=cell.viewWithTag(1) as! UILabel
                var secondLabel=cell.viewWithTag(2) as! UILabel
                firstLabel.text="面积："+cellData["extension","room","buildingArea"].stringValue
                secondLabel.text="总价："+cellData["extension","room","totalAmount"].stringValue
            case 3:
                cell = getReuseTableCell("purposeroomInfo")
                var firstLabel=cell.viewWithTag(1) as! UILabel
                var secondLabel=cell.viewWithTag(2) as! UILabel
                firstLabel.text="意向级别："+cellData["extension","level_name"].stringValue
                secondLabel.text="考虑因素："+cellData["reason"].stringValue
            default:
                println("index:\(index) out of array")
            }
            return cell
        }
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("purposeroomId") as! UITableViewCell
        var idLabel=cell.viewWithTag(1) as! UILabel
        idLabel.text=String(cellData["id"].intValue)
        return cell
        
    }
    
    func getReuseTableCell(indentifier:String)->UITableViewCell{
        return self.tableView.dequeueReusableCellWithIdentifier(indentifier) as! UITableViewCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let vc=segue.destinationViewController as? AddOrEditPurposeroomController{
            let indentifier=segue.identifier;
            if indentifier == "addPurposeroom"{
                vc.customerId=self.customerId
            }else if indentifier == "editPurpsoeroom"{
                var indexPath=self.tableView.indexPathForSelectedRow()
                if let sectionIndex=indexPath?.section {
                    vc.customerId=self.customerId
                    vc.purposeroom=self.purposeroomList[sectionIndex]
                }
            }
        }
    }


}
