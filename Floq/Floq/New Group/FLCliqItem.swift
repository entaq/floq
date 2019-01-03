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
    
    public private (set) var id:String
    public private (set) var item:PhotoItem
    public private (set) var name:String
    public private (set) var creatorUid:String

    public var joined:Bool
    
    init(snapshot:DocumentSnapshot,_ joined:Bool = false) {
        id = snapshot.documentID
        self.name = snapshot.getString(.cliqname)
        creatorUid = snapshot.getString(.userUID)
        item = PhotoItem(photoID: snapshot.getString(.fileID), user: snapshot.getString(.username), timestamp: snapshot.getDate(.timestamp),uid:creatorUid)
        self.joined = false
        
    }
    init(id:String,name:String, item:PhotoItem,uid:String, joined:Bool) {
        self.id = id
        self.item = item
        self.name = name
        creatorUid = uid
        self.joined = joined
    }
    
}
