//
//  LocationPickerViewController.swift
//  Warhead
//
//  Created by Alok Sahay on 02.06.2024.
//

import Foundation
import UIKit
import MapKit

class LocationPickerViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var selectedLocation = CLLocationCoordinate2D(latitude: 50.09389700161148, longitude: 14.450689047959024)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
    }
    
    private func setupMapView() {
        mapView.delegate = self
        addInitialLocationPin()
    }
    
    func addInitialLocationPin() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedLocation
        mapView.addAnnotation(annotation)
    }
}

extension LocationPickerViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "draggablePin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if view == nil {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            view?.canShowCallout = false
            view?.isDraggable = true
            view?.animatesWhenAdded = true
        } else {
            view?.annotation = annotation
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .ending, .canceling:
            view.dragState = .none
            if let coordinate = view.annotation?.coordinate {
                print("New coordinates: \(coordinate.latitude), \(coordinate.longitude)")
                selectedLocation = coordinate
            }
        default: break
        }
    }
}
