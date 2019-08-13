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
    
    static func == (lhs: Comment, rhs: Comment) -> Bool{
       return lhs.id == rhs.id
    }
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
                Keys.photoID.rawValue:self.photoID
            ]
        }
    }
    
    
}




extension Comment{
    
    fileprivate init(body:String,user:String){
        id  = appUser!.uid
        reference = nil
        self.body = body
        timestamp = Date()
        commentor = user
        commentorID = appUser!.uid
        photoID = ""
    }
    
    struct MockData{
        var comments = [
            Comment(body: "Back in my early years in school, we had a mathematic topic called Number bases, the first time I was introduced to it, it bewildered. I found it interesting ", user: "Eric ball"),
            Comment(body: "What do I mean by this? Computer science engineers and systems architecture designers are able to express everything in binary and silicon transistors can also hold binary data by virtue of the existence of voltage coursing through it or the nonexistence. Put this two together and we have our modern computer infrastructure", user: "Taco Bell"),
            Comment(body: "O yeah we were short of numbers so we had to borrow some alphabets.", user: "Saurik"),
            Comment(body: "The great thing about hex is that it allows gargantuan numbers to be rewritten in a not so intimidating format. Take this number for an example : 737369261 will map to 2BF35CAD in the hexadecimal format. Notice the length doesn’t change by much, yeah but you can appreciate the aesthetics in the hex and hex (hence) the “not so intimidating reference I made. Now I want you to try this exercise, try memorizing both numbers. You will appreciatetge existence of the alphabet in there as it is easier to memorize. “2bf-thirty five-card” is much simpler than 737- u already lost me friend. The best thing about the hex system is when @compare with the binary is the the brutal length reduction. Binary : 11110000000000001111101001101110 will map to F000FA6E. Wow who could have seen that “one one one one O O O O O O O O O O O O one one one one one O one O O - please u lost me already” could be made easier for computer programmers? Well system architects did and placed a hex on it🤣🤣🤣. And we got “foofage”. Evidently Hex system reduces binary number length vigorously with impunity as a shorthand for wringing binary. ", user: "Long Con")
        
        ]
        
        mutating func appendComment(body:String){
            let comment = Comment(body: body, user: "Gerold Dayne")
            comments.append(comment)
        }
        
        mutating func makeDuplicate(){
            let comments = self.comments
            self.comments.append(contentsOf: comments)
            self.comments.append(contentsOf: comments)
            
        }
    }
}


