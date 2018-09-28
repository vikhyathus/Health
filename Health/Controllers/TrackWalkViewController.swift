//
//  TrackWalkViewController.swift
//  Health
//
//  Created by Vikhyath on 24/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import Firebase
import CoreMotion

class TrackWalkViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    var ref: DatabaseReference?
    let activity = CMMotionActivityManager()
    let pedometer = CMPedometer()
    
    var time = 0
    var timer = Timer()
    var startTime: Date!
    var endTime: Date!
    var presentDistance: String!
    var stepCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isHidden = true
    }
    
    private func startTrackingActivityType() {
        
        activity.startActivityUpdates(to: OperationQueue.main) {
            [weak self] (activity: CMMotionActivity?) in
            
            guard let activity = activity else { return }
                if activity.walking {
                    print("your ae walking")
                
                } else if activity.stationary {
                   print("you are stationary")
                } else if activity.running {
                    print("you are running")
                } else if activity.automotive {
                    print("you are automotive")
                }
        }
    }
    
    private func startCountingSteps() {
        
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else {
                print("error updating step count")
                return
            }
            DispatchQueue.main.async {
                self?.timeLabel.text = pedometerData.numberOfSteps.stringValue
            }
        }
    }
    
    private func startUpdating() {
        
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivityType()
        }
        
        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
        }
    }

    
    @IBAction func startButtonTapped(_ sender: Any) {
        //startTime = Date()
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(action), userInfo: nil, repeats: false)
        startButton.isEnabled = false
        startButton.alpha = 0.3
        startUpdating()
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        //endTime = Date()
        //timer.invalidate()
        doneButton.isHidden = false
        startButton.isEnabled = true
        startButton.alpha = 1
        activity.stopActivityUpdates()
        stepCount = Int(timeLabel.text!)!
        print(stepCount)
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        timer.invalidate()
        time = 0
        timeLabel.text = "0"
        stepCount = 0
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
        updateDatabase(stepCount: stepCount)
        dismiss(animated: true, completion: nil)
    }
    
    func updateDatabase(stepCount: Int) {
        
        ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com")
        let uid = Auth.auth().currentUser?.uid
        
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddmmyyyy"
        let key = formatter.string(from: today)
        
        let userReference = ref?.child("Users").child(uid!).child("Activities").child(key).child("Walk")
        let values = ["duration" : 0, "date" : Date.dateToString(date: Date()), "steps" : stepCount] as [String : Any]
        userReference?.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                print(error?.localizedDescription)
            }
            print("saved successfully")
            self.dismiss(animated: true, completion: nil)
        })
    }
}
