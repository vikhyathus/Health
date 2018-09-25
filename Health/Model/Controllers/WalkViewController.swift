//
//  WalkViewController.swift
//  Health
//
//  Created by Vikhyath on 24/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import FirebaseDatabase

class WalkViewController: UIViewController {

    var ref: DatabaseReference?
    var databasehandler: DatabaseHandle?
    var walkTask: WalkTask!
    
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var coveredLabel: UILabel!
    @IBOutlet weak var tobeCoveredLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Tasks")
        _ = assignTask()
        ref?.child("Task1").observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as! NSDictionary
            print(dict)
            
            if let duration = dict["duration"] as? Int {
                self.goalLabel.text = "\(duration)" + " min"
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func handleCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func assignTask() -> String {
        return "Task1"
    }
    
    @IBAction func walkTapped(_ sender: UIButton) {
        
    }
    
    
}
