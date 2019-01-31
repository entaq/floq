//
//  FLUser.swift
//  Floq
//
//  Created by Mensah Shadrach on 30/09/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import FirebaseFirestore.FIRDocumentSnapshot


class FLUser{
    
    public private (set) var uid:String!
    public private (set) var username:String!
    public private (set) var profileImg:URL?
    public private (set) var cliqs:Int
    
    
    init(uid:String, username:String?,profUrl:URL?,cliqs:Int) {
        self.username = username ?? "Floq User"
        self.uid = uid
        self.cliqs = cliqs
        profileImg = profUrl
    }
    
    init(snap:DocumentSnapshot) {
        username = snap.getString(.username)
        uid = snap.documentID
        cliqs = snap.getInt(.cliqCount)
        profileImg = URL(string: snap.getString(.profileImg))
    }
}
