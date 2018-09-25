//
//  ActivityListViewController.swift
//  Health
//
//  Created by Vikhyath on 25/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import Firebase

class ActivityListViewController: UIViewController {

    var isWalk: Bool = true
    var isDay: Bool = true
    var activityList: [WalkSleep] = []
    var userID: String!
    
    @IBOutlet weak var weekDaySegmentController: UISegmentedControl!
    @IBOutlet weak var walkSleepSegmentController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //userID = Auth.auth().currentUser?.uid
        populateList()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        populateList()
        tableView.reloadData()
    }
    
    @IBAction func dayWeekSegmentController(_ sender: Any) {
        
        isDay = !isDay
        populateList()
        tableView.reloadData()
    }
    
    @IBAction func walkSleepSegmentControllerAction(_ sender: Any) {
        
        isWalk = !isWalk
        populateList()
        tableView.reloadData()
    }
    
    func populateList() {
        
        userID = Auth.auth().currentUser?.uid
        activityList.removeAll()
        if isWalk && isDay {
            walkDay()
        }
    }
    
    func walkDay() {
        var date: String!
        var duration: Double!
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        
        ref.child(userID).child("Activities").observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                for (key, value) in dict {
                    date = key as? String
                    if let dict2 = value as? NSDictionary {
                        for (_,v) in dict2 {
                            duration = v as? Double
                            self.activityList.append(WalkSleep(duration: duration, steps: 0, date: date))
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
}

