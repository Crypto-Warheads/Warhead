//
//  ViewController.swift
//  Warhead
//
//  Created by Alok Sahay on 01.06.2024.
//

import UIKit
import CoreLocation
import MapKit

class RadarViewController: UIViewController  {

    let locationManager = CLLocationManager()
    var mapView: MKMapView = MKMapView()
    var lastKnownLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
    }
}

extension RadarViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last, location.distance(from: lastKnownLocation) > 100 {
            print("Current location: \(location)")
            lastKnownLocation = location
        }
    }
}
