//
//  FLUser.swift
//  Floq
//
//  Created by Mensah Shadrach on 30/09/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import Foundation


class FLUser{
    
    private var _uid:String!
    private var _username:String!
    private var _floqs:[String]?
    
    var uid:String{
        return _uid
    }
    
    var username:String{
        get{
            return _username
        }
        set{
            _username = newValue
        }
    }
    
    var floqs:[String]?{
        get{
            return _floqs
        }
        set{
            _floqs = newValue
        }
    }
    
    
    init(uid:String, username:String?, floqs:[String]?) {
        _username = username ?? "Floq User"
        _uid = uid
        _floqs = floqs
    }
}
