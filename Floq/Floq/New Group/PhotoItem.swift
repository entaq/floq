//
//  PhotoItem.swift
//  Floq
//
//  Created by Arun Nagarajan on 12/10/17.
//  Copyright © 2017 Arun Nagarajan. All rights reserved.
//
import IGListKit
import FirebaseFirestore.FIRDocumentSnapshot

final class PhotoItem: ListDiffable, Equatable {
    typealias Likers = [String]
    typealias Shards = [String:Bool]
    static func ==(lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        return lhs.photoID == rhs.photoID && lhs.user == rhs.user
    }
    var reference:DocumentReference!
    let photoID: String
    let user: String
    let timestamp:Date
    let userUid:String
    let absoluteID:String
    public private (set) var likes:Int
    public private (set) var likers:Likers
    public private (set) var shards:Shards
    public private (set) var likesUpdated:Bool = false
    
    init(id:String,photoID: String, user: String, timestamp:Date,uid:String, likes:Int = 0) {
        absoluteID = id
        self.photoID = photoID
        self.user = user
        self.timestamp = timestamp
        self.userUid = uid
        self.likes = likes
        likers = []
        shards = [:]
        
    }
    
    init(doc:DocumentSnapshot){
        reference = doc.reference
        photoID = doc.getString(.fileID)
        absoluteID = doc.documentID
        user = doc.getString(.username)
        timestamp = doc.getDate(.timestamp)
        userUid = doc.getString(.userUID)
        likes = doc.getInt(.likes)
        likers = doc.getArray(.likers) as? Likers ?? []
        shards = doc.getDictionary(.shardLikes) as? Shards ?? [:]
        likesUpdated = shards.count < 1
    }
    
    func updateLikes(likers:Likers){
        self.likers.append(contentsOf: likers)
        likesUpdated = true
    }
    
    func makeChanges(_ docChanges:DocumentSnapshot){
        likes = docChanges.getInt(.likes)
        likers = docChanges.getArray(.likers) as? Likers ?? []
        
    }
    
    func hasliked()->Bool{
        return likers.contains(UserDefaults.uid)
    }
    
    func Liked()->Bool{
        let uid = UserDefaults.uid
        let ret = likers.contains(uid)
        if !ret{
           likers.append(uid)
            likes += 1
        }
        return ret
    }
    
    
    
    // MARK: ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return photoID as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? PhotoItem else { return false }
        return user == object.user
    }
    
    
}
