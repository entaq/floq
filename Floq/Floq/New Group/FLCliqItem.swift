//
//  FLCliqItem.swift
//  Floq
//
//  Created by Mensah Shadrach on 15/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import IGListKit
import FirebaseFirestore
import CoreLocation

class FLCliqItem:ListDiffable, Equatable{
    
    enum Max:Int {
        case followers = 30
        case photos = 100
        
    }
    
    
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    
    static func ==(lhs: FLCliqItem, rhs: FLCliqItem) -> Bool {
        return lhs.id == rhs.id && lhs.creatorUid == rhs.creatorUid
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? FLCliqItem else { return false }
        return id == object.id
    }
    
    func isMember(_ id:String? = nil)->Bool{
        let id = id ?? UserDefaults.uid
        return followers.contains(id)
    }
    
    func addMember(_ id:String? = nil){
        let id = id ?? UserDefaults.uid
        followers.insert(id)
    }
    
    public func hasChanges(item:FLCliqItem)->Bool{
        return !(item.followers.count == followers.count)
        
    }
    
    
    public var canFollow:Bool{
        return followers.count < Max.followers.rawValue
    }
    
    public private (set) var id:String
    //public private (set) var item:PhotoItem
    public private (set) var fileID:String
    public private (set) var name:String
    public private (set) var creatorUid:String
    public private (set) var creatorName:String
    public private (set) var followers: Set<String>
    public private (set) var flaggers:[String] = []
    public private (set) var isActive:Bool
    public private (set) var timestamp:Date
    public var shouldFlagCover:Bool = false
    private var location:CLLocation?
    public var joined:Bool
    
    func isNearby(location:CLLocation)-> Bool{
        guard let loc = self.location else{return false}
        if location.distance(from: loc) < 501{
            return true
        }
        return false
    }
    
//    func getPhotoItem(id:String){
//        guard let str = id.split(separator: "-").last?.replacingOccurrences(of: " ", with: "") else {return}
//        DataService.main.getPhotoItem(id: str) { (photo) in
//            if let photo = photo{
//                self.item = photo
//            }
//        }
//    }
    
    init(snapshot:DocumentSnapshot) {
        
        id = snapshot.documentID
        self.name = snapshot.getString(.cliqname)
        creatorUid = snapshot.getString(.userUID)
        timestamp = snapshot.getDate(.timestamp)
        creatorName = snapshot.getString(.username)
        //item = PhotoItem(id:id, photoID: snapshot.getString(.fileID), user: snapshot.getString(.username), timestamp: timestamp,uid:creatorUid)
        fileID = snapshot.getString(.fileID)
        flaggers = snapshot.getArray(.flaggers) as? [String] ?? []
        followers = []
        if let data = snapshot.get(Fields.followers.rawValue) as? [String]{
            self.followers = Set<String>(data)
        }
    
        if followers.isEmpty{
            self.followers.insert(creatorUid)
        }
        isActive = timestamp.nextDay > Date()
        joined = followers.contains(UserDefaults.uid)
        location = snapshot.getLocation(.coordinate)
        //getPhotoItem(id: id)
        
    }
    
    func hasFlagged()->Bool{
        let id = UserDefaults.uid
        return flaggers.contains(id)
    }
    
}
