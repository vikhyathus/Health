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
    
    var isSignUp: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        guard let user = userName.text, let password = passwordField.text else {
            return
        }
        Auth.auth().signIn(withEmail: user, password: password) { (user, error) in
            
            if error != nil {
                print("Error sign In")
                return
            }
            print("User logged in successfuly!")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
}
