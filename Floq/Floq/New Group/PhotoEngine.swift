//
//  PhotoEngine.swift
//  Floq
//
//  Created by Mensah Shadrach on 15/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import Geofirestore

class PhotoEngine{
    
    
    private var geopoint:GeoPoint!
    private let RADIUS = 1.0
    private var allphotos:[PhotoItem] = []
    public private (set) var mycliqIds:Set<String> = []
    
    private var storage:Storage{
        return Storage.storage()
    }
    
    

    private var geofire:GeoFirestore{
        return GeoFirestore(collectionRef: database.collection(References.flocations.rawValue))
    }
    
    private var userRef:CollectionReference{
        return database.collection(.users)
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
    
    private var query:GFSQuery?
    
    var allPhotos:[PhotoItem]{
        return allphotos
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
    
    public private (set) var myCliqs:[FLCliqItem] = []
    
    
    func queryForCliqsAt(geopoint:GeoPoint,onFinish:@escaping CompletionHandlers.nearbyCliqs){
        query = geofire.query(withCenter: geopoint, radius: RADIUS)
            let _ = query!.observe(.documentEntered) { (id, location) in
            if let id = id {
                self.database.collection(References.floqs.rawValue).document(id).getDocument(completion: { (snapshot, error) in
                    if error == nil && snapshot != nil {
                        guard snapshot!.exists else {
                            onFinish(nil,"Document does not exist")
                            return
                        }
                        
                        let cliq = FLCliqItem(snapshot: snapshot!)
                        onFinish(cliq,nil)
                        
                    }else{
                        onFinish(nil,error!.localizedDescription)
                    }
                })
            }
        }
        
    }
    
    func queryPhotos(cliqDocumentID:String, onFinish:@escaping CompletionHandlers.photogrids){
        var data:[PhotoItem] = []
        database.collection(References.floqs.rawValue).document(cliqDocumentID)
            .collection(References.photos.rawValue).order(by: Fields.timestamp.rawValue, descending: true).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    onFinish(nil,err.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                        guard let userName = document["userName"] as? String else { continue }
                        let ts = document.getDate(.timestamp)
                        let photoItem = PhotoItem(photoID: document.documentID, user: userName, timestamp: ts,uid:document.getString(.userUID))
                        if !data.contains(photoItem) {
                            data.append(photoItem)
                        }
                        data.sort(by: { (a1, a2) -> Bool in
                            return a1.timestamp.timeIntervalSince1970 > a2.timestamp.timeIntervalSince1970
                        })
                        let gridsItems = self.generateGridItems(new: data)
                        self.storeAllPhotos(data)
                        onFinish(gridsItems,nil)
                    }
                }
        }
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
    
    //Optimization (Save Latest Cliq in firestore document)
    //Query Archived cliqs in last 24hrs for the Near Me section.
    
    func getMyCliqs(handler:@escaping CompletionHandlers.simpleBlock){
        var counter = 0
        let uid = UserDefaults.standard.string(forKey: Fields.uid.rawValue)!
        userRef.document(uid).collection(.myCliqs).order(by: Fields.dateCreated.rawValue, descending: true).limit(to: 25).addSnapshotListener { (snap, err) in
            
            if let snap = snap{
                for doc in snap.documentChanges{
                    self.floqRef.document(doc.document.documentID).getDocument(completion: { (docsnap, err) in
                        self.mycliqIds.insert(doc.document.documentID)
                        counter += 1
                        if let dsnap = docsnap{
                            let cliq = FLCliqItem(snapshot: dsnap)
                            
                            if !self.myCliqs.contains(cliq){
                               self.myCliqs.append(cliq)
                                print("The count is: \(snap.count)")
                                if counter == snap.count{
                                    handler()
                                   
                                }
                            }
                        }else{
                            print("The count is: \(snap.count)")
                            if counter == snap.count{
                                handler()
                                
                            }
                        }
                    })
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
    
    
    deinit {
        if query != nil{
            query?.removeAllObservers()
        }
    }

}


