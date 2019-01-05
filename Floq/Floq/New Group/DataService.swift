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
    
    public static var profileIDs:Set<String> = []
    
    private var store:Firestore{
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        return db
    }
    
    
    
    private var geofireRef:CollectionReference{
        return store.collection(References.flocations.rawValue)
    }
    
    private var floqRef:CollectionReference{
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
                    Storage.reference(.userProfilePhotos).child(user.uid).putFile(from: url)
                }
                handler(nil, error.localizedDescription)
            }else{
                handler(true, nil)
            }
        }
    }
    
    func isRegistered(uid:String,handler:@escaping (_ exists:Bool, _ username:String?)->()){
        userRef.document(uid).getDocument { (snap, err) in
            if let snap = snap{
                if snap.exists{
                    handler(true,snap.getString(.username))
                }else{
                   handler(false,nil)
                }
            }else{
               handler(false,nil)
            }
        }
    }
    
    func getAndStoreProfileImg(imgUrl:URL,uid:String){
        let downloader = SDWebImageDownloader.shared()
        downloader.downloadImage(with: imgUrl, options: [.lowPriority], progress: nil) { (imge, data, err, succ) in
            if let image = imge{
                Storage.reference(.userProfilePhotos).child(uid).putData(image.pngData() ?? data!)
            }
        }
    }
    
    func cleanUp(uid:String){
        let rtepData:Aliases.dictionary = [Fields.username.rawValue:"Floq user",Fields.profileImg.rawValue:"placeholder",Fields.deleted.rawValue:true,Fields.dateDeleted.rawValue:Date()]
        userRef.document(uid).updateData(rtepData)
        Storage.reference(.userProfilePhotos).child(uid).delete { (err) in
            Logger.log(err)
        }
    }
    
    func joinCliq(cliq:FLCliqItem){
        let data = [Fields.dateCreated.rawValue:cliq.item.timestamp,Fields.uid.rawValue:cliq.id] as [String : Any]
        let batch = store.batch()
        let uid = UserDefaults.uid
        batch.setData(data, forDocument: userRef.document(uid).collection(.myCliqs).document(cliq.id), merge:true)
        let clef = floqRef.document(cliq.id)
        batch.updateData(["\(Fields.followers.rawValue).\(uid)":Date()], forDocument: clef)
        batch.commit { (err) in
            if let err = err{
                Logger.log(err)
            }else{
                
            }
        }
    }
    
    func removeCliq(_ key:String){
        let uid = UserDefaults.standard.string(forKey: Fields.uid.rawValue)!
        userRef.document(uid).collection(.myCliqs).document(key).delete()
        
    }
    
    
    func addNewCliq(image:UIImage, name:String,locaion:CLLocation, onFinish:@escaping CompletionHandlers.dataservice){
        
        userRef.document(UserDefaults.uid).getDocument { (snapshotq, err) in
            guard let snap = snapshotq else{
                onFinish(false,err?.localizedDescription ?? "")
                return
            }
            let count = snap.getInt(.cliqCount)
            let batch = self.store.batch()
            let tpath = Int(Date.timeIntervalSinceReferenceDate * 1000)
            let filePath = "\(name) - \(tpath)"
            let geofire = GeoFirestore(collectionRef: self.geofireRef)
            let uid = UserDefaults.uid
            let newMetadata = StorageMetadata()
            let userName =  snap.getString(.username)
            
            newMetadata.customMetadata = [
                Fields.fileID.rawValue : filePath,
                Fields.username.rawValue : userName,
                Fields.userUID.rawValue: Auth.auth().currentUser!.uid,
                Fields.cliqname.rawValue : name
                
            ]
            
            var data = Data()
            data = image.jpegData(compressionQuality: 1.0)!
            
            Storage.floqPhotos.child(filePath)
                .putData(data, metadata: newMetadata, completion: { (metadata, error) in
                    if let error = error {
                        onFinish(false,"Error uploading: \(error)")
                        print("Error uploading: \(error)")
                        return
                    }
                    var docData: [String: Any] = [
                        "timestamp" : FieldValue.serverTimestamp(),
                        Fields.followers.rawValue: [UserDefaults.uid:Date()]
                        
                    ]
                    docData.merge(newMetadata.customMetadata!, uniquingKeysWith: { (_, new) in new })
                    print(docData, filePath)
                    batch.setData(docData, forDocument: self.floqRef.document(filePath), merge: true)
                    
                    let addata = [Fields.uid.rawValue:uid, Fields.dateCreated.rawValue:docData[Fields.timestamp.rawValue]!,Fields.cliqCount.rawValue: count + 1]
                    batch.setData(addata, forDocument: self.userRef.document(uid).collection(.myCliqs).document(filePath), merge: true)
                    docData.removeValue(forKey: Fields.cliqname.rawValue)
                    docData.removeValue(forKey:  Fields.followers.rawValue)
                    docData.removeValue(forKey:  Fields.userEmail.rawValue)
                    batch.setData(docData, forDocument:self.floqRef.document(filePath).collection(References.photos.rawValue).document("\(tpath)") , merge: true)
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
