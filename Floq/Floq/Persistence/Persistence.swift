//
//  Persistence.swift
//  Floq
//
//  Created by Shadrach Mensah on 15/08/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import CoreData
import FirebaseFirestore.FIRDocumentSnapshot


public struct CMTSubscription{
    
    private let stack = CoreDataStack.stack
    
    func save(_ snap:DocumentSnapshot){
        var ids:[String] = []
        var cliqsub:CMTCliqSubscription?
        let id = snap.documentID
        cliqsub = fetchCliqSub(id)
        if (cliqsub != nil){
            cliqsub!.count = snap.getInt64(.cliqComments)
            if let photos = snap.data(){
                for (key, val) in photos{
                    if key == Fields.cliqComments.rawValue {continue}
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
        ids.forEach{broadcast(id: $0)}
        broadcastCliq(snap.documentID)
    }
    
    func fetchCliqSub(_ id:String)->CMTCliqSubscription?{
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "\(CMTCliqSubscription.self)")
        let sortdesc = NSSortDescriptor(key:"cliqID", ascending: true)
        req.sortDescriptors = [sortdesc]
        let pred = NSPredicate(format: "%K = %@", "cliqID", id)
        req.predicate = pred
        
        do {
            let cliq = try stack.context.fetch(req) as? [CMTCliqSubscription]
            return cliq?.first
        } catch let err {
            print(err.localizedDescription)
            
        }
        return nil
    }
    
    

    
    func fetchPhotoSub(id:String)->CMTPhotoSubscription?{
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "\(CMTPhotoSubscription.self)")
        let sortdesc = NSSortDescriptor(key:"photoID" , ascending: true)
        req.sortDescriptors = [sortdesc]
        let pred = NSPredicate(format: "%K = %@", "photoID", id)
        req.predicate = pred
        
        do {
            let photo = try stack.context.fetch(req)
            if photo.isEmpty{
                return nil
            }else{
                return photo.first as? CMTPhotoSubscription
            }
        } catch let err {
            print(err.localizedDescription)
            
        }
        return nil
    }
    
    
    func broadcast(id:String){
       Subscription.main.post(suscription: .newHighlight, object: id)
    }
    
    func broadcastCliq(_ id:String){
        Subscription.main.post(suscription: .cliqHighlight, object: id)
    }
    
    func endHightlightFor(_ photo:String){
        guard let photo = fetchPhotoSub(id: photo) else {return}
        photo.canBroadcast = false
        stack.saveContext()
    }
    //1049089634264-8g938r5ljbf1gsenpkn5s7fk406rq4p7.apps.googleusercontent.com
}

/*
 
class CustomSnapshot:DocumentSnapshot{
    
    override func data() -> [String : Any]? {
        return [Fields.count.rawValue:10,
            "xxxxx":[
                "ts":124567345,
                "count":122
            ],
            "xyxxx":[
                "ts":234567,
                "count":23
            ]
        ]
        
    }
    
    override var documentID: String{
        return "Amama"
    }
    
    init(id:String){
        
    }
}
 */
