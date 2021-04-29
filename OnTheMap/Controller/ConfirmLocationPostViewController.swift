//
//  ConfirmLocationPostViewController.swift
//  OnTheMap
//
//  Created by Tomasz Milczarek on 24/04/2021.
//

import UIKit
import MapKit

protocol RefreshLocationOnMapDelegate: class {
    
    func refreshView()
    
}

class ConfirmLocationPostViewController: UIViewController {
    
    // MARK: - IB
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    
    var location: CLLocation?
    var locationName: String?
    var studenName: String?
    var link: String?
    var delegate: RefreshLocationOnMapDelegate?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        
        setupAnnotation()
    }
    
    private func setupAnnotation() {
        guard let location = location else { return }
        
        var annotations = [MKPointAnnotation]()
        
        let lat = CLLocationDegrees(location.coordinate.latitude)
        let long = CLLocationDegrees(location.coordinate.longitude)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = UdacityClient.Auth.loggedUser
        annotation.subtitle = link ?? ""
        
        annotations.append(annotation)
    
        mapView.addAnnotations(annotations)
        mapView.centerToLocation(location)
    }
    
    // MARK: - Actions
    
    @IBAction func onConfirmTap(_ sender: Any) {
        guard let location = location else { return }
        
        NetworkHelper.showLoader(true, activityIndicator: activityIndicator)
        
        let httpRequestBody = PostStudentLocationRequest(uniqueKey: UUID().uuidString, firstName: UdacityClient.Auth.loggedUser, lastName: "", mapString: locationName ?? "", mediaURL: link ?? "", latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        UdacityClient.postStudentLocation(body: httpRequestBody, completion: handlePostStudentsLocationResponse(success:error:))
    }
    
    private func handlePostStudentsLocationResponse(success:Bool, error: Error?) {
        NetworkHelper.showLoader(false, activityIndicator: activityIndicator)
        
        if success {
            delegate?.refreshView()
            navigationController?.dismiss(animated: true, completion: nil)
        } else {
            NetworkHelper.showFailurePopup(title: "Error", message: error?.localizedDescription ?? "", on: self)
        }
    }
    
}

// MARK: - MKMapViewDelegate

extension ConfirmLocationPostViewController: MKMapViewDelegate {
    
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
