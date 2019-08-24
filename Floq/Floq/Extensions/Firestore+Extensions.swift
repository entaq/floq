//
//  Firestore+Extensions.swift
//  Floq
//
//  Created by Mensah Shadrach on 30/12/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import FirebaseFirestore
import CoreLocation

extension DocumentReference{
    func collection(_ ref:References)->CollectionReference{
        return collection(ref.rawValue)
    }
}

extension DocumentSnapshot{
    
    func getString(_ id:Fields)->String{
        if let field = get(id.rawValue) as? String{
            return field
        }
        return ""
    }
    
    func getLocation(_ id:Fields)->CLLocation?{
        if let field = get(id.rawValue) as? GeoPoint{
            let location = CLLocation(latitude: field.latitude, longitude: field.longitude)
            return location
        }
        return nil
    }
    
    func getDate(_ id:Fields)->Date{
        
        if let field = get(id.rawValue) as? Timestamp{
            return field.dateValue()
        }
        return Date()
        
        
    }
    
    func getArray(_ id:Fields)->[Any]{
        if let field = get(id.rawValue) as? [Any]{
            return field
        }
        return []
    }
    
    func getDictionary(_ id:Fields)->Aliases.dictionary{
        if let field = get(id.rawValue) as? Aliases.dictionary{
            return field
        }
        return [:]
        
    }
    
    func getDouble(id:Fields)->Double{
        if let field = get(id.rawValue) as? Double{
            return field
        }
        return 0.000001
    }
    
    func getInt(_ id:Fields)->Int{
        if let field = get(id.rawValue) as? Int{
            return field
        }
        return 0
    }
    
    func getInt64(_ id:Fields)->Int64{
        if let field = get(id.rawValue) as? Int{
            return Int64(field)
        }
        return 0
    }
    
    
    func getBoolena(_ id:Fields)->Bool{
        if let field = get(id.rawValue) as? Bool{
            return field
        }
        return false
    }
    
    func getString(_ id:String)->String{
        if let field = get(id) as? String{
            return field
        }
        return ""
    }
    
    func getLocation(_ id:String)->CLLocation?{
        if let field = get(id) as? GeoPoint{
            let location = CLLocation(latitude: field.latitude, longitude: field.longitude)
            return location
        }
        return nil
    }
    
    func getDate(_ id:String)->Date{
        
        if let field = get(id) as? Timestamp{
            return field.dateValue()
        }
        return Date()
        
        
    }
    
    func getArray(_ id:String)->[Any]{
        if let field = get(id) as? [Any]{
            return field
        }
        return []
    }
    
    func getDictionary(_ id:String)->Aliases.dictionary{
        if let field = get(id) as? Aliases.dictionary{
            return field
        }
        return [:]
        
    }
    
    func getDouble(id:String)->Double{
        if let field = get(id) as? Double{
            return field
        }
        return 0.000001
    }
    
    func getInt(_ id:String)->Int{
        if let field = get(id) as? Int{
            return field
        }
        return 0
    }
    
    func getInt64(_ id:String)->Int64{
        if let field = get(id) as? Int64{
            return field
        }
        return 0
    }
    
    
    func getBoolena(_ id:String)->Bool{
        if let field = get(id) as? Bool{
            return field
        }
        return false
    }
    
    
}


extension GeoPoint{
    
    convenience init(coordinate:CLLocationCoordinate2D){
       self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}


extension Firestore{
    
    class var database:Firestore{
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        return db
    }
    
    func collection(_ ref:References)->CollectionReference{
        return collection(ref.rawValue)
    }
    
    
}

