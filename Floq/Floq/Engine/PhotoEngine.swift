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
import CoreLocation
import RxSwift

class PhotoEngine:NSObject{
    
    
    private var query:GFSQuery?
    private let MAX_IDs = 15
    private var allphotos:[PhotoItem] = []
    private let bag = DisposeBag()
    public private (set) var mycliqIds:Set<String> = []
    public private (set) var activeCliq:FLCliqItem?
    public private (set) var nearbyCliqs:[FLCliqItem] = []
    private var core:CoreEngine!
    public private (set)  var myCliqs:[FLCliqItem] = []
    public private (set) var nearbyIds:NSMutableOrderedSet = []
    private var geoPoint:GeoPoint?
    var allPhotos:[PhotoItem]{
        return allphotos
    }
    
    override init() {
        super.init()
        core = CoreEngine()
        let locationSub = core.locationPoint.share()
        locationSub.subscribe(onNext: { (point) in
            self.geoPoint = point
            self.listenForCliqsAt(geopoint: point)
        }) {
            
            }.disposed(by: bag)
        
        start()
    }
    
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
    
    func start(){
        core.setupLocation()
        queryForMyCliqs()
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
    
    
    
    
    func listenForCliqsAt(geopoint:GeoPoint){
        query = geofire.query(withCenter: geopoint, radius: core.RADIUS)
            let _ = query!.observe(.documentEntered) { (id, location) in
            if let id = id {
                let date = self.getTimeFromIdFormat(id: id)
                if date != nil{
                    if date!.nextDay < Date(){
                        return
                    }
                }
                self.nearbyIds.add(id)
                self.getNearbyDocument(id: id)
            }
        }
        
        let _ = query!.observe(.documentExited) { (id, location) in
            guard let id = id else{return}
            if let cliq = self.getCliq(id: id){
                let index = self.nearbyCliqs.firstIndex(of: cliq) ?? -1
                self.nearbyCliqs.remove(at: index)
                self.post(name: .cliqLeft)
            }
        }
        
    }
    
    
    private func getNearbyDocument(id:String){
        
        
        self.database.collection(References.floqs.rawValue).document(id).addSnapshotListener({ (snapshot, error) in
            if error == nil && snapshot != nil {
                guard snapshot!.exists else {
                    return
                }
                
                let cliq = FLCliqItem(snapshot: snapshot!)
                if cliq.isActive{
                    self.addNearby(cliq)
                }
            }else{
                Logger.log(error)
            }})
    }
    
    func addNearby(_ cliq:FLCliqItem){
        if nearbyCliqs.contains(cliq){
            if let oldcliq = getCliq(id: cliq.id){
                if oldcliq.hasChanges(item: cliq){
                    let index = nearbyCliqs.firstIndex(of: oldcliq) ?? -1
                    nearbyCliqs.remove(at: index)
                }else{return}
            }else{return}
        }
        nearbyCliqs.append(cliq)
        nearbyCliqs.sort { (a1, a2) -> Bool in
            return a1.item.timestamp > a2.item.timestamp
        }
       post(name: .cliqEntered)
    }
    
    func getCliq(id:String)->FLCliqItem?{
        return nearbyCliqs.filter{
            return $0.id == id
        }.first
    }
    
    func getTimeFromIdFormat(id:String)->Date?{
        
        let ns = id.replacingOccurrences(of: " ", with: "")
        let chset = ns.split(separator: "-")
        if chset.count == 2{
            if let ts = Int(chset.last!){
                return Date(timeIntervalSinceReferenceDate: TimeInterval((ts / 1000)))
            }
        }
        return nil
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
    
    func queryForMyCliqs(){
        let uid = UserDefaults.uid
        floqRef.whereField(Fields.followers.rawValue, arrayContains: uid).addSnapshotListener { (querySnap, err) in
            if let query = querySnap{
                for doc in query.documentChanges{
                    let cliq = FLCliqItem(snapshot: doc.document)
                    if self.myCliqs.contains(cliq){
                        let index = self.myCliqs.firstIndex(of: cliq)
                        if let index = index{
                            self.myCliqs.remove(at: index)
                            self.myCliqs.append(cliq)
                        }
                    }else{
                        self.myCliqs.append(cliq)
                    }
                }
                self.myCliqs.sort(by: { (a1, a2) -> Bool in
                    a1.item.timestamp > a2.item.timestamp
                })
                self.setMostActive()
                
            }
        }
    }
   
    
    
    func setMostActive(){
        let latest = UserDefaults.activeCliqID
        let lcliqs = myCliqs.filter { (item) -> Bool in
            return item.id == latest
        }
        activeCliq = lcliqs.first
        post(name: .myCliqsUpdated)
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
    
    
    
    
    
    
    func isDuplicate(_ cliq:FLCliqItem)->Bool{
        return myCliqs.contains(where: { (item) -> Bool in
            
            return item.id == cliq.id
        })
    }
    
    deinit {
        if query != nil{
            query?.removeAllObservers()
        }
    }
    
    func post(name:Notification){
        NotificationCenter.post(name:name)
    }
    enum Notification:String{
        case cliqEntered = "cliqEntered"
        case cliqLeft = "cliqLeft"
        case myCliqsUpdated = "cliqsUpdated"
    }

}





