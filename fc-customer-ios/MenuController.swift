//
//  MenuController.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/10.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit
import KeychainSwift

class MenuController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let openid=KeychainSwift.get("openid")
        
        println(openid)
        
        if openid==nil{
            let vc=storyboard!.instantiateViewControllerWithIdentifier("LoginController") as! UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
