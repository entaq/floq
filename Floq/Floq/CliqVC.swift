//
//  HomeVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 29/12/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import IGListKit

class NearbyCliqsVC: UIViewController{

    
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

    convenience init(with Engine:PhotoEngine) {
        self.init()
        self.photoEngine = Engine
    }

    var data: [FLCliqItem] = []

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        photoEngine = PhotoEngine()
        collectionView.backgroundColor = UIColor.globalbackground()

        setupLocation()
        

        view.addSubview(collectionView)


        adapter.collectionViewDelegate = self
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }


    func fetchNearbyCliqs(point:GeoPoint){

        photoEngine.queryForCliqsAt(geopoint: point, onFinish: { (cliq, errM) in
            if let cliq = cliq {
                if !self.data.contains(cliq) {
                    self.data.append(cliq)
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

        return data as [ListDiffable]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return PhotoSection()
    }
    /*
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
    */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cliq = self.data[indexPath.section]
        let documentID = cliq.itemID
        let cliqName = cliq.cliqname
        self.navigationController?.pushViewController(PhotosVC(cliqDocumentID: documentID, cliqName: cliqName), animated: true)

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
