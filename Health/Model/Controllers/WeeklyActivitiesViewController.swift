//
//  WeeklyActivitiesViewController.swift
//  Health
//
//  Created by Vikhyath on 21/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import Firebase

class WeeklyActivitiesViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func logoutButtonTapped(_ sender: Any) {
        do {
            try! Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
    }
        
    
}
    @IBAction func handleWalk(_ sender: UIButton) {
        var walkingScreen: UIViewController = WalkViewController()
        
        
    }
}
