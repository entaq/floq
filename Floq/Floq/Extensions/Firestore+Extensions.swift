//
//  Firestore+Extensions.swift
//  Floq
//
//  Created by Mensah Shadrach on 30/12/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import FirebaseFirestore

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
        if let field = get(id.rawValue) as? Int64{
            return field
        }
        return 0
    }
    
    
    func getBoolena(_ id:Fields)->Bool{
        if let field = get(id.rawValue) as? Bool{
            return field
        }
        return false
    }
    
    
}


extension Firestore{
    
    func collection(_ ref:References)->CollectionReference{
        return collection(ref.rawValue)
    }
    
    
}

