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
    let goal = 200
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    
    let percentageLabel: UILabel = {
        
        let label = UILabel()
        label.text = "0%"
        label.textColor = Colors.orange
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: CGFloat(20))
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeGround), name: UIApplication.willEnterForegroundNotification, object: nil)
        startButton.layer.borderColor = Colors.orange.cgColor
        startButton.setTitleColor(Colors.orange, for: .normal)
        startButton.layer.borderWidth = 1.0
        setUpProgressView()
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUIwithPreviousData()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        updateUIwithPreviousData()
//    }
    
    func updateUIwithPreviousData() {
        
        let userID = Auth.auth().currentUser?.uid
        var previousSleepDetail = 0
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com")
        
        ref.child("Users").child(userID!).child("Activities").child("Sleep").observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild(Date.getKeyFromDate()) {
                let snapshotData = snapshot.childSnapshot(forPath: Date.getKeyFromDate())
                guard let sleepDetails = snapshotData.value as? NSDictionary else { print("error"); return }
                print(sleepDetails["duration"])
                previousSleepDetail = sleepDetails["duration"] as? Int ?? 0
                print("Inside \(previousSleepDetail)")
                self.sleepCount = previousSleepDetail
                self.time = previousSleepDetail
                self.sec = (Int(self.time) % 60)
                self.min = (Int(self.time) / 60)
                self.hour = (Int(self.time) / 3600)
                let percent = CGFloat(self.sleepCount)/CGFloat(self.goal)
                self.shapeLayer.strokeEnd = percent
                self.percentageLabel.text = "\(Int(percent*100))%"
                self.updateUI()
                return
            } else {
                self.sleepCount = previousSleepDetail
                return
            }
        }
        return
            print("Outside \(previousSleepDetail)")
    }
    
    func setUpProgressView() {
        
        let center = view.center
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi/2, endAngle: 3*CGFloat.pi/2, clockwise: true)
        
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = Colors.lightorange.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = Colors.orange.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(trackLayer)
        view.layer.addSublayer(shapeLayer)
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
        print(time)
        print(timeDiff)
        time += Int(timeDiff)
        sec = (Int(time) % 60)
        min = (Int(time) / 60)
        hour = (Int(time) / 3600)
        updateUI()
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
    
        sleepCount = time
        updateDatabase(sleepCount: sleepCount)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func action() {
        
        var percent = 0.0
        time += 1
        percent = Double(time)/Double(goal)
        self.shapeLayer.strokeEnd = CGFloat(percent)
        self.percentageLabel.text = "\(Int(percent*100))%"
        updateUI()
    }
    
    func updateUI() {
        sec += 1
        if sec >= 60 {
            if sec == 60 {
                min += 1
            }
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
    
    func getPreviousSleepCount() {
        
        let userID = Auth.auth().currentUser?.uid
        var previousSleepDetail = 0
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com")
        
        ref.child("Users").child(userID!).child("Activities").child("Sleep").observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild(Date.getKeyFromDate()) {
                let snapshotData = snapshot.childSnapshot(forPath: Date.getKeyFromDate())
                guard let sleepDetails = snapshotData.value as? NSDictionary else { print("error"); return }
                print(sleepDetails["duration"])
                previousSleepDetail = sleepDetails["duration"] as? Int ?? 0
                print("Inside \(previousSleepDetail)")
                self.sleepCount += previousSleepDetail
                self.updateDatabase(sleepCount: self.sleepCount)
                return
            } else {
                self.updateDatabase(sleepCount: self.sleepCount)
                return
            }
        }
        return
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
        let values = ["duration": sleepCount, "date": Date.dateToString(date: Date()), "steps": 0] as [String: Any]
        
        userReference?.updateChildValues(values, withCompletionBlock: { error, _ in
            if error != nil {
                print(error?.localizedDescription)
            }
            print("saved successfully")
        })
    }
    
}
