//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Tomasz Milczarek on 23/04/2021.
//

import UIKit
import CoreLocation

class InformationPostingViewController: UIViewController {
    
    // MARK: - Variables
    
    private lazy var geocoder = CLGeocoder()
    private var location: CLLocation?
    var delegate: RefreshLocationOnMapDelegate?
    
    // MARK: - IB
    
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var link: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConfirmLocation" {
            let confirmLocationPostViewController = segue.destination as? ConfirmLocationPostViewController
            confirmLocationPostViewController?.link = link.text
            confirmLocationPostViewController?.locationName = placeName.text
            confirmLocationPostViewController?.location = location
            confirmLocationPostViewController?.delegate = delegate
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onCancelTap(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onFindLocationTap(_ sender: Any) {
        guard let placeNameText = placeName.text, !placeNameText.isEmpty, let linkText = link.text, !linkText.isEmpty else {
            NetworkHelper.showFailurePopup(title: "Error", message: "Invalid location or link", show: .modally, on: self)
            return
        }
        
        NetworkHelper.showLoader(true, activityIndicator: activityIndicator)
        
        geocoder.geocodeAddressString(placeName.text ?? "") { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        NetworkHelper.showLoader(false, activityIndicator: activityIndicator)

        if error != nil {
            NetworkHelper.showFailurePopup(title: "Error", message: "Could not find any location posted", show: .modally, on: self)
        } else {
            var location: CLLocation?

            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }

            if let location = location {
                self.location = location
                
                performSegue(withIdentifier: "ConfirmLocation", sender: self)
                
                let coordinate = location.coordinate
                debugPrint("Selected location: \(coordinate.latitude), \(coordinate.longitude))")
            } else {
                NetworkHelper.showFailurePopup(title: "Error", message: "No matching location found", show: .modally, on: self)
            }
        }
    }
    
}
