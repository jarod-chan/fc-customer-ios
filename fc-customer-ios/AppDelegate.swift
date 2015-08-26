//
//  AppDelegate.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/8.
//  Copyright (c) 2015年 jarod. All rights reserved.
//

import UIKit
import Alamofire
import XLForm

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
     
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        if Keychain.openid != nil{
            window?.rootViewController=UIStoryboard(name:"Main",bundle:NSBundle.mainBundle()).instantiateInitialViewController() as? UIViewController
        }else{
            window?.rootViewController=UIStoryboard(name:"Main",bundle:NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LoginController") as? UIViewController
        }
    
        window?.makeKeyAndVisible()
        
        return true
    }
    
}

