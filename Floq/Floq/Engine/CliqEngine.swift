//
//  CliqEngine.swift
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

class CliqEngine:NSObject{
    
    
    private var query:GFSQuery?
    private let MAX_IDs = 15
    private var isFetchingMine = false
    private let bag = DisposeBag()
    public private (set) var mycliqIds:Set<String> = []
    public private (set) var activeCliq:FLCliqItem?
    public private (set) var nearbyCliqs:[FLCliqItem] = []
    private var core:CoreEngine!
    public private (set)  var myCliqs:[FLCliqItem] = []
    public private (set) var nearbyIds:NSMutableOrderedSet = []
    private var geoPoint:GeoPoint?
    private var lastSnapshot:DocumentSnapshot?
    private var nearbyScliq:SectionableCliq?
    private var mySectionalCliqs:SectionableCliq?
    private var ActiveSectionCliq:SectionableCliq?
    var homeData:[SectionableCliq]!{
        didSet{
            homeData.sort { (a1, a2) -> Bool in
                return a1.designatedIndex < a2.designatedIndex
            }
        }
    }
    override init() {
        super.init()
        core = CoreEngine()
        homeData = []
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
        if nearbyScliq != nil{
            if homeData.contains(nearbyScliq!){
               let index = homeData.firstIndex(of: nearbyScliq!)!
                homeData.remove(at: index)
            }
        }
        nearbyScliq = SectionableCliq(cliqs: nearbyCliqs, type: .near)
        homeData.append(nearbyScliq!)
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
    
    
    //Optimization (Save Latest Cliq in firestore document)
    //Query Archived cliqs in last 24hrs for the Near Me section.
    
    func queryForMyCliqs(){
        
        if isFetchingMine {return}
        isFetchingMine = true
        let uid = UserDefaults.uid
        var query:Query
        if myCliqs.isEmpty{
            query = floqRef.whereField(Fields.followers.rawValue, arrayContains: uid).limit(to: 20).order(by: Fields.timestamp.rawValue, descending: true)
        }else{
            guard let last = lastSnapshot else {return}
            query = floqRef.whereField(Fields.followers.rawValue, arrayContains: uid).order(by: Fields.timestamp.rawValue, descending: true).start(atDocument: last).limit(to: 20)
        }
        query.addSnapshotListener { (querySnap, err) in
            if let query = querySnap{
                self.lastSnapshot = query.documents.last
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
                self.setMostActive()
                self.updateMyCliqsSection()
                self.post(name: .myCliqsUpdated)
                self.isFetchingMine = false
                
            }
        }
    }
   
    func fetchNextBadge(){
        
    }
    
    func setMostActive(){
        let latest = UserDefaults.activeCliqID
        let lcliqs = myCliqs.filter { (item) -> Bool in
            return item.id == latest
        }
        if let first = lcliqs.first {
            activeCliq = first.isActive ? first : nil
        }
        homeData.removeAll { (sec) -> Bool in
            return sec.sectionType == .active
        }
        if let ac = activeCliq{
            ActiveSectionCliq = SectionableCliq(cliqs: [ac], type: .active)
            homeData.append(ActiveSectionCliq!)
            
//            if ActiveSectionCliq != nil{
//                if !homeData.contains(ActiveSectionCliq!){
//                    let index = homeData.firstIndex(of: ActiveSectionCliq!)!
//                    homeData.remove(at: index)
//                }
//                ActiveSectionCliq!.cliqs = [ac]
//            }else{
//
//            }
        }
    }
    
    
    func updateMyCliqsSection(){
        let count = appUser?.cliqs
        
////            if homeData.contains(mySectionalCliqs!){
////                let index = homeData.firstIndex(of: mySectionalCliqs!)!
////                homeData.remove(at: index)
////            }
//            mySectionalCliqs!.cliqs = myCliqs
//            mySectionalCliqs!.setCount(count)
//
//        }else{
//            mySectionalCliqs = SectionableCliq(cliqs: myCliqs, type: .mine,count:count)
//            homeData.append(mySectionalCliqs!)
//        }
       mySectionalCliqs = SectionableCliq(cliqs: myCliqs, type: .mine,count:count)
        homeData.removeAll { (sec) -> Bool in
            return sec.sectionType == .mine
        }
        homeData.append(mySectionalCliqs!)
        
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







