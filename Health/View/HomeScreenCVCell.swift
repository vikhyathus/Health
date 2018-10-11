//
//  HomeScreenCVCell.swift
//  FirebaseAuth
//
//  Created by Vikhyath on 09/10/18.
//

import UIKit
import Firebase

class HomeScreenCVCell: UICollectionViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var pageController: UIView!
    @IBOutlet weak var sleepWalkCountLabel: UILabel!
    
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    let percentageLabel = UILabel()
    var goalWalk = 200
    var goalSleep = 4 * 3600
    
    override func awakeFromNib() {
        
        setUpProgressView(containerView: self)
        setUpPercentageLabel()
        retrieveGoal()
        getGoals()
    }
    
    func getGoals() {
        
        if let saveddata = UserDefaults.standard.object(forKey: "walk") as? Int {
            goalWalk = saveddata
        } else {
            let shared = UserDefaults.standard
            shared.set(goalWalk, forKey: "walk")
        }
        
        if let saveddata = UserDefaults.standard.object(forKey: "sleep") as? Int {
            goalSleep = saveddata
        } else {
            let shared = UserDefaults.standard
            shared.set(goalWalk, forKey: "sleep")
        }
    }
    
    func retrieveGoal() {
        
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        let (status, message) = FireBaseHelper.getUserID()
        guard status else {
            print(message)
            return
        }
        
        ref.child(message).observeSingleEvent(of: .value, with: { data in
            
            guard data.hasChild("goal") else {
                self.goalWalk = 200
                self.goalSleep = 4 * 3600
                return
            }
            let goalValue = data.childSnapshot(forPath: "goal")
            guard let goalDictionary = goalValue.value as? NSDictionary else {
                return
            }
            guard let previousWalk = goalDictionary["walkgoal"] as? Int else {
                return
            }
            guard let previousSleep = goalDictionary["sleepgoal"] as? Int else {
                return
            }
            self.goalWalk = previousWalk
            self.goalSleep = previousSleep
        }) { error in
            print("completion block at error")
        }
    }
    
    func setUpProgressView(containerView: UIView) {
        
        let center = containerView.center
        let circularPath = UIBezierPath(arcCenter: center, radius: 50, startAngle: -CGFloat.pi/2, endAngle: 3*CGFloat.pi/2, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = Colors.white.cgColor
        trackLayer.lineWidth = 5
        trackLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = Colors.blue.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0
        
        self.layer.addSublayer(trackLayer)
        self.layer.addSublayer(shapeLayer)
    }
    
    func setUpPercentageLabel() {
        
        percentageLabel.text = "0%"
        percentageLabel.textColor = Colors.white
        percentageLabel.textAlignment = .center
        percentageLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(15))
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        percentageLabel.center = self.center
        
        self.addSubview(percentageLabel)
    }
    
    func setUpCellForSteps() {
        
        updateUIwithWalkDetails(activity: "Walk", property: "steps") { steps, percent in
            self.sleepWalkCountLabel.text = "\(steps) Steps"
            self.shapeLayer.strokeEnd = CGFloat(percent)
            self.percentageLabel.text = "\(Int(percent * 100))%"
        }
    }
    
    func setUpCellForSleep() {
        
        updateUIwithWalkDetails(activity: "Sleep", property: "duration") { duration, percent in
            let sec = duration % 60
            let min = duration / 60
            let hour = duration / 3600
            self.sleepWalkCountLabel.text = "\(hour)hrs:\(min)min:\(sec)sec"
            self.shapeLayer.strokeEnd = CGFloat(percent)
            self.percentageLabel.text = "\(Int(percent * 100))%"
        }
    }
    
    func updateUIwithWalkDetails(activity: String, property: String, completion: @escaping (Int, CGFloat) -> ()) {
        
        let userID = Auth.auth().currentUser?.uid
        var previousWalkDetails = 0

        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        ref.child(userID!).child("Activities").child(activity).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.hasChild(Date.getKeyFromDate()) {
                let snapshotData = snapshot.childSnapshot(forPath: Date.getKeyFromDate())
                guard let sleepDetails = snapshotData.value as? NSDictionary else { print("error"); return }
                previousWalkDetails = sleepDetails[property] as? Int ?? 0
                var percent: CGFloat = 0
                if activity == "Walk" {
                    percent = CGFloat(previousWalkDetails) / CGFloat(self.goalWalk)
                } else {
                    percent = CGFloat(previousWalkDetails) / CGFloat(self.goalSleep * 3600)
                }
                //self.shapeLayer.strokeEnd = CGFloat(percent)
                //self.percentageLabel.text = "\(Int(percent * 100))%"
                completion(previousWalkDetails, CGFloat(percent))
                return
            } else {
                completion(previousWalkDetails, 0)
            }
        }
        print("Outside \(previousWalkDetails)")
        completion(previousWalkDetails, 0)
    }
}
