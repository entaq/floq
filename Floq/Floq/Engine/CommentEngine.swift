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
    private var _internalComments:CommentSet
    private var photoId:String
    private var commentsCollection:CollectionReference{
        return Firestore.firestore().collection(.comment)
    }
    
    
    init(photo id:String) {
        super.init()
        photoId = id
    }
    
    var comments:Comments{
        return _internalComments.sorted{$0.timestamp > $1.timestamp}
    }
    
    func watchForComments(completion:@escaping Completion){
        let query = commentsCollection.whereField(Comment.Keys.photoID.rawValue, isEqualTo: photoId).limit(to: 20).order(by: Comment.Keys.timestamp.rawValue, descending: true)
        query.addSnapshotListener { (querySnap, error) in
            guard let docs = querySnap?.documents else {return}
            docs.forEach{let comment = Comment(snapshot: $0)
                self._internalComments.insert(comment)
            }
            completion(error)
        }
    }
    
    func postAComment(_ comment:Comment.Raw)
    
}
