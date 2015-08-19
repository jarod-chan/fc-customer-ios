//
//  StringExtension.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/19.
//  Copyright (c) 2015年 jarod. All rights reserved.
//
import Foundation

extension String {
    
    func trim() -> String {
        return  self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}
