//
//  LoginViewController.swift
//  Health
//
//  Created by Vikhyath on 21/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var textFields: [UITextField]!
    
    var isSignUp: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.alpha = 0.5
        signInButton.layer.cornerRadius = 7
        activityIndicator.isHidden = true
        signInButton.isEnabled = false
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    @IBAction private func signInButtonTapped(_ sender: Any) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        guard let user = userName.text, let password = passwordField.text else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            return
        }
        Auth.auth().signIn(withEmail: user, password: password) { (user, error) in
            
            if error != nil {
                let alert = self.alertCreator(title: "Authentication Error", message: (error?.localizedDescription)!)
                self.present(alert, animated: true, completion: nil)
            } else {
                print("User logged in successfuly!")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction private func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func alertCreator(title: String, message: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "OK", style: .cancel) { (action: UIAlertAction) in
            self.clearForm()
        }
        alertController.addAction(action1)
        
        return alertController
    }
    
    func clearForm() {
        
        userName.text = ""
        passwordField.text = ""
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        signInButton.alpha = 0.5
        signInButton.isEnabled = false
    }
    
}
