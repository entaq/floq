//
//  FLUser.swift
//  Floq
//
//  Created by Mensah Shadrach on 30/09/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import Foundation


class FLUser{
    
    public private (set) var uid:String!
    public private (set) var username:String!
    public private (set) var floqs:[String]?
    public private (set) var profileImg:URL?

    
    
    init(uid:String, username:String?,profUrl:URL?, floqs:[String]?) {
        self.username = username ?? "Floq User"
        self.uid = uid
        self.floqs = floqs
        profileImg = profUrl
    }
}
