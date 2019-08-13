//
//  CommentEngine.swift
//  Floq
//
//  Created by Shadrach Mensah on 16/07/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseFirestore


class CommentEngine:NSObject{
    
    
    typealias Comments = Array<Comment>
    typealias CommentSet = Set<Comment>
    typealias Completion = (_ error:Error?) -> ()
    
    private var _QUERY_LIMIT = 20
    private var _internalComments:CommentSet = []
    private var photoId:String
    private var lastSnapshot:DocumentSnapshot?
    private var commentsCollection:CollectionReference{
        return Firestore.database.collection(.comment)
    }
    
    var exhausted = false
    
    init(photo id:String) {
        photoId = id
        super.init()
        
    }
    
    var comments:Comments{
        return _internalComments .sorted{$0.timestamp > $1.timestamp}
    }
    
    func watchForComments(completion:@escaping Completion){
        let query:Query
        if _internalComments.isEmpty{
            query = commentsCollection.whereField(Comment.Keys.photoID.rawValue, isEqualTo: photoId).limit(to: _QUERY_LIMIT).order(by: Comment.Keys.timestamp.rawValue, descending: true)
        }else{
            guard let last = lastSnapshot else {return}
            query = commentsCollection.whereField(Comment.Keys.photoID.rawValue, isEqualTo: photoId).order(by: Comment.Keys.timestamp.rawValue, descending: true).start(afterDocument: last).limit(to: _QUERY_LIMIT)
        }
        
        query.addSnapshotListener { (querySnap, error) in
            guard let docs = querySnap?.documents else {return}
            self.lastSnapshot = docs.last
            if docs.count < 20 {self.exhausted = true}
            docs.forEach{let comment = Comment(snapshot: $0)
                if !self._internalComments.contains(comment){
                    self._internalComments.insert(comment)
                }
            }
            completion(error)
        }
    }
    
    func postAComment(_ comment:Comment.Raw, completion:@escaping Completion){
        commentsCollection.document().setData(comment.data() as [String : Any], merge: true) { err in
            completion(err)
        }
    }
    
}
