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
    public private (set) var blockingList:Set<String> = []
    public private (set) var blockedList:Set<String> = []
 
    
    init(uid:String, username:String?,profUrl:URL?,cliqs:Int) {
        self.username = username ?? "Floq User"
        self.uid = uid
        self.cliqs = cliqs
        profileImg = profUrl
    }
    
    func increaseCount(){
        cliqs += 1
    }
    
    func hasBlocked(user id:String)->Bool{
        return blockingList.contains(id)
    }
    
    func isBlocked(user id:String)->Bool{
        return blockedList.contains(id) || blockingList.contains(id)
    }
    
    init(snap:DocumentSnapshot) {
        username = snap.getString(.username)
        uid = snap.documentID
        cliqs = snap.getInt(.cliqCount)
        profileImg = URL(string: snap.getString(.profileImg))
        if let arr = snap.getArray(.blockedList) as? [String]{
            blockedList = Set(arr)
        }
        if let arr = snap.getArray(.blockingList) as? [String]{
            blockingList = Set(arr)
        }
        
    }
}
