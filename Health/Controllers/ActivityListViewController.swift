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
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setUpViews() {
        
        walkButton.backgroundColor = UIColor.init(red: 26/255, green: 26/255, blue: 255/255, alpha: 1)
        sleepButton.backgroundColor = UIColor.init(red: 26/255, green: 26/255, blue: 255/255, alpha: 1)
        sleepButtonView.backgroundColor = UIColor.init(red: 26/255, green: 26/255, blue: 255/255, alpha: 1)
        headerView.backgroundColor = UIColor.init(red: 26/255, green: 26/255, blue: 255/255, alpha: 1)
        walkButtonView.backgroundColor = .white
        //tableView.setGradientBackground(colorOne: Colors.blue, colorTwo: Colors.white)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if didLoad {
            if iswalk {
                 populateList(activity: "Walk", property: "steps")
            } else {
                populateList(activity: "Sleep", property: "duration")
            }
            tableView.reloadData()
        }
        didLoad = true
    }
    
    func populateList(activity: String, property: String) {
        
        activityList.removeAll()
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        ref.child(userID!).child("Activities").child(activity).observeSingleEvent(of: .value) { (snapshot) in
            guard let days = snapshot.value as? NSDictionary else { self.tableView.reloadData(); return }
            
            for ( _, value) in days {
                
                guard let walkDetails = value as? NSDictionary,
                let tempDate = walkDetails["date"] as? String,
                let propertyTemp = walkDetails[property] as? Int else { return }
                let date = Date.stringToDate(str: tempDate)
                self.activityList.append(WalkSleep(duration: 0, steps: propertyTemp, date: date))
            }
            self.tableView.reloadData()
        }
        tableView.reloadData()
    }
    
    
    @IBAction func walkButtonTapped(_ sender: Any) {
        
        if iswalk {
            return
        }
        populateList(activity: "Walk", property: "steps")
        iswalk = !iswalk
        walkButtonView.backgroundColor = .white
        sleepButtonView.backgroundColor = UIColor.init(red: 26/255, green: 26/255, blue: 255/255, alpha: 1)
    }
    
    @IBAction func sleepButtonTapped(_ sender: Any) {
        
        if !iswalk {
            return
        }
        iswalk = !iswalk
        populateList(activity: "Sleep", property: "duration")
        sleepButtonView.backgroundColor = .white
        walkButtonView.backgroundColor = UIColor.init(red: 26/255, green: 26/255, blue: 255/255, alpha: 1)
    }
    
}

