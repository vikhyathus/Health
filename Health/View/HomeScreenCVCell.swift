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
    
    
    override func awakeFromNib() {
        
        setUpProgressView(containerView: self)
        setUpPercentageLabel()
    }
    
    func setUpProgressView(containerView: UIView) {
        
        let center = containerView.center
        let circularPath = UIBezierPath(arcCenter: center, radius: 50, startAngle: -CGFloat.pi/2, endAngle: 3*CGFloat.pi/2, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = Colors.lightorange.cgColor
        trackLayer.lineWidth = 5
        trackLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = Colors.orange.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0
        
        self.layer.addSublayer(trackLayer)
        self.layer.addSublayer(shapeLayer)
    }
    
    func setUpPercentageLabel() {
        
        percentageLabel.text = "0%"
        percentageLabel.textColor = Colors.orange
        percentageLabel.textAlignment = .center
        percentageLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(15))
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        percentageLabel.center = self.center
        
        self.addSubview(percentageLabel)
    }
    
    func setUpCellForSteps() {
        
        updateUIwithWalkDetails(activity: "Walk", property: "steps") { steps in
            self.sleepWalkCountLabel.text = "\(steps) Steps"
        }
    }
    
    func setUpCellForSleep() {
        
        updateUIwithWalkDetails(activity: "Sleep", property: "duration")  { duration in
            let sec = duration % 60
            let min = duration / 60
            let hour = duration / 3600
            self.sleepWalkCountLabel.text = "\(hour)hrs:\(min)min:\(sec)sec"
        }
    }
    
    func updateUIwithWalkDetails(activity: String, property: String, completion: @escaping (Int) -> ()) {
        
        let userID = Auth.auth().currentUser?.uid
        var previousWalkDetails = 0
        let goal = 200
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        ref.child(userID!).child("Activities").child(activity).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.hasChild(Date.getKeyFromDate()) {
                let snapshotData = snapshot.childSnapshot(forPath: Date.getKeyFromDate())
                guard let sleepDetails = snapshotData.value as? NSDictionary else { print("error"); return }
                previousWalkDetails = sleepDetails[property] as? Int ?? 0
                let percent = CGFloat(previousWalkDetails) / CGFloat(goal)
                self.shapeLayer.strokeEnd = CGFloat(percent)
                self.percentageLabel.text = "\(Int(percent * 100))%"
                completion(previousWalkDetails)
                return
            } else {
                completion(previousWalkDetails)
            }
        }
        print("Outside \(previousWalkDetails)")
        
    }
}
