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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let sugue=segue.identifier;
        
        if(sugue=="purpose" || sugue=="sign" || sugue=="public"){
            if let vc=segue.destinationViewController as? ListCustomerController{
                vc.state=sugue
            }
        }

    }

}
