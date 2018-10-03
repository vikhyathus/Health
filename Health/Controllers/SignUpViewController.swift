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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradientBackground(colorOne: Colors.blue, colorTwo: Colors.green)
        
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let email = emailField.text, let pass = passwordField.text, let name = nameField.text else {
            print("Not all the fields are filled!")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: pass) { (user, error) in
            
            if error != nil {
                print("error creating user")
                return
            }
            guard let uid = user?.user.uid else {
                return
            }
            //if user authenticated sucessfully
            let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com")
            let userReference = ref.child("Users").child(uid)
            let values = ["name" : name, "email":email]
            userReference.updateChildValues(values, withCompletionBlock: { (updatingUserError, ref) in
                
                if updatingUserError != nil {
                    print(updatingUserError?.localizedDescription)
                    return
                }
                
                let taskViewController = ORKTaskViewController(task: ConsentTask, taskRun: nil)
                taskViewController.delegate = self
                self.present(taskViewController, animated: true, completion: nil)
//                self.navigationController?.popViewController(animated: true)
                //self.dismiss(animated: true, completion: nil)
                print("saved user sucessfully")
                
            })
        }
    }
}

extension SignUpViewController: ORKTaskViewControllerDelegate {
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        // handling results here
        print("It comes")
        taskViewController.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
