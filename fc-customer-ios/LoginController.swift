//
//  LoginController.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/10.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class LoginController: UIViewController {
    
    
    @IBOutlet weak var openIdTextLable: UITextField!
    
    @IBOutlet weak var warnTextLable: UILabel!
    
    @IBAction func doLogin(sender: UIButton) {
        var openid=openIdTextLable.text
        
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        Alamofire.request(.POST, Router("isregister"),parameters:["openid":openid])
            .responseJSON { _, _, ret,error in
                if(error != nil){
                    progressHUD.labelText = "网络错误"
                    progressHUD.mode = .Text
                    progressHUD.hide(true, afterDelay: 2)
                    return;
                }
                
                var json = JSON(ret!)
                var result = json["result"].bool!
                if result {
                    self.storeOpenidAndCounselor(openid,json:json["data"])
                    progressHUD.hide(true)
                    
                    let vc=self.storyboard!.instantiateViewControllerWithIdentifier("NaviController") as! UIViewController
                    self.presentViewController(vc, animated: true, completion: nil)
                }else{
                    progressHUD.hide(true)
                    var message=json["message"].string!
                    self.warnTextLable.text=message
                    self.warnTextLable.hidden=false
                    NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("update"), userInfo: nil, repeats: false)
                }
        }
        
    }
    
    func storeOpenidAndCounselor(openid:String,json:JSON) {
        Keychain.openid=openid
        Defaults.counselor = Counselor(id: json["id"].int!, name:json["name"].string!, role: json["role"].string!)
    }
    
    
    func update(){
        self.warnTextLable.text = ""
        self.warnTextLable.hidden = true
    }
    

    
}