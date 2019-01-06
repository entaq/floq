//
//  FLCliqItem.swift
//  Floq
//
//  Created by Mensah Shadrach on 15/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import IGListKit
import FirebaseFirestore

class FLCliqItem:ListDiffable, Equatable{
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    
    static func ==(lhs: FLCliqItem, rhs: FLCliqItem) -> Bool {
        return lhs.id == rhs.id && lhs.item == rhs.item
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? FLCliqItem else { return false }
        return id == object.id
    }
    
    func isMember(_ id:String? = nil)->Bool{
        let id = id ?? UserDefaults.uid
        return (followers[id] != nil)
    }
    
    func addMember(_ id:String? = nil){
        let id = id ?? UserDefaults.uid
        followers.updateValue(Date().unix_ts, forKey: id)
    }
    
    public private (set) var id:String
    public private (set) var item:PhotoItem
    public private (set) var name:String
    public private (set) var creatorUid:String
    public private (set) var followers: Aliases.follower_set
    public private (set) var isActive:Bool

    public var joined:Bool
    
    init(snapshot:DocumentSnapshot) {
        print(snapshot.debugDescription)
        id = snapshot.documentID
        self.name = snapshot.getString(.cliqname)
        creatorUid = snapshot.getString(.userUID)
        let timestamp = snapshot.getDate(.timestamp)
        item = PhotoItem(photoID: snapshot.getString(.fileID), user: snapshot.getString(.username), timestamp: timestamp,uid:creatorUid)
        
        let data = snapshot.getDictionary(.followers)
        var followers:Aliases.follower_set = [:]
        for (key,val) in data{
            let ts = (val as? Timestamp)?.dateValue().unix_ts ?? 0
            followers.updateValue(ts, forKey: key)
        }
        self.followers = followers
        if followers.isEmpty{
            self.followers.updateValue(snapshot.getDate(.timestamp).unix_ts, forKey: creatorUid)
        }
        isActive = timestamp.nextDay > Date()
        joined = (followers[UserDefaults.uid] != nil) 
        
    }
    
    
}
