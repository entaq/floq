//
//  FoundationTypes+Extensions.swift
//  Floq
//
//  Created by Mensah Shadrach on 30/12/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import Foundation


extension Dictionary where Key == String{
    
    func getString(_ id:Fields)->String{
        if let field = self[id.rawValue] as? String{
            return field
        }
        return ""
    }
    
    func getDate(_ id:Fields)->Date{
        if let field = self[id.rawValue] as? Date{
            return field
        }
        return Date.init(timeIntervalSince1970: 0)
    }
    
    func getArray(_ id:Fields)->[Any]{
        if let field = self[id.rawValue] as? [Any]{
            return field
        }
        return []
    }
    
    func getDouble(id:Fields)->Double{
        if let field = self[id.rawValue] as? Double{
            return field
        }
        return 0.000001
    }
    
    func getInt(_ id:Fields)->Int{
        if let field = self[id.rawValue] as? Int{
            return field
        }
        return 0
    }
    
    func getInt64(_ id:Fields)->Int64{
        if let field = self[id.rawValue] as? Int64{
            return field
        }
        return 0
    }
    
    
    func getBoolena(_ id:Fields)->Bool{
        if let field = self[id.rawValue] as? Bool{
            return field
        }
        return false
    }
    
    func allKeys()->Aliases.stray{
        return (self as NSDictionary).allKeys as! Aliases.stray
    }
}


extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    
    
}

extension Array where Element == FLCliqItem{
    
    
}

extension UserDefaults{
    
    public class var uid:String{
        return standard.string(forKey: Fields.uid.rawValue)!
       
    }
    
    public class var instanceToken:String{
        return standard.string(forKey: Fields.instanceToken.rawValue) ?? ""
    }
    
    public class var username:String{
        return standard.string(forKey: Fields.username.rawValue)!
    }
    
    class func set(_ value:Any, for field:Fields){
        standard.set(value, forKey: field.rawValue)
    }
    
    public class func invalidateUserData(){
        standard.removeObject(forKey: Fields.username.rawValue)
        standard.removeObject(forKey: Fields.uid.rawValue) 
    }
}
