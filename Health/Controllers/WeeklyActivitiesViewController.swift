//
//  WeeklyActivitiesViewController.swift
//  Health
//
//  Created by Vikhyath on 21/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import Firebase
import HealthKit

class WeeklyActivitiesViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        authorizeHealthKit()
    }
    @IBAction func logoutButtonTapped(_ sender: Any) {
        do {
            try! Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
    }
        
    
}
    @IBAction func handleWalk(_ sender: UIButton) {
        //var walkingScreen: UIViewController = WalkViewController()
    }
    
    private func authorizeHealthKit() {
        
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                
                return
            }
            
            print("HealthKit Successfully Authorized.")
        }
        
    }
}
