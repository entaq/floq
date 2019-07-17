//
//  FLComments.swift
//  Floq
//
//  Created by Shadrach Mensah on 15/07/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseFirestore


struct Comment {
    
    public  let id:String
    public let reference:String?
    public let body:String
    public let timestamp:Date
    public let commentor:String
    public let commentorID:String
    public let photoID:String
    
    init(snapshot:DocumentSnapshot) {
        id = snapshot.documentID
        reference = snapshot.getString(Keys.reference.rawValue)
        body = snapshot.getString(Keys.body.rawValue)
        timestamp = snapshot.getDate(Keys.timestamp.rawValue)
        commentor = snapshot.getString(Keys.commentor.rawValue)
        commentorID = snapshot.getString(Keys.commentorID.rawValue)
        photoID = snapshot.getString(Keys.photoID.rawValue)
    }
    
}


extension Comment{
    public enum Keys:String{
        case id, reference, body, timestamp, commentor, commentorID, photoID
    }
}


extension Comment:Hashable, Equatable{
    
}

extension Comment{
    
    struct Raw {
        
        private  let reference:String?
        private  let body:String
        private  let commentor:String
        private  let commentorID:String
        private  let photoID:String
        
        init(ref:String?,body:String, photoID:String){
            reference = ref
            self.body = body
            commentor = appUser!.username
            self.photoID = photoID
            commentorID = appUser!.uid
        }
        
        public func data()->[String:Any?]{
            return [
                Keys.body.rawValue:body,
                Keys.reference.rawValue:reference,
                Keys.timestamp.rawValue:FieldValue.serverTimestamp(),
                Keys.commentor.rawValue:commentor,
                Keys.commentorID.rawValue: commentorID,
            ]
        }
    }
    
    
}




