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
    var sec: Int = 0
    var min: Int = 0
    var hour: Int = 0
    var sleepCount: Int = 0
    var timeLabelString: String!
    var hourStr: String!
    var minStr: String!
    var secStr: String!
    var isStart = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeGround), name: UIApplication.willEnterForegroundNotification, object: nil)
        startButton.layer.borderColor = Colors.orange.cgColor
        startButton.setTitleColor(Colors.orange, for: .normal)
        startButton.layer.borderWidth = 1.0
    }
    
    @objc func pauseWhenBackground() {
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
        
        if !isStart {
            startButton.setTitle("Stop", for: .normal)
            startButton.backgroundColor = Colors.orange
            startButton.setTitleColor(Colors.white, for: .normal)
            startTime = Date()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(action), userInfo: nil, repeats: true)
            isStart = !isStart
        } else {
            startButton.setTitle("Start", for: .normal)
            startButton.backgroundColor = .white
            startButton.setTitleColor(Colors.orange, for: .normal)
            timer.invalidate()
            sleepCount  = time
            isStart = !isStart
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        removeSavedData()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func saveTapped(_ sender: Any) {
    
        getPreviousSleepCount { pre in
            self.sleepCount += pre
            self.updateDatabase(sleepCount: self.sleepCount)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func action() {
        
        time += 1
        sec += 1
        if sec == 60 {
            min += 1
            sec = 0
            if min == 60 {
                hour += 1
                min = 0
            }
        }
        if String(sec).count == 1 {
            secStr = "0\(sec)"
        } else {
            secStr = "\(sec)"
        }
        if String(hour).count == 1 {
            hourStr = "0\(hour)"
        } else {
            hourStr = "\(hour)"
        }
        if String(min).count == 1 {
            minStr = "0\(min)"
        } else {
            minStr = "\(min)"
        }
        timeLabelString = "\(hourStr!):\(minStr!):\(secStr!)"
        timeLabel.text = timeLabelString
    }
    
    func getPreviousSleepCount(completion: @escaping (Int) -> Void) {
        
        var previousSleepDetail = 0
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users/pA7l0khhOVanqUHODOkjPMX08XG2/Activities/Sleep")
        ref.child(Date.getKeyFromDate()).observeSingleEvent(of: .value) { snapshot in
            
            guard let sleepDetails = snapshot.value as? NSDictionary else { print("error"); return }
            print(sleepDetails["duration"])
            previousSleepDetail = sleepDetails["duration"] as? Int ?? 0
            print("Inside \(previousSleepDetail)")
            completion(previousSleepDetail)
        }
        completion(previousSleepDetail)
        print("Outside \(previousSleepDetail)")
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
        let key = Date.getKeyFromDate()
        
        let userReference = ref?.child("Users").child(uid!).child("Activities").child("Sleep").child(key)
        let values = ["duration" : sleepCount, "date" : Date.dateToString(date: Date()), "steps" : 0] as [String : Any]
        userReference?.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                print(error?.localizedDescription)
            }
            print("saved successfully")
            
        })
    }
    
}
