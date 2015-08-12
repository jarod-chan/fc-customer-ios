//
//  LoginController.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/10.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit
import KeychainSwift

class LoginController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var openIdTextLable: UITextField!
    
    @IBOutlet weak var warnTextLable: UILabel!
    
    @IBAction func doLogin(sender: UIButton) {
        var openid=openIdTextLable.text
        var stroryboard = self.storyboard
        if(isRegister(openid)){
            
             KeychainSwift.set(openid, forKey: "openid")
            
            let vc=stroryboard!.instantiateViewControllerWithIdentifier("NaviController") as! UIViewController
          //  self.navigationController?.pushViewController(vc, animated: true);
            self.presentViewController(vc, animated: true, completion: nil)
  
        }else{
            warnTextLable.hidden=false;
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: false)
        }
    }
    
    func update(){
         warnTextLable.hidden=true;
    }
    
    func isRegister(openid:String)->Bool{
        return openid == "a1";
    }
    
    
}