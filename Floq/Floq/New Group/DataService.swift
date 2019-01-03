//
//  DataService.swift
//  Floq
//
//  Created by Mensah Shadrach on 30/09/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Geofirestore
import CoreLocation
import SDWebImage


class DataService{
    
    private static let _main = DataService()
    
    
    static var main:DataService{
        return _main
        
    }
    
    
    private var store:Firestore{
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        return db
    }
    
    var storageRef:StorageReference{
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
        let data = [Fields.username.rawValue: user.username, Fields.dateCreated.rawValue:Date(),Fields.profileImg.rawValue:user.profileImg?.absoluteString ?? ""] as [String:Any]
        userRef.document(user.uid).setData(data) { (err) in
            if let error = err {
                if let url = user.profileImg{
                    self.storageRef.child(References.userProfilePhotos.rawValue).child(user.uid).putFile(from: url)
                }
                handler(nil, error.localizedDescription)
            }else{
                handler(true, nil)
            }
        }
    }
    
    func getAndStoreProfileImg(imgUrl:URL,uid:String){
        let downloader = SDWebImageDownloader.shared()
        downloader.downloadImage(with: imgUrl, options: [.lowPriority], progress: nil) { (imge, data, err, succ) in
            if let image = imge{
                self.storageRef.child(References.userProfilePhotos.rawValue).child(uid).putData(image.pngData() ?? data!)
            }
        }
    }
    
    func joinCliq(key:String, data:[String:Any]){
        let uid = UserDefaults.standard.string(forKey: Fields.uid.rawValue) ?? ""
        userRef.document(uid).collection(.myCliqs).document(key).setData(data, merge: true) { err in
            Logger.log(err)
        }
    }
    
    func removeCliq(_ key:String){
        let uid = UserDefaults.standard.string(forKey: Fields.uid.rawValue)!
        userRef.document(uid).collection(.myCliqs).document(key).delete()
        
    }
    
    
    func addNewCliq(image:UIImage, name:String,locaion:CLLocation, onFinish:@escaping CompletionHandlers.dataservice){
        
        let batch = store.batch()
        let tpath = Int(Date.timeIntervalSinceReferenceDate * 1000)
        let filePath = "\(name) - \(tpath)"
        let geofire = GeoFirestore(collectionRef: geofireRef)
        let uid = UserDefaults.uid()
        let newMetadata = StorageMetadata()
        var userEmail = "unknown"
        var userName = "unknown"
        if let realEmail = Auth.auth().currentUser?.email, let realName = Auth.auth().currentUser?.displayName {
            userEmail = realEmail
            userName = realName
        }
        newMetadata.customMetadata = [
            Fields.fileID.rawValue : filePath,
            Fields.userEmail.rawValue: userEmail,
            Fields.username.rawValue : userName,
            Fields.userUID.rawValue: Auth.auth().currentUser!.uid,
            Fields.cliqname.rawValue : name
        ]
        
        var data = Data()
        data = image.jpegData(compressionQuality: 1.0)!
        
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
                batch.setData(docData, forDocument: self.photoRefs.document(filePath), merge: true)
                docData.removeValue(forKey: "cliqName")
                let addata = [Fields.uid.rawValue:uid, Fields.dateCreated.rawValue:docData[Fields.timestamp.rawValue]!]
                batch.setData(addata, forDocument: self.userRef.document(uid).collection(.myCliqs).document(filePath), merge: true)
                batch.setData(docData, forDocument:self.photoRefs.document(filePath).collection(References.photos.rawValue).document("\(tpath)") , merge: true)
                batch.commit(completion: { (err) in
                    if err != nil {
                        onFinish(false,"Error writing document data")
                        
                    } else {
                        onFinish(true,nil)
                    }
                })
                geofire.setLocation(location: locaion, forDocumentWithID: filePath)
            })
    }
    
    func getUserWith(_ uid:String, handler:@escaping CompletionHandlers.dataservice){
        
        userRef.document(uid).getDocument { (snapshot, err) in
            if let snap = snapshot{
                let user = FLUser(uid: uid, username: snap.getString(.username), profUrl: nil, floqs: nil)
                handler(user,nil)
            }
        }
    }
    
    
}
