//
//  DataService.swift
//  Floq
//
//  Created by Mensah Shadrach on 30/09/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import Firebase
import Geofirestore
import CoreLocation


class DataService{
    
    private static let _main = DataService()
    private let imageCache:NSCache = NSCache<AnyObject,AnyObject>()
    
    static var main:DataService{
        return _main
        
    }
    
    
    func cache(_ image:UIImage, key:String){
        imageCache.setObject(image, forKey: key as AnyObject)
    }
    
    func getCachedImage(for key:String)-> UIImage?{
        return imageCache.object(forKey: key as AnyObject) as? UIImage
    }
    
    func clearCache(){
        imageCache.removeAllObjects()
    }
    private var store:Firestore{
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        return db
    }
    
    private var storageRef:StorageReference{
        return Storage.storage().reference()
    }
    
    private var geofireRef:CollectionReference{
        return store.collection(References.flocations.rawValue)
    }
    
    private var photoRefs:CollectionReference{
        return store.collection(References.floqs.rawValue)
    }
    

    private var userRef: CollectionReference{
        
       return store.collection(References.users.rawValue)
    }
    
    
    func setUser(user:FLUser, handler:@escaping CompletionHandlers.dataservice){
        let data = [Fields.username.rawValue: user.username, Fields.dateCreated.rawValue:Date()] as [String:Any]
        userRef.document(user.uid).setData(data) { (err) in
            if let error = err {
                handler(nil, error.localizedDescription)
            }else{
                handler(true, nil)
            }
        }
    }
    
    
    func addNewCliq(image:UIImage, name:String,locaion:CLLocation, onFinish:@escaping CompletionHandlers.dataservice){
        
        
        let filePath = "\(name) - \(Int(Date.timeIntervalSinceReferenceDate * 1000))"
        let geofire = GeoFirestore(collectionRef: geofireRef)
        // Create file metadata to update
        let newMetadata = StorageMetadata()
        var userEmail = "unknown"
        var userName = "unknown"
        if let realEmail = Auth.auth().currentUser?.email, let realName = Auth.auth().currentUser?.displayName {
            userEmail = realEmail
            userName = realName
        }
        newMetadata.customMetadata = [
            "fileID" : filePath,
            "userEmail": userEmail,
            "userName" : userName,
            "userID": Auth.auth().currentUser!.uid,
            "cliqName" : name
        ]
        
        var data = Data()
        data = UIImageJPEGRepresentation(image, 1.0)!
        
        self.storageRef.child(filePath)
            .putData(data, metadata: newMetadata, completion: { (metadata, error) in
                if let error = error {
                    onFinish(false,"Error uploading: \(error)")
                    print("Error uploading: \(error)")
                    return
                }
                var docData: [String: Any] = [
                    "timestamp" : FieldValue.serverTimestamp()
                ]
                docData.merge(newMetadata.customMetadata!, uniquingKeysWith: { (_, new) in new })
                print(docData, filePath)
                
                self.photoRefs.document(filePath)
                    .setData(docData) { err in
                        
                        if err != nil {
                            onFinish(false,"Error writing document data")
                        } else {
                            onFinish(true,nil)
                        }
                        
                }
                geofire.setLocation(location: locaion, forDocumentWithID: filePath)
            })
    }
}
