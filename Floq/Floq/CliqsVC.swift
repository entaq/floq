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

final class Ho : UIViewController {
    
    
    var  fluser:FLUser?
    var data: [FLCliqItem] = []
    var allCliqs:[SectionableCliq] = []
    var nearbyScliq:SectionableCliq?
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
        collectionView.backgroundColor = UIColor.globalbackground()
        
        setupLocation()
        self.title = "Floq"
        
        view.addSubview(collectionView)
        
        let floaty = Floaty()
        floaty.buttonColor = .clear
        floaty.buttonImage = UIImage(named: "page1")
        
        floaty.addItem("Create a Cliq", icon: UIImage(named: "AppIcon")!, handler: { item in
            self.present(AddCliqVC(), animated: true, completion: nil)
        })
        floaty.addItem("Logout", icon: UIImage(named: "logout")!, handler: { item in
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true, completion: nil)
            } catch {
                print("error trying to logout")
            }
        })
        
        view.addSubview(floaty)
        adapter.collectionViewDelegate = self
        adapter.collectionView = collectionView
        adapter.dataSource = self
        photoEngine.getMyCliqs {
            if self.photoEngine.myCliqs.count > 0{
                let section = SectionableCliq(cliqs: self.photoEngine.myCliqs, type: .mine)
                self.allCliqs.append(section)
                self.adapter.reloadData(completion: nil)
                
            }
        }
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
                    self.adapter.reloadData(completion: nil)
                }else{
                    print("Error occurred with signature: \(errM ?? "Unknown Error")")
                }
            }
        })
        
    }
    
    
    
}


extension CliqsVC: UICollectionViewDelegate, ListAdapterDataSource{
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        
        return allCliqs as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return PhotoSection(isHome: true)
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        let view = UIView(frame: self.view.frame)
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: view.frame.height)))
        label.numberOfLines = 10
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.text = "Oops, there are no cliqs nearby, try creating a cliq in this location"
        label.center = view.center
        view.addSubview(label)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cliq = self.data[indexPath.section]
//        let documentID = cliq.id
//        let cliqName = cliq.name
//        self.navigationController?.pushViewController(PhotosVC(cliqDocumentID: documentID, cliqName: cliqName), animated: true)
        
    }
}


extension CliqsVC:CLLocationManagerDelegate{
    
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
