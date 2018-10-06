//
//  SignUpViewController.swift
//  Health
//
//  Created by Vikhyath on 21/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import ResearchKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var textFields: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        signUpButton.layer.cornerRadius = 7
        signUpButton.alpha = 0.5
        signUpButton.isEnabled = false
        activityIndicator.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        clearTextFields()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func clearTextFields() {
        
        for textField in textFields {
            textField.text = ""
        }
        signUpButton.isEnabled = false
        signUpButton.alpha = 0.5
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func alertCreator(title: String, message: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .cancel) { (action: UIAlertAction) in
            self.clearTextFields()
        }
        alertController.addAction(action1)
        
        return alertController
    }
    
    @IBAction private func signUpButtonTapped(_ sender: Any) {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        let taskViewController = ORKTaskViewController(task: ConsentTask, taskRun: nil)
        taskViewController.delegate = self
        self.present(taskViewController, animated: true, completion: nil)
    }
    
    @IBAction private func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension SignUpViewController: ORKTaskViewControllerDelegate {
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        // handling results here
        guard let consentResult = taskViewController.result.results as? [ORKStepResult] else { taskViewController.dismiss(animated: true, completion: nil); return }
        
        print(consentResult)
        for stepResult in consentResult {
            if stepResult.identifier == "ConsentReviewStep" {
                let signatureResult = stepResult.results as? [ORKConsentSignatureResult]
                guard signatureResult?.first?.consented == true else {
                    taskViewController.dismiss(animated: true, completion: nil)
                    return
                }
                let signatureDoc = signatureResult?.first?.signature
                print(signatureDoc)
                signUpTheUser()
            }
         
        }
        taskViewController.dismiss(animated: true, completion: nil)
    }
    
    func signUpTheUser() {
        
        guard let email = emailField.text, let pass = passwordField.text, let name = nameField.text else {
            print("Not all the fields are filled!")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: pass) { user, error in
            
            if error != nil {
                
                let alert = self.alertCreator(title: "Sign Up Error", message: (error?.localizedDescription as? String)!)
                self.present(alert, animated: true, completion: nil)
                print(error?.localizedDescription)
                return
            }
            guard let uid = user?.user.uid else {
                return
            }
            self.dismiss(animated: true, completion: nil)
            //if user authenticated sucessfully
            let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com")
            let userReference = ref.child("Users").child(uid)
            let values = ["name": name, "email": email]
            userReference.updateChildValues(values, withCompletionBlock: { updatingUserError, _ in
                
                if updatingUserError != nil {
                    print(updatingUserError?.localizedDescription)
                    return
                }
                print("saved user sucessfully")
            })
        }
    }
}


