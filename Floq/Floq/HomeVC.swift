//
//  CliqsVC.swift
//  Floq
//
//  Created by Arun Nagarajan on 7/8/18.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit
import IGListKit
import Firebase
import Floaty
import CoreLocation
import Geofirestore
import Crashlytics

final class HomeVC : UIViewController {
    
    
    var  fluser:FLUser?
    var data: [FLCliqItem] = []
    var allCliqs:[SectionableCliq] = []
    var nearbyScliq:SectionableCliq?
    var mySectionalCliqs:SectionableCliq?
    var myActiveSectionCliq:SectionableCliq?
    private var photoEngine:PhotoEngine!
    private var locationManager:CLLocationManager!
    private var queryhandle:GFSQueryHandle?
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 2)
    }()
    
    func setupLocation(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager?.startUpdatingLocation()
        }
    }
    
    convenience init(_ fluser:FLUser?) {
        self.init()
        self.fluser = fluser
        
    }
    
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        photoEngine = PhotoEngine()
        collectionView.backgroundColor = UIColor.globalbackground
        
        setupLocation()
        
        
        view.addSubview(collectionView)
        
        let floaty = Floaty()
        floaty.buttonColor = .clear
        floaty.buttonImage = .icon_app_rounded
        
        floaty.addItem("Create a Cliq", icon:.icon_app, handler: { item in
            self.present(AddCliqVC(), animated: true, completion: nil)
        })
        floaty.addItem("Profile", icon:.placeholder, handler: { item in
            if let vc = UIStoryboard.main.instantiateViewController(withIdentifier: String(describing: UserProfileVC.self)) as? UserProfileVC{
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
        
        view.addSubview(floaty)
        adapter.collectionViewDelegate = self
        adapter.collectionView = collectionView
        adapter.dataSource = self
        photoEngine.getMyCliqs {
            if self.photoEngine.myCliqs.count > 0{
                self.updateData()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        title = "Floq"
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    
    func fetchNearbyCliqs(point:GeoPoint){
        
        photoEngine.queryForCliqsAt(geopoint: point, onFinish: { (cliq, errM) in
            if let cliq = cliq {
                if !self.data.contains(cliq) {
                    if self.nearbyScliq == nil{
                        self.nearbyScliq = SectionableCliq(cliqs: [cliq], type: .near)
                        self.allCliqs.append(self.nearbyScliq!)
                    }else{
                        self.nearbyScliq!.update(cliq)
                    }
                    self.allCliqs.sort { (s1, s2) -> Bool in
                        return s1.designatedIndex < s2.designatedIndex
                    }
                    self.adapter.reloadData(completion: nil)
                }else{
                    print("Error occurred with signature: \(errM ?? "Unknown Error")")
                }
            }
        })
        
    }
    
    func updateData(){
        if mySectionalCliqs != nil{
            mySectionalCliqs!.cliqs = self.photoEngine.myCliqs
        }else{
            mySectionalCliqs = SectionableCliq(cliqs: photoEngine.myCliqs, type: .mine)
            allCliqs.append(mySectionalCliqs!)
        }
        if myActiveSectionCliq != nil{
            if photoEngine.activeCliq != nil{
                if photoEngine.activeCliq!.id != mySectionalCliqs!.cliqs.first!.id{
                    myActiveSectionCliq?.cliqs = [photoEngine.activeCliq!]
                }else{
                    //There is no more active cliq.. Remove that section
                    if allCliqs.contains(myActiveSectionCliq!){
                        allCliqs.remove(at: 0)

                    }
                }
            }
        }else{
            if self.photoEngine.activeCliq != nil{
                myActiveSectionCliq = SectionableCliq(cliqs: [photoEngine.activeCliq!], type: .active)
                allCliqs.append(myActiveSectionCliq!)
            }
            
        }
        allCliqs.sort { (s1, s2) -> Bool in
            return s1.designatedIndex < s2.designatedIndex
        }
        
        self.adapter.reloadData(completion: nil)
    }
    
}


extension HomeVC: UICollectionViewDelegate, ListAdapterDataSource{
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        
        return allCliqs as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let sect =  object as? SectionableCliq{
            if sect.sectionType == .active{
                return ActiveSectionController()
            }
        }
        return PhotoSection(isHome: true)
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        
        return .listAdapterEmptyView(superView: view, info: .nocliqs_nearby)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Crashlytics.sharedInstance().crash()
        let cliqsction = self.allCliqs[indexPath.section]
        switch cliqsction.sectionType {
        case .active:
            let vc = PhotosVC(cliq: cliqsction.cliqs.first!)
            navigationController?.pushViewController(vc, animated: true)
            break
        case .near:
            let vc = NearbyCliqsVC(with: photoEngine, data: cliqsction.cliqs)
            navigationController?.pushViewController(vc, animated: true)
            break
        case .mine:
            let vc = MyCliqsVC(engine: photoEngine)
            navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
        
        
    }
}


extension HomeVC:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let userLocation = locations.first else{
            return
        }
        let point  = GeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        fetchNearbyCliqs(point: point)
        locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
}
