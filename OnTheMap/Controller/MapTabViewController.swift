//
//  MapTabViewController.swift
//  OnTheMap
//
//  Created by Tomasz Milczarek on 20/04/2021.
//

import UIKit
import MapKit

class MapTabViewController: UIViewController, MKMapViewDelegate {

    // MARK: - IB
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadStudentsLoaction()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationNavigationController = segue.destination as? UINavigationController,
              let informationPostingViewController = destinationNavigationController.topViewController as? InformationPostingViewController else { return }
        
        informationPostingViewController.delegate = self
    }
    
    private func loadStudentsLoaction() {
        NetworkHelper.showLoader(true, activityIndicator: activityIndicator)
        UdacityClient.getStudentsLocation(completion: handleStudentsLocationResponse(results:error:))
    }
    
    private func handleStudentsLocationResponse(results: [StudentLocationResult], error: Error?) {
        NetworkHelper.showLoader(false, activityIndicator: activityIndicator)
        
        if !results.isEmpty {
            setupAnnotations(results: results)
            
            let lastFivePins = results[0..<5]
            let annotations = createAnnotations(for: Array(lastFivePins))
            
            mapView.showAnnotations(annotations, animated: true)
        } else {
            guard let tabBarController = tabBarController else { return }
            
            NetworkHelper.showFailurePopup(title: "Pins load error", message: error?.localizedDescription ?? "", on: tabBarController)
        }
    }
    
    private func setupAnnotations(results: [StudentLocationResult]) {
        mapView.removeAnnotations(mapView.annotations)
        
        let annotations = createAnnotations(for: results)
        
        mapView.addAnnotations(annotations)
    }
    
    private func createAnnotations(for collection: [StudentLocationResult]) -> [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        
        for result in collection {
            let lat = CLLocationDegrees(result.latitude)
            let long = CLLocationDegrees(result.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = result.firstName
            let last = result.lastName
            let mediaURL = result.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        return annotations
    }
    
    // MARK: - Actions
    
    @IBAction func onLogoutTap(_ sender: Any) {
        NetworkHelper.showLoader(true, activityIndicator: activityIndicator)
        
        UdacityClient.logout { [weak self] success, error in
            guard let self = self else { return }
            
            NetworkHelper.showLoader(false, activityIndicator: self.activityIndicator)
            
            if let error = error, let tabBarController = self.tabBarController {
                NetworkHelper.showFailurePopup(title: "Logout failed!", message: "Could not logout: \(error)", on: tabBarController)
            } else {
                self.presentingViewController?.dismiss(animated: false, completion:nil)
            }
        }
    }
    
    @IBAction func onRefreshTap(_ sender: Any) {
        loadStudentsLoaction()
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let application = UIApplication.shared
            if let toOpen = view.annotation?.subtitle!, let url = URL(string: toOpen) {
                application.open(url)
            }
        }
    }

}

// MMARK: - RefreshLocationOnMapDelegate

extension MapTabViewController: RefreshLocationOnMapDelegate {
    
    func refreshView() {
        loadStudentsLoaction()
    }

}

