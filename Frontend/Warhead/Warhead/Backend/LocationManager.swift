//
//  LocationManager.swift
//  Warhead
//
//  Created by Alok Sahay on 02.06.2024.
//

import Foundation
import CoreLocation

class LocationManager {
    
    static let sharedManager = LocationManager()
    var dropCoordinate = CLLocationCoordinate2D(latitude: 50.09389700161148, longitude: 14.450689047959024)
    var isP2P: Bool = false
}
