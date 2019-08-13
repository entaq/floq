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
        return lhs.fileID == rhs.fileID && lhs.user == rhs.user
    }
    var id:String
    let fileID: String
    let user: String
    let timestamp:Date
    let userUid:String
    let cliqID:String
    
    public private (set) var likes:Int
    public private (set) var likers:Likers
    public private (set) var shards:Shards
    public private (set) var likesUpdated:Bool = false
    public private (set) var flagged:Bool = false
    
    init(id:String,cliq:String, photoID: String, user: String, timestamp:Date,uid:String, likes:Int = 0) {
        self.id = id
        self.fileID = photoID
        self.user = user
        self.timestamp = timestamp
        self.userUid = uid
        self.likes = likes
        likers = []
        shards = [:]
        cliqID = cliq
        
    }
    
    init(doc:DocumentSnapshot){
        id = doc.documentID
        fileID = doc.getString(.fileID)
        cliqID = doc.getString(.cliqID)
        user = doc.getString(.username)
        timestamp = doc.getDate(.timestamp)
        userUid = doc.getString(.userUID)
        flagged = doc.getBoolena(.flagged)
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
        return fileID as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? PhotoItem else { return false }
        return user == object.user
    }
    
    
}
