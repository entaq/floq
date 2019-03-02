//
//  UpdateInfo.swift
//  Floq
//
//  Created by Mensah Shadrach on 29/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseFirestore

public struct UpdateInfo{
    
    var current:Int
    var leastSupport:Int
    var updateInfo:String
    var forcedInfo:String
    var appUrl:URL?
    
    
    init(snap:DocumentSnapshot) {
        current = snap.getInt(.current)
        leastSupport = snap.getInt(.least)
        updateInfo = snap.getString(.info)
        forcedInfo = snap.getString(.forced)
        appUrl = URL(string: snap.getString(.appurl))
    }
    
    func islessThanLeastSupport()->Bool{
        return leastSupport > Update.leastSupport.rawValue
    }
    
    func notifyUpdate()-> Bool{
        return current > Update.current.rawValue
    }
}
