//
//  PhotosEngine.swift
//  Floq
//
//  Created by Mensah Shadrach on 24/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth


class PhotosEngine:NSObject{
    
    
    
    private var _internalPhotoContainer:[PhotoItem] = []
    static let MAXX_LIKES = 34000
    private var allphotos:[PhotoItem] = []
    
    var allPhotos:[PhotoItem]{
        return allphotos
    }
    
    private var _photoGrids:[GridPhotoItem] = []
    var photoGrids:[GridPhotoItem]{
        return _photoGrids
    }
    
    private var floqRef:CollectionReference{
        return Firestore.database.collection(References.floqs.rawValue)
    }
    
    private var photoRef:CollectionReference{
        return Firestore.database.collection(References.photos.rawValue)
    }
    
    func getAllPhotoMetadata()->[Aliases.stuple]{
        var dictHolder:[String:(String,Int)] = [:]
        let all = _internalPhotoContainer.compactMap { item -> [String:String]?  in
            if let user = appUser{
                if user.hasBlockedMe(user: item.userUid){
                    return nil
                }else{
                    return [item.userUid:item.user]
                }
            }
            return [item.userUid:item.user]
        }
        
        
        for item in all{
            var count = dictHolder[item.first?.key ?? ""]?.1 ?? 0
            count += 1
            dictHolder.updateValue((item.first!.value,count), forKey: item.first!.key)
        }
        
        let stup = dictHolder.compactMap { (value) -> Aliases.stuple in
            return (value.key,value.value.0, value.value.1)
            }
        
        return stup
    }
    
    func getTrueIndex(of photo:PhotoItem)->Int{
        let index = allphotos.firstIndex(of: photo) ?? 0
        return index
    }
    
//    func storeAllPhotos(_ data:[PhotoItem]){
//        guard !allphotos.isEmpty else {
//            allphotos = data
//            return
//        }
//        for item in data {
//            if !allphotos.contains(item){
//                allphotos.append(item)
//            }
//        }
//    }
    
    
    
    func flagPhoto(photoID:String,cliqID:String? = nil, handler:@escaping CompletionHandlers.storage){
        guard let id = Auth.auth().currentUser?.uid else {return}
        let batch = Firestore.database.batch()
        if let cliq = cliqID{
            batch.updateData([Fields.flaggers.rawValue:FieldValue.arrayUnion([id])], forDocument: floqRef.document(cliq))
        }
        batch.updateData([Fields.flagged.rawValue: true, Fields.flaggers.rawValue:FieldValue.arrayUnion([id])], forDocument: photoRef.document(photoID))
        batch.commit(completion: { (err) in
            if let err = err {
                
                handler(false,err.localizedDescription)
    
            }else{
                self.allphotos.removeAll{$0.id == photoID}
                self.generateGridItems()
                handler(true,nil)
            }
        })
    }
    
    func watchForPhotos(cliqDocumentID:String, onFinish:@escaping CompletionHandlers.storage){
        guard let id = Auth.auth().currentUser?.uid else {return}
        photoRef.whereField(Fields.cliqID.rawValue, isEqualTo: cliqDocumentID)
            .addSnapshotListener { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    onFinish(false,"Error fetching snapshots: \(error?.localizedDescription ?? "Unknown Error")")
                    return
                }
                let changes = snapshot.documentChanges.filter({ (dc) -> Bool in
                    if let flaggers = dc.document.getArray(.flaggers) as? [String]{
                        return !flaggers.contains(id)
                    }
                    return true
                })
                
                changes.forEach { diff in
                    if (diff.type == .added) {
                        
                        let photoItem = PhotoItem(doc: diff.document)
                        if !self._internalPhotoContainer.contains(photoItem) {
                            self._internalPhotoContainer.append(photoItem)
                            self._internalPhotoContainer.sort(by: { (i1, i2) -> Bool in
                                return i1.timestamp > i2.timestamp
                            })
                            self.generateGridItems()
                            onFinish(true, nil)
                        }
                    }else if diff.type == .modified{
                        let id = diff.document.documentID
                        self._internalPhotoContainer.first(where: { (item) -> Bool in
                            return item.id == id
                        })?.makeChanges(diff.document)
                        self.post(.modified)
                    }else if diff.type == .removed{
                        self._internalPhotoContainer.removeAll(where: { (photo) -> Bool in
                            return photo.fileID == diff.document.documentID
                        })
                        
                    }
                }
        }
    }
    
    func getExtraLikes(id:String){
        guard let photo = allphotos.first(where: {$0.id == id}) else{return}
        if photo.likesUpdated {return}
        if photo.shards.count > 0{
            photoRef.document(id).collection(.likes).getDocuments { (query, err) in
                guard let query = query else{return}
                var likes = PhotoItem.Likers()
                for doc in query.documents{
                    let likers = doc.getArray(.likers) as? PhotoItem.Likers ?? []
                    likes.append(contentsOf: likers)
                }
                photo.updateLikes(likers: likes)
                
            }
        }
        
    }
    
    func likeAPhoto(cliqID:String,id:String){
        let photo = allphotos.first {return $0.id == id}
        guard photo != nil else {return}
        if photo!.Liked(){return}
        let uid = UserDefaults.uid
        let ref = photoRef.document(id)
        
        Firestore.database.runTransaction({ (transaction, errroP) -> Any? in
            let doc:DocumentSnapshot
            do{
                try doc = transaction.getDocument(ref)
            }catch let err as NSError{
                errroP?.pointee = err
                return err
            }
            
            let likes = doc.getInt(.likes)
            var newUpdate:[String:Any] = [Fields.likes.rawValue:likes + 1]
            let exc = doc.getBoolena(.maxxedLikes)
            if(exc){
                var shard = doc.get(Fields.shardLikes.rawValue) as? [String:Bool] ?? [:]
                let active = shard.first{
                    return $0.value == false
                }
                if active == nil{
                    errroP?.pointee = NSError(domain: "Floq.Likes.Sharding", code: 100, userInfo: ["msg":"Could not find an available Shard"])
                    return nil
                    
                }
                
                let shadDoc:DocumentSnapshot
                do{
                    try shadDoc = transaction.getDocument(ref.collection(.likes).document(active!.key))
                }catch let err as NSError{
                    errroP?.pointee = err
                    return nil
                }
                
                var exceeds = false
                var likers = shadDoc.getArray(.likers) as? PhotoItem.Likers ?? []
                let maXVal = PhotosEngine.MAXX_LIKES * (shard.count + 1)
                if (likes + 1) > maXVal{
                    exceeds = true
                    likers = [uid]
                }else{
                    likers.append(uid)
                }
                
                shard.updateValue(exceeds, forKey: active!.key)
                newUpdate.updateValue(shard, forKey: Fields.shardLikes.rawValue)
                transaction.updateData(newUpdate, forDocument: ref)
                if shard.count > maXVal{
                    let newsharef = ref.collection(.likes).document()
                    shard.updateValue(false, forKey: newsharef.documentID)
                    transaction.updateData([Fields.shardLikes.rawValue:shard], forDocument: ref)
                    transaction.setData([Fields.likers.rawValue:likers], forDocument: newsharef, merge: true)
                }else{
                  transaction.updateData([Fields.likers.rawValue:likers], forDocument: ref.collection(.likes).document(active!.key))
                }
                
            }else{
                var exceeds = false
                var likers = doc.getArray(.likers) as? PhotoItem.Likers ?? []
                if (likes + 1) > PhotosEngine.MAXX_LIKES{
                    exceeds = true
                    let newsharef = ref.collection(.likes).document()
                    newUpdate.updateValue([newsharef.documentID:false], forKey: Fields.shardLikes.rawValue)
                    likers = [uid]
                    transaction.setData([Fields.likers.rawValue:likers], forDocument: newsharef, merge: true)
                    
                }else{
                   likers.append(uid)
                    newUpdate.merge([Fields.likers.rawValue:likers,Fields.maxxedLikes.rawValue:exceeds], uniquingKeysWith: { (k1, k2) -> Any in
                        return k2
                    })
                }
                
                transaction.updateData(newUpdate, forDocument: ref)
                
            }
            return nil
        }) { (sux, err) in
            if let err = err{
                print("Transaction Error: \(err.localizedDescription)")
            }
        }
    }
    
    func filterForBlock(id:String? = nil, photoId:String? = nil){
        guard let user = appUser else {return}
        if let id = id{
            if let pid = photoId{
                allphotos = _internalPhotoContainer.filter{!user.isBlocked(user: $0.userUid) && $0.userUid != id && $0.id != pid}
            }else{
               allphotos = _internalPhotoContainer.filter{!user.isBlocked(user: $0.userUid) && $0.userUid != id}
            }
            
        }else{
            if let pid = photoId{
                allphotos = _internalPhotoContainer.filter{!user.isBlocked(user: $0.userUid) && $0.userUid != id && $0.id != pid}
            }else{
                allphotos = _internalPhotoContainer.filter{!user.isBlocked(user: $0.userUid)}
            }
           
        }
        
    }
    
    func generateGridItems(id:String? = nil, photoId:String? = nil){
        var grids:[GridPhotoItem] = []
        filterForBlock(id:id, photoId:photoId)
        
        let chuncked = allPhotos.chunked(into: 4)
        for chunk in chuncked{
            let grid = GridPhotoItem(items: chunk)
            grids.append(grid)
        }
        _photoGrids = grids
    }
    
    
    func storeImage(filePath:String, data:Data,id:String, newMetadata:StorageMetadata, onFinish:@escaping CompletionHandlers.dataservice){
        Storage.floqPhotos.child(filePath)
            .putData(data, metadata: newMetadata, completion: { (metadata, error) in
                if let error = error {
                    print("Error uploading: \(error)")
                    return
                }
                var docData: [String: Any] = [
                    Fields.timestamp.rawValue : FieldValue.serverTimestamp(),
                    Fields.flagged.rawValue:false,
                    Fields.flaggers.rawValue:[]
                ]
                docData.merge(newMetadata.customMetadata!, uniquingKeysWith: { (_, new) in new })
                print(docData, filePath)
                
                self.photoRef.document(filePath)
                    .setData(docData,merge:true) { err in
                        if let err = err {
                            onFinish(false,err.localizedDescription)
                            print("Error writing document: \(err)")
                        } else {
                            onFinish(true,nil)
                            print("Document successfully written!")
                        }
                }
            })
    }
    
    func post(_ name:FLNotification){
        NotificationCenter.post(name: name)
    }
}
