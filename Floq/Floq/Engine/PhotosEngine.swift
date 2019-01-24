//
//  PhotosEngine.swift
//  Floq
//
//  Created by Mensah Shadrach on 24/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage


class PhotosEngine:NSObject{
    
    private var allphotos:[PhotoItem] = []
    var allPhotos:[PhotoItem]{
        return allphotos
    }
    
    private var database:Firestore{
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        return db
    }
    
    private var floqRef:CollectionReference{
        return database.collection(References.floqs.rawValue)
    }
    
    func getAllPhotoMetadata()->[Aliases.stuple]{
        var dictHolder:[String:(String,Int)] = [:]
        let all = allPhotos.compactMap { item -> [String:String] in
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
    
    func storeAllPhotos(_ data:[PhotoItem]){
        guard !allphotos.isEmpty else {
            allphotos = data
            return
        }
        for item in data {
            if !allphotos.contains(item){
                allphotos.append(item)
            }
        }
    }
    
    func watchForPhotos(cliqDocumentID:String, onFinish:@escaping CompletionHandlers.photogrids){
        
        floqRef.document(cliqDocumentID).collection(References.photos.rawValue)
            .addSnapshotListener { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    onFinish(nil,"Error fetching snapshots: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        guard let userName = diff.document["userName"] as? String else { return }
                        let ts = diff.document.getDate(.timestamp)
                        let fileID = diff.document.getString(Fields.fileID)
                        let photoItem = PhotoItem(photoID: fileID, user: userName, timestamp:ts,uid:diff.document.getString(.userUID))
                        if !self.allphotos.contains(photoItem) {
                            self.allphotos.append(photoItem)
                            print("photo added: \(diff.document.data())")
                            self.allphotos.sort(by: { (i1, i2) -> Bool in
                                return i1.timestamp > i2.timestamp
                            })
                            let grid = self.generateGridItems(new: self.allPhotos)
                            onFinish(grid, nil)
                        }
                    }
                }
        }
    }
    
    func generateGridItems(new:[PhotoItem])->[GridPhotoItem]{
        var grids:[GridPhotoItem] = []
        
        let chuncked = new.chunked(into: 4)
        for chunk in chuncked{
            let grid = GridPhotoItem(items: chunk)
            grids.append(grid)
        }
        return grids
    }
    
    
    func storeImage(filePath:String, data:Data,id:String, newMetadata:StorageMetadata, onFinish:@escaping CompletionHandlers.dataservice){
        Storage.floqPhotos.child(filePath)
            .putData(data, metadata: newMetadata, completion: { (metadata, error) in
                if let error = error {
                    print("Error uploading: \(error)")
                    return
                }
                var docData: [String: Any] = [
                    Fields.timestamp.rawValue : FieldValue.serverTimestamp()
                ]
                docData.merge(newMetadata.customMetadata!, uniquingKeysWith: { (_, new) in new })
                print(docData, filePath)
                
                self.floqRef.document(id)
                    .collection(References.photos.rawValue).document(filePath)
                    .setData(docData) { err in
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
}
