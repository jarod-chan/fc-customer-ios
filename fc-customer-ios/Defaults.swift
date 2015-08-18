//
//  Defaults.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/10.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit


class Defaults {
    class var counselor: Counselor? {
        get {
            let nsdata=NSUserDefaults.standardUserDefaults().objectForKey("counselor") as! NSData
            return NSKeyedUnarchiver.unarchiveObjectWithData(nsdata) as? Counselor
        }
        set (value) {
            let nsdata = NSKeyedArchiver.archivedDataWithRootObject(value!)
            NSUserDefaults.standardUserDefaults().setObject(nsdata, forKey: "counselor")
        }
    }
}


