//
//  Core.swift
//  Floq
//
//  Created by Mensah Shadrach on 23/01/2019.
//  Copyright © 2019 Arun Nagarajan. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

import CoreLocation


final public class CoreEngine:NSObject{
    
    
    public let RADIUS = 0.5
    private var locationManager:CLLocationManager?
    
    var locationPoint:GeoPoint!
    public private (set) var currentLocation:CLLocation?
    private var isfetching = false
    public override init() {
        super.init()
        locationManager = CLLocationManager()
        
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
        currentLocation = userLocation
        let point  = GeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        if !isfetching{
           Subscription.main.post(suscription: .geoPointUpdated, object: point)
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

