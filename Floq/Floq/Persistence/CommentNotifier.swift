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
    /*
    
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
                    if key == Fields.commentCount.rawValue || Fields. {continue}
                    let photo = fetchPhotoSub(id: key)
                    if photo != nil{
                        let ts = Int64(Date().unix_ts)
                        let count = Int64(val as! Int)
                        photo?.lastTimestamp = ts
                        if photo!.count != count{
                            if App.currentDomain == .Comment{
                              photo?.canBroadcast = false
                            }else{
                                photo?.canBroadcast = true
                                cliqsub?.broadcastCount += 1
                                ids.append(key)
                            }
                            
                        }
                        
                        photo?.count = count
                        
                    }else{
                        let photo = CMTPhotoSubscription(context: stack.persistentContainer.viewContext)
                        photo.photoID = key
                        photo.lastTimestamp = Int64(Date().unix_ts)
                        photo.count = Int64(val as! Int)
                        if App.currentDomain == .Comment{
                            photo.canBroadcast = false
                        }else{
                             photo.canBroadcast = true
                            cliqsub?.broadcastCount += 1
                            ids.append(key)
                        }
                        cliqsub?.addToPhotoSubscriptions(photo)
                        
                    }
                }
            }
            
        }else{
            cliqsub  = CMTCliqSubscription(context: stack.persistentContainer.viewContext)
            cliqsub!.cliqID = snap.documentID
            cliqsub!.count = snap.getInt64(.count)
            cliqsub!.userID = userID
            if let photos = snap.data(){
                for (key, val) in photos{
                    if key == Fields.cliqComments.rawValue {continue}
                    let photo = CMTPhotoSubscription(context: stack.persistentContainer.viewContext)
                    photo.photoID = key
                    photo.lastTimestamp = Int64(Date().unix_ts)
                    photo.count = Int64(val as! Int)
                    photo.canBroadcast = true
                    cliqsub!.addToPhotoSubscriptions(photo)
                    ids.append(key)
                }
            }
        }
        stack.saveContext()
        if userID != UserDefaults.uid{
            ids.forEach{broadcast(id: $0)}
            broadcastCliq(snap.documentID)
        }
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
    
    func canHiglightCliq(_ id:String) -> Bool{
        guard let phs = fetchCliqSub(id)?.photoNotifiers as? Set<PhotoNotifier> else {return false}
        for item in phs{
            if item.canBroadcast{return true}
        }
        return false
    }
    
    
    func broadcast(id:String){
       Subscription.main.post(suscription: .newHighlight, object: id)
    }
    
    func broadcastCliq(_ id:String){
        Subscription.main.post(suscription: .cliqHighlight, object: id)
    }
    
    func canHighlightCliq(id:String)-> Bool{
        guard let cliq = fetchCliqSub(id), let photos = cliq.photoNotifiers as? Set<PhotoNotifier> else {return false}
        if cliq.userID == UserDefaults.uid {
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
    
    */
    
    
}
