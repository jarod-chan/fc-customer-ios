//
//  Router.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/13.
//  Copyright (c) 2015年 jarod. All rights reserved.
//
import Alamofire

class Router: URLStringConvertible {
    static let baseURLString = "http://app.fyg.cn:9997/fc-customer/public/service/"
    
    static let homeURLString = "http://app.fyg.cn:9997/fc-customer/public/"
    
    let module:String!
    
    init(_ module:String){
        self.module = module
    }
    
    var URLString: String {
         return Router.baseURLString+"\(module)"
    }

    

}
