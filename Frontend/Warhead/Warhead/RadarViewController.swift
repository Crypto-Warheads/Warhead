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
    @IBOutlet weak var mapView: MKMapView!
    var lastKnownLocation = CLLocation()
    var overlays = [MKOverlay]()
    let testCoordinate = CLLocationCoordinate2D(latitude: 50.09389700161148, longitude: 14.450689047959024)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        mapView.mapType = .hybridFlyover
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) // Adjust the zoom level
        let region = MKCoordinateRegion(center: lastKnownLocation.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
    }
}

extension RadarViewController: MKMapViewDelegate {
    
    func addImpactArea(at coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let circle = MKCircle(center: coordinate, radius: radius)
        circle.title = "impact"
        mapView.addOverlay(circle)
        overlays.append(circle)
    }
    
    func addAirdropArea(at coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let circle = MKCircle(center: coordinate, radius: radius)
        circle.title = "airdrop"
        mapView.addOverlay(circle)
        overlays.append(circle)
    }
    
    
    func removeOverlay(_ overlay: MKOverlay) {
        mapView.removeOverlay(overlay)
        overlays.removeAll { $0 === overlay }
    }
    
    func removeAllOverlays() {
        mapView.removeOverlays(mapView.overlays)
        overlays.removeAll()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: circleOverlay)
            
            switch circleOverlay.title {
            case "impact":
                circleRenderer.fillColor = UIColor.red.withAlphaComponent(0.2)
                circleRenderer.strokeColor = UIColor.red
                circleRenderer.strokeColor = UIColor.red
            case "airdrop":
                circleRenderer.fillColor = UIColor.green.withAlphaComponent(0.2)
                circleRenderer.strokeColor = UIColor.green
                circleRenderer.strokeColor = UIColor.green
            default: break
            }
            circleRenderer.lineWidth = 2
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
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
            addAirdropArea(at: testCoordinate, radius: 200)            
        }
    }
}
