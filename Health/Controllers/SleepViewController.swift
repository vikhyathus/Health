//
//  SleepViewController.swift
//  Health
//
//  Created by Vikhyath on 27/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import NotificationCenter
import Firebase

class SleepViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var timer = Timer()
    var startTime: Date!
    var endTime: Date!
    var time = 0
    var sleepCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeGround), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    @objc func pauseWhenBackground()  {
        timer.invalidate()
        let shared = UserDefaults.standard
        shared.set(Date(), forKey: "savedTime")
        print("paused called")
    }
    
    @objc func willEnterForeGround() {
        if let saveddata = UserDefaults.standard.object(forKey: "savedTime") as? Date {
            let timeDifference = getTimeDifference(savedData: saveddata)
            refresh(timeDiff: timeDifference)
            
        }
        print("foreground entry")
    }
    
    func refresh(timeDiff: TimeInterval) {
        time += Int(timeDiff)
        timeLabel.text = "\(time)"
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(action), userInfo: nil, repeats: true)
    }
    
    func getTimeDifference(savedData: Date) -> TimeInterval {
        
        let diff = Date().timeIntervalSince(savedData)

        return diff
    }
    
    @IBAction func startTapped(_ sender: Any) {
        
        startButton.isEnabled = false
        startButton.alpha = 0.4
        startTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(action), userInfo: nil, repeats: true)
    }
    
    @IBAction func stopTapped(_ sender: Any) {
        
        startButton.isEnabled = true
        startButton.alpha = 1
        timer.invalidate()
        sleepCount  = time
    }
    
    @IBAction func resetTapped(_ sender: UIButton) {
        removeSavedData()
        time = 0
        timeLabel.text = "\(time)"
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        updateDatabase(sleepCount: sleepCount)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func action()  {
        time+=1
        timeLabel.text = String(time)
    }
    
    func removeSavedData() {
        if (UserDefaults.standard.object(forKey: "savedTime") as? Date) != nil {
            UserDefaults.standard.removeObject(forKey: "savedTime")
        }
    }
    
    func updateDatabase(sleepCount: Int) {
        
        var ref: DatabaseReference?
        ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com")
        let uid = Auth.auth().currentUser?.uid
        
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddmmyyyy"
        let key = formatter.string(from: today)
        
        let userReference = ref?.child("Users").child(uid!).child("Activities").child(key).child("Sleep")
        let values = ["duration" : sleepCount, "date" : Date.dateToString(date: Date()), "steps" : 0] as [String : Any]
        userReference?.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                print(error?.localizedDescription)
            }
            print("saved successfully")
            
        })
    }
    
}
