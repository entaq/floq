//
//  CommentListener.swift
//  Floq
//
//  Created by Shadrach Mensah on 10/10/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseFirestore


class CommentListener:NSObject{
    
    private var reference:CollectionReference{
        return Firestore.database.collection(.comment)
    }
    
    private var listener:ListenerRegistration?
    
    var cliqID:String!
    
    init(cliqID:String){
        super.init()
        self.cliqID = cliqID
    }
    
    func attachListener(){
        if listener != nil {return}
        listener = reference.whereField(Comment.Keys.cliqID.rawValue, isEqualTo: cliqID).limit(to: 1).addSnapshotListener { (query, err) in
            if let snap = query?.documents.last{
                let comment = Comment(snapshot: snap)
                
            }
        }
    }
    
    
    func removeListener(){
        listener?.remove()
        listener = nil
    }
    
}
