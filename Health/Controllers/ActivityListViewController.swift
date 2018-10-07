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
    
    var activityList: [WalkSleep] = []
    var didLoad: Bool = false
    let userID = Auth.auth().currentUser?.uid
    var iswalk = true
    
    @IBOutlet weak var walkButtonView: UIView!
    @IBOutlet weak var sleepButtonView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var walkButton: UIButton!
    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        populateList(activity: "Walk", property: "steps")
        sort()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setUpViews() {
        
        walkButton.backgroundColor = Colors.orange
        sleepButton.backgroundColor = Colors.orange
        sleepButtonView.backgroundColor = Colors.orange
        headerView.backgroundColor = Colors.orange
        walkButtonView.backgroundColor = .white
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if didLoad {
            if iswalk {
                 populateList(activity: "Walk", property: "steps")
                 sort()
            } else {
                populateList(activity: "Sleep", property: "duration")
                sort()
            }
            tableView.reloadData()
        }
        didLoad = true
    }
    
    func populateList(activity: String, property: String) {
        
        activityList.removeAll()
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        ref.child(userID!).child("Activities").child(activity).observeSingleEvent(of: .value) { snapshot in
            guard let days = snapshot.value as? NSDictionary else { self.tableView.reloadData(); return }
            
            for ( _, value) in days {
                
                guard let walkDetails = value as? NSDictionary,
                let tempDate = walkDetails["date"] as? String,
                let propertyTemp = walkDetails[property] as? Int else { return }
                let date = Date.stringToDate(str: tempDate)
                self.activityList.append(WalkSleep(duration: 0, steps: propertyTemp, date: date))
            }
            self.sort()
            self.tableView.reloadData()
        }
        sort()
        tableView.reloadData()
    }
    
    func sort() {
        activityList = activityList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
    @IBAction private func walkButtonTapped(_ sender: Any) {
        
        if iswalk {
            return
        }
        activityList.removeAll()
        populateList(activity: "Walk", property: "steps")
        walkButtonView.backgroundColor = .white
        sleepButtonView.backgroundColor = Colors.orange
        iswalk = !iswalk
    }
    
    @IBAction func sleepButtonTapped(_ sender: Any) {
        
        if !iswalk {
            return
        }
        activityList.removeAll()
        populateList(activity: "Sleep", property: "duration")
        sleepButtonView.backgroundColor = .white
        walkButtonView.backgroundColor = Colors.orange
        iswalk = !iswalk
    }
}
