//
//  CommentNotifierService.swift
//  Floq
//
//  Created by Shadrach Mensah on 10/10/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import CoreData

public class CommentNotifier{
    
    /*
    
    static let main = CommentNotifier()
    private let stack = CoreDataStack.stack
    
    func updateNote(_ comment:Comment){
        let cliqNote = fetchCliqNote(comment.cliqID)
        if cliqNote != nil{
            let lastupdated = cliqNote!.lastupdated
            let timestamp = Int64(comment.timestamp.unix_ts)
            
            cliqNote!.lastupdated = timestamp
            let photoNote = cliqNote?.photoNotes?.first{($0 as? CommentPhotoNote)?.photoID == comment.photoID} as? CommentPhotoNote
            if photoNote != nil{
                let lastupdated = photoNote!.lastupdated
                let timestamp = Int64(comment.timestamp.unix_ts)
                if timestamp > lastupdated{
                    photoNote!.canBroadcast = true
                    cliqNote!.broadcastCount += 1
                    photoNote!.lastupdated = timestamp
                }
            }else{
                let photoNote = CommentPhotoNote(context: stack.context)
                photoNote.photoID = comment.cliqID
                photoNote.lastupdated = Int64(comment.timestamp.unix_ts)
                photoNote.canBroadcast = true
                cliqNote!.broadcastCount += 1
                cliqNote!.addToPhotoNotes(photoNote)
                
            }
        }else{
            let cliqNote = CommentCliqNote(context: stack.context)
            cliqNote.cliqID = comment.cliqID
            cliqNote.lastupdated = Int64(comment.timestamp.unix_ts)
            cliqNote.broadcastCount += 1
            let photoNote = CommentPhotoNote(context: stack.context)
            photoNote.photoID = comment.cliqID
            photoNote.lastupdated = Int64(comment.timestamp.unix_ts)
            photoNote.canBroadcast = true
            cliqNote.addToPhotoNotes(photoNote)
        }
        
        //let photoNote = fetchPhotoNote(comment.photoID)
        
        
        stack.saveContext()
        
    }
    
    
    func fetchCliqNote(_ id:String)->CommentCliqNote?{
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "\(CommentCliqNote.self)")
        let sortdesc = NSSortDescriptor(key:"cliqID", ascending: true)
        req.sortDescriptors = [sortdesc]
        let pred = NSPredicate(format: "%K = %@", "cliqID", id)
        req.predicate = pred
        
        do {
            let cliq = try stack.context.fetch(req) as? [CommentCliqNote]
            return cliq?.first
        } catch let err {
            print(err.localizedDescription)
            
        }
        return nil
    }
    
    func fetchPhotoNote(_ id:String)->CommentPhotoNote?{
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "\(CommentPhotoNote.self)")
        let sortdesc = NSSortDescriptor(key:"cliqID", ascending: true)
        req.sortDescriptors = [sortdesc]
        let pred = NSPredicate(format: "%K = %@", "cliqID", id)
        req.predicate = pred
        
        do {
            let cliq = try stack.context.fetch(req) as? [CommentPhotoNote]
            return cliq?.first
        } catch let err {
            print(err.localizedDescription)
            
        }
        return nil
    }
    
    func canHiglightPhoto(_ id:String) -> Bool{
        guard let phs = fetchPhotoNote(id) else {return false}
        return phs.canBroadcast
    }
    
    
    func broadcast(id:String){
       Subscription.main.post(suscription: .newHighlight, object: id)
    }
    
    func broadcastCliq(_ id:String){
        Subscription.main.post(suscription: .cliqHighlight, object: id)
    }
    
    func canHighlightCliq(id:String)-> Bool{
        guard let cliq = fetchCliqNote(id) else {return false}
        return cliq.broadcastCount > 0
    }
    
    func endHightlightFor(_ photo:String){
        guard let photo = fetchPhotoNote(photo) else {return}
        photo.canBroadcast = false
        photo.cliqNote?.broadcastCount -= 1
        stack.saveContext()
    }
    */
    
}
