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
    var dropValue = "0.5"
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(launchAirdrop), name: NSNotification.Name("TriggerAirdrop"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(launchHellfire), name: NSNotification.Name("TriggerHellfire"), object: nil)
    }
}

extension RadarViewController: MKMapViewDelegate {
    
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let airdropAnnotation = annotation as? AirdropAnnotation else { return nil }

        let identifier = "AirdropAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false

            // Create a label for the countdown
            let timerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
            timerLabel.backgroundColor = .init(white: 1.0, alpha: 0.8)
            timerLabel.textColor = .black
            timerLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
            timerLabel.tag = 101
            
            annotationView?.addSubview(timerLabel)
            
            // Create a label for the value
            let valueLabel = UILabel(frame: CGRect(x: 0, y: 20, width: 100, height: 20))
            valueLabel.backgroundColor = .init(white: 1.0, alpha: 0.8)
            valueLabel.textColor = .black
            valueLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
            valueLabel.tag = 102
            
            annotationView?.addSubview(valueLabel)
        } else {
            annotationView?.annotation = annotation
        }

        // Update countdown label
        if let timerLabel = annotationView?.viewWithTag(101) as? UILabel {
            timerLabel.text = "\(airdropAnnotation.countdown)s"
        }

        // Update value label
        if let valueLabel = annotationView?.viewWithTag(102) as? UILabel {
            valueLabel.text = "\(airdropAnnotation.value) ETH"
        }
        return annotationView
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
    
    @objc func launchAirdrop() {
        removeAllOverlays()
        addAirdropArea(at: LocationManager.sharedManager.dropCoordinate, radius: 300)
    }
    
    @objc func launchHellfire() {
        removeAllOverlays()
        addImpactArea(at: LocationManager.sharedManager.dropCoordinate, radius: 100)
    }
    
    
}

extension RadarViewController {
    
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
        addAirdropWithTimer(at: coordinate, value: dropValue, duration: 20)
    }
    
    func addAirdropWithTimer(at coordinate: CLLocationCoordinate2D, value: String, duration: Int) {
        let airdropAnnotation = AirdropAnnotation(coordinate: coordinate, countdown: duration, value: value)
        mapView.addAnnotation(airdropAnnotation)
        startTimer(for: airdropAnnotation)
    }
    
    func removeOverlay(_ overlay: MKOverlay) {
        mapView.removeOverlay(overlay)
        overlays.removeAll { $0 === overlay }
    }
    
    func removeAllOverlays() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        overlays.removeAll()
    }
    
    func startTimer(for annotation: AirdropAnnotation) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in

            guard let annotationView = self?.mapView.view(for: annotation),
                  let timerLabel = annotationView.viewWithTag(101) as? UILabel else {
                return
            }

            DispatchQueue.main.async {
                if annotation.countdown > 0 {
                    annotation.countdown -= 1
                    
                    timerLabel.text = "\(annotation.countdown)s"
                    
                } else {
                    timer.invalidate()
                    print("Handle drop")
                    timerLabel.text = "❌ No claim"
//                    self?.mapView.removeAnnotation(annotation) //do not erase unless claimed.
                }
            }
        }
    }
}

class AirdropAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var countdown: Int
    var value: String

    init(coordinate: CLLocationCoordinate2D, countdown: Int, value: String) {
        self.coordinate = coordinate
        self.countdown = countdown
        self.value = value
        super.init()
    }
}
