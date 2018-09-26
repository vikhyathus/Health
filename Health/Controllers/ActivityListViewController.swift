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
    var didLoad: Bool = false
    
    @IBOutlet weak var weekDaySegmentController: UISegmentedControl!
    @IBOutlet weak var walkSleepSegmentController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateList()
        tableView.delegate = self
        tableView.dataSource = self
        didLoad = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if didLoad {
            populateList()
            tableView.reloadData()
        }
        didLoad = true
        print("did appear")
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
            activityList.sorted(by: {$0.date > $1.date })
        }
    }
    
    func walkDay() {
        var tempDate: String!
        var date: Date!
        var duration: Double!
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        
        ref.child(userID).child("Activities").observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                for (_, value) in dict {
                    if let dict2 = value as? NSDictionary {
                        duration = dict2.value(forKey: "Walk") as? Double
                        tempDate = dict2.value(forKey: "Date") as? String
                        date = Date.stringToDate(str: tempDate)
                        self.activityList.append(WalkSleep(duration: duration, steps: 0, date: date))
                       
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
}

