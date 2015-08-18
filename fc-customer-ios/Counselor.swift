//
//  c.swift
//  fc-customer-ios
//
//  Created by jarod_chan on 15/8/13.
//  Copyright (c) 2015年 jarod. All rights reserved.
//
//  置业顾问对象
import Foundation

class Counselor: NSObject {
    
    var id:Int
    var name:String
    var role:String
    
    func encodeWithCoder(coder: NSCoder){
        coder.encodeInteger(self.id, forKey: "id")
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.role, forKey: "role")
        
    }
    
    required init(coder decoder: NSCoder){
        self.id = decoder.decodeIntegerForKey("id")
        self.name = decoder.decodeObjectForKey("name") as! String
        self.role = decoder.decodeObjectForKey("role") as! String
        
    }
    
    init (id:Int,name:String,role:String){
        self.id=id
        self.name=name
        self.role=role
    }
    
    static let roleList:[String:String]=["s":"销售顾问","m":"销售经理"]
    
    var roleName:String?{
        return Counselor.roleList[self.role]
    }
    
    func isSale()->Bool{
        return self.role=="s";
    }
    
    func isManager()->Bool{
        return self.role=="m";
    }

}

