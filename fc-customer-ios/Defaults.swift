//
//  Defaults.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/10.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit

class Defaults {
    class var userId: Int? {
        get { return NSUserDefaults.standardUserDefaults().valueForKey("userId") as? Int }
        set (value) { NSUserDefaults.standardUserDefaults().setValue(value, forKey: "userId") }
    }
}

