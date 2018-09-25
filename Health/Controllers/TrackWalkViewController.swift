//
//  TrackWalkViewController.swift
//  Health
//
//  Created by Vikhyath on 24/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import Firebase

class TrackWalkViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    var ref: DatabaseReference?
    
    var time = 0
    var timer = Timer()
    var startTime: Date!
    var endTime: Date!
    var presentDistance: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isHidden = true
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        startTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(action), userInfo: nil, repeats: true)
        startButton.isEnabled = false
        startButton.alpha = 0.3
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        endTime = Date()
        timer.invalidate()
        doneButton.isHidden = false
        startButton.isEnabled = true
        startButton.alpha = 1
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        timer.invalidate()
        time = 0
        timeLabel.text = String(time)
        startButton.isEnabled = true
        startButton.alpha = 1
    }
    
    @objc func action()  {
        time+=1
        timeLabel.text = String(time)
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        if startTime != nil && endTime != nil {
            var totalTime = endTime.timeIntervalSince(startTime)/60
            if let currentDistance = presentDistance as? Double {
                totalTime += currentDistance
            }
            
            totalTime += Double(presentDistance)!
            print(presentDistance)
            
            updateDatabase(totalTime: totalTime)
            print(totalTime)
        }
    }
    
    func updateDatabase(totalTime: TimeInterval) {
        
        ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com")
//        let date = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "ddMMyyyy"
//        let today = formatter.string(from: date)
        let uid = Auth.auth().currentUser?.uid
        
        let userReference = ref?.child("Users").child(uid!).child("Activities").child(String(Date().ticks))
        let values = ["Walk" : totalTime]
        userReference?.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                print(error?.localizedDescription)
            }
            print("saved successfully")
            self.dismiss(animated: true, completion: nil)
        })
    }
}
