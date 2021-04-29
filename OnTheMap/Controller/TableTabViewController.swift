//
//  TableTabViewController.swift
//  OnTheMap
//
//  Created by Tomasz Milczarek on 22/04/2021.
//

import UIKit

class TableTabViewController: UIViewController {
    
    // MARK: - Variables
    
    var studentLocations: [StudentLocationResult] = []
    
    // MARK: - IB
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var studentLocationTableView: UITableView!
    
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
        studentLocationTableView.isHidden = true
        
        NetworkHelper.showLoader(true, activityIndicator: activityIndicator)
        UdacityClient.getStudentsLocation(completion: handleStudentsLocationResponse(results:error:))
    }
    
    private func handleStudentsLocationResponse(results: [StudentLocationResult], error: Error?) {
        studentLocationTableView.isHidden = false
        NetworkHelper.showLoader(false, activityIndicator: activityIndicator)
        
        if results.isEmpty {
            guard let tabBarController = tabBarController else { return }
            
            NetworkHelper.showFailurePopup(title: "Student locations load error", message: error?.localizedDescription ?? "", on: tabBarController)
        } else {
            studentLocations = results
            studentLocationTableView.reloadData()
        }
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
    
}

// MARK: - UITableViewDataSource

extension TableTabViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StudentLocationTableViewCell", for: indexPath) as? StudentLocationTableViewCell else { return UITableViewCell() }
        
        let studentLocation = studentLocations[indexPath.row]
        
        cell.nameLabel.text = "\(studentLocation.firstName) \(studentLocation.firstName)"
        cell.linkLabel.text = studentLocation.mediaURL
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension TableTabViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toOpen = studentLocations[indexPath.row].mediaURL
        let application = UIApplication.shared
        let url = URL(string: toOpen)
        
        if let url = url, application.canOpenURL(url) {
            application.open(url)
        } else if let tabBarController = self.tabBarController {
            NetworkHelper.showFailurePopup(title: "Error", message: "Invalid URL: \(toOpen)", on: tabBarController)
        }
    }
    
}

// MMARK: - RefreshLocationOnMapDelegate

extension TableTabViewController: RefreshLocationOnMapDelegate {
    
    func refreshView() {
        loadStudentsLoaction()
    }

}

