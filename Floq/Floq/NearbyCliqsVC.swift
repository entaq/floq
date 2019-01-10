//
//  HomeVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 29/12/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import IGListKit
import Firebase
import Floaty
import CoreLocation
import Geofirestore



class NearbyCliqsVC: UIViewController{

    private var isFetchingNearby = false
    private var photoEngine:PhotoEngine!
    private var locationManager:CLLocationManager!
    private var queryhandle:GFSQueryHandle?
    private  var myCliqs:Set<String>!
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

    convenience init(with Engine:PhotoEngine,data:[FLCliqItem]) {
        self.init()
        self.photoEngine = Engine
        self.data = data
        myCliqs = photoEngine.mycliqIds
    }

    var data: [FLCliqItem] = []

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        
          navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        photoEngine = PhotoEngine()
        collectionView.backgroundColor = .globalbackground
        
        
        setupLocation()
        
        let floaty = Floaty()
        floaty.buttonColor = .clear
        floaty.buttonImage = .icon_app_rounded
        floaty.fabDelegate = self
        
        
        view.addSubview(collectionView)
        view.addSubview(floaty)

        adapter.collectionViewDelegate = self
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Near Me"
    }


    func fetchNearbyCliqs(point:GeoPoint){
        if isFetchingNearby{return}else{isFetchingNearby = true}
        photoEngine.queryForCliqsAt(geopoint: point) {
            self.adapter.reloadData(completion: nil)
        }
    }



}


extension NearbyCliqsVC: UICollectionViewDelegate, ListAdapterDataSource{

    

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {

        return photoEngine.nearbyCliqs as [ListDiffable]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return PhotoSection(isHome: false, keys: .near)
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return .listAdapterEmptyView(superView: self.view, info: .nocliqs_nearby)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cliq = self.data[indexPath.section]
        self.navigationController?.pushViewController(PhotosVC(cliq: cliq, id: cliq.id), animated: true)

    }
}


extension NearbyCliqsVC:CLLocationManagerDelegate{

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

extension NearbyCliqsVC:FloatyDelegate{
    
    
    func emptyFloatySelected(_ floaty: Floaty) {
        self.present(AddCliqVC(), animated: true, completion: nil)
    }
}
