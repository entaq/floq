//
//  PhotoNotication.swift
//  Floq
//
//  Created by Shadrach Mensah on 19/08/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//


import CoreData


struct PhotoNotification {
    
    private let stack = CoreDataStack()
    
    
    func saveNotification(id:String,cliq:String){
        if let notif = fetchExistingNotication(id){
            notif.notify = true
        }else{
            let notif = CMTPhotoNotication(context: stack.context)
            notif.id = id
            notif.cliq = cliq
            notif.notify = true
        }
        
        stack.saveContext()
        Subscription.main.post(suscription: .cmt_photo_notify, object: id)
    }
    
    
    func fetchExistingNotication(_ id:String)->CMTPhotoNotication?{
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "\(CMTPhotoNotication.self)")
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.predicate = NSPredicate(format: "%K = %@","id", id)
        
        do {
            let notifs = try stack.context.fetch(request)
            return notifs.first as? CMTPhotoNotication
        } catch let err {
            print("Error occurred whiles fetching Notif with id: \(id) with sig: \(err.localizedDescription)")
        }
        return nil
    }
    
    func endNotifying(_ id:String){
        guard let notif = fetchExistingNotication(id) else { return }
        notif.notify = false
        stack.saveContext()
    }
}
