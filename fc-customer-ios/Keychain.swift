//
//  Keychain.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/13.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit
import KeychainSwift

class Keychain {
    class var openid: String? {
        get { return KeychainSwift.get("openid")}
        set (value) { KeychainSwift.set(value!, forKey: "openid") }
    }
}
