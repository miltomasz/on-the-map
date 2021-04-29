//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Tomasz Milczarek on 09/04/2021.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - IB

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UITextView!
    
    // MARK: - Configuration
    
    private enum Configuration {
        static let infoLabelText = "Don't have an account? Sign up!"
        static let infoLabelLink = "https://auth.udacity.com/sign-up?next=https://classroom.udacity.com"
        static let linkRange = NSRange(location: 23, length: 7)
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        usernameTextField.text = ""
        passwordTextField.text = ""
        
        setupInfoLabel()
    }
    
    private func setupInfoLabel() {
        let attributedString = NSMutableAttributedString(string: Configuration.infoLabelText)
        attributedString.addAttribute(.link, value: Configuration.infoLabelLink, range: Configuration.linkRange)
        
        infoLabel.attributedText = attributedString
        infoLabel.isUserInteractionEnabled = true
        infoLabel.font = UIFont.systemFont(ofSize: 17.0)
        infoLabel.textAlignment = .center
    }
    
    // MARK: - Actions
    
    @IBAction func loginTapped(_ sender: UIButton) {
        setLoggingIn(true)
        UdacityClient.login(username: usernameTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
    }
    
    private func handleLoginResponse(success: Bool, error: Error?) {
        setLoggingIn(false)
        if success {
            performSegue(withIdentifier: "completeLogin", sender: nil)
        } else {
            NetworkHelper.showFailurePopup(title: "Login Failed", message: error?.localizedDescription ?? "", on: self)
        }
    }

    private func setLoggingIn(_ loggingIn: Bool) {
        NetworkHelper.showLoader(loggingIn, activityIndicator: activityIndicator)
        
        usernameTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
    }
    
}

// MARK: - UITextViewDelegate

extension LoginViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
}

