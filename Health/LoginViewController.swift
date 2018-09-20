//
//  LoginViewController.swift
//  Health
//
//  Created by Vikhyath on 20/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import ResearchKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 20
    }

    @IBAction func loginTapped(_ sender: Any) {
        let consentTaskViewController = ORKTaskViewController(task: ConsentTask, taskRun: nil)
        consentTaskViewController.delegate = self
        present(consentTaskViewController, animated: true, completion: nil)
    }
}

extension LoginViewController: ORKTaskViewControllerDelegate {
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        // Analyse the result here----------
        taskViewController.dismiss(animated: true, completion: nil)
        let surveyView: UIViewController = storyboard?.instantiateViewController(withIdentifier: "SurveyViewController") as! UIViewController
        self.navigationController?.pushViewController(surveyView, animated: true)
    }
}
