//
//  FoundationTypes+Extensions.swift
//  Floq
//
//  Created by Mensah Shadrach on 30/12/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit



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
    
    public class func setLatest(_ id:String){
        set(id, for: .latestCliq)
    }
    
    public class var activeCliqID:String{
        return standard.string(forKey: Fields.latestCliq.rawValue) ?? ""
    }
    
    public class var instanceToken:String{
        return standard.string(forKey: Fields.instanceToken.rawValue) ?? ""
    }
    
    public class var updatedtoken:Bool{
        return standard.bool(forKey: "updatedtoken")
    }
    
    public class var username:String{
        return standard.string(forKey: Fields.username.rawValue)!
    }
    
    class func set(_ value:Any, for field:Fields){
        standard.set(value, forKey: field.rawValue)
    }
    
//    class var getlastUpdate:Double{
//        let last = standard.double(forKey: Fields.lastChecked.rawValue)
//        if last < 1 {
//            return Date().timeIntervalSinceReferenceDate + WEEK_SECONDS
//            
//        }else{return last}
//    }
    
    public class func invalidateUserData(){
        standard.removeObject(forKey: Fields.username.rawValue)
        standard.removeObject(forKey: Fields.uid.rawValue)
        standard.removeObject(forKey: Fields.latestCliq.rawValue)
        standard.removeObject(forKey: Fields.instanceToken.rawValue)
        
    }
}


extension NotificationCenter{
    
    class func post(name:FLNotification, object:Any? = nil){
        NotificationCenter.default.post(name: NSNotification.Name(name.rawValue), object: object)
    }
    
    
    class func set(observer:Any, selector:Selector, name:FLNotification,_ object:Any? = nil){
        self.default.addObserver(observer, selector: selector, name: NSNotification.Name(name.rawValue), object: object)
    }
}


extension String {
    static var empty:String{
        return ""
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    
}



extension Int{
    static var largest:Int{
        return Int(INT64_MAX)
    }
}
