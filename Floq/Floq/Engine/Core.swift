//
//  Core.swift
//  Floq
//
//  Created by Mensah Shadrach on 23/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage
import Geofirestore
import CoreLocation
import RxSwift

final public class CoreEngine:NSObject{
    
    private var geopointSubject = PublishSubject<GeoPoint>()
    public let RADIUS = 0.5
    private var locationManager:CLLocationManager?
    private var disposer:DisposeBag!
    var locationPoint:Observable<GeoPoint>{
        return geopointSubject.asObserver()
    }
    private var isfetching = false
    public override init() {
        super.init()
        locationManager = CLLocationManager()
        disposer = DisposeBag()
    }

    
    enum LocationError:Error{
        case unableToFindLocation
    }
}



extension CoreEngine:CLLocationManagerDelegate{
    
    func setupLocation(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager?.startUpdatingLocation()
            //locationManager?.startMonitoringSignificantLocationChanges()
        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let userLocation = locations.first else{
            return
        }
        let point  = GeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        if !isfetching{
           geopointSubject.onNext(point)
            isfetching = true
        }
        locationManager?.stopUpdatingLocation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(180)) {
            self.isfetching = false
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
}

