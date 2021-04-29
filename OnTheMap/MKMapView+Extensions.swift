//
//  MapView+Extensions.swift
//  OnTheMap
//
//  Created by Tomasz Milczarek on 29/04/2021.
//

import MapKit

extension MKMapView {
    
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
    
}
