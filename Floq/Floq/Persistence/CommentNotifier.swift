//
//  CommentNotifier.swift
//  Floq
//
//  Created by Shadrach Mensah on 05/11/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseFirestore.FIRDocumentSnapshot
import CoreData


public struct CommentNotificationEngine{
    
    
    private let stack = CoreDataStack.stack
    
    func save(_ snap:DocumentSnapshot){
        var ids:[String] = []
        var cliqsub:CliqNotifier?
        let id = snap.documentID
        cliqsub = fetchCliqSub(id)
        if (cliqsub != nil){
            cliqsub!.count = snap.getInt64(.commentCount)
            cliqsub!.lastUpdated = snap.getDate(.lastUpdated)
            if let photos = snap.data(){
                for (key, val) in photos{
                    if key == Fields.commentCount.rawValue || key == Fields.lastUpdated.rawValue {continue}
                    if let values = val as? [String:Any]{
                        let count = values[Fields.count.rawValue] as? Int ?? 0
                        let lastUpdated = values[Fields.lastUpdated.rawValue] as? Date ?? Date(timeIntervalSince1970: 0)
                        let user = values[Fields.userUID.rawValue] as? String ?? ""
                        let photo = fetchPhotoSub(id: key)
                        if photo != nil{
                            photo!.userID = user
                            photo!.lastUpdated = lastUpdated
                            if photo!.count != count && count > 0{
                                photo?.canBroadcast = true
                                photo!.count = Int64(count)
                                
                                ids.append(key)
                            }
                            
                        }else{
                            let photo = PhotoNotifier(context: stack.persistentContainer.viewContext)
                            photo.photoID = key
                            photo.lastUpdated = lastUpdated
                            photo.count = Int64(count)
                            photo.canBroadcast = (lastUpdated > UserDefaults.installTime && user != UserDefaults.uid) ? true : false
                            photo.userID = user
                            ids.append(key)
                            cliqsub?.addToPhotoNotifiers(photo)
                        }
                    }
                }
            }
            
        }else{
            cliqsub  = CliqNotifier(context: stack.persistentContainer.viewContext)
            cliqsub!.cliqID = snap.documentID
            cliqsub!.count = snap.getInt64(.count)
            if let photos = snap.data(){
                for (key, val) in photos{
                    if key == Fields.commentCount.rawValue || key == Fields.lastUpdated.rawValue {continue}
                    if let values = val as? [String:Any]{
                        let count = values[Fields.count.rawValue] as? Int ?? 0
                        let lastUpdated = values[Fields.lastUpdated.rawValue] as? Date ?? Date(timeIntervalSince1970: 0)
                        let user = values[Fields.userUID.rawValue] as? String ?? ""
                        let photo = PhotoNotifier(context: stack.persistentContainer.viewContext)
                        photo.photoID = key
                        photo.lastUpdated = lastUpdated
                        photo.count = Int64(count)
                        photo.canBroadcast = (lastUpdated > UserDefaults.installTime && user != UserDefaults.uid) ? true : false
                        photo.userID = user
                        ids.append(key)
                        cliqsub?.addToPhotoNotifiers(photo)
                        
                    }
                }
            }
        }
        stack.saveContext()
        ids.forEach{broadcast(id: $0)}
        broadcastCliq(snap.documentID)
        
    }
    
    func fetchCliqSub(_ id:String)->CliqNotifier?{
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "\(CliqNotifier.self)")
        let sortdesc = NSSortDescriptor(key:"cliqID", ascending: true)
        req.sortDescriptors = [sortdesc]
        let pred = NSPredicate(format: "%K = %@", "cliqID", id)
        req.predicate = pred
        
        do {
            let cliq = try stack.context.fetch(req) as? [CliqNotifier]
            return cliq?.first
        } catch let err {
            print(err.localizedDescription)
            
        }
        return nil
    }
    
    

    
    func fetchPhotoSub(id:String)->PhotoNotifier?{
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "\(PhotoNotifier.self)")
        let sortdesc = NSSortDescriptor(key:"photoID" , ascending: true)
        req.sortDescriptors = [sortdesc]
        let pred = NSPredicate(format: "%K = %@", "photoID", id)
        req.predicate = pred
        
        do {
            let photo = try stack.context.fetch(req)
            if photo.isEmpty{
                return nil
            }else{
                return photo.first as? PhotoNotifier
            }
        } catch let err {
            print(err.localizedDescription)
            
        }
        return nil
    }
    
//    func canHiglightCliq(_ id:String) -> Bool{
//        guard let phs = fetchCliqSub(id)?.photoNotifiers as? Set<PhotoNotifier> else {return false}
//        for item in phs{
//            if item.canBroadcast{return true}
//        }
//        return false
//    }
    
    func canHighlight(photo:String)->Bool{
        guard let photo = fetchPhotoSub(id: photo) else {return false}
        return photo.canBroadcast
    }
    
    
    func broadcast(id:String){
       Subscription.main.post(suscription: .newHighlight, object: id)
    }
    
    func broadcastCliq(_ id:String){
        Subscription.main.post(suscription: .cliqHighlight, object: id)
    }
    
    func canHighlightCliq(id:String)-> Bool{
        guard let cliq = fetchCliqSub(id), let photos = cliq.photoNotifiers as? Set<PhotoNotifier> else {return false}
        if cliq.lastUpdated! < UserDefaults.installTime {
            return false
        }
        for photo in photos{
            if photo.canBroadcast{return true}
        }
        return false
    }
    
    func endHightlightFor(_ photo:String){
        guard let photo = fetchPhotoSub(id: photo) else {return}
        photo.canBroadcast = false
        stack.saveContext()
        
        
    }
    
    
    
    
}
