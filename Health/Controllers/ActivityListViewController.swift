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
    var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var placeHolderText: UILabel!
    @IBOutlet weak var placeholder: UIView!
    @IBOutlet weak var walkButtonView: UIView!
    @IBOutlet weak var sleepButtonView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var walkButton: UIButton!
    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setActivityIndicator()
        setUpViews()
        populateList(activity: "Walk", property: "steps")
        sort()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setActivityIndicator() {
        
        activityIndicator = {
            
            let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            activity.center = view.center
            activity.style = UIActivityIndicatorView.Style.gray
            activity.center = view.center
            activity.hidesWhenStopped = true
            //activity.isHidden = true
            return activity
        }()
        tableView.addSubview(activityIndicator)
    }
    
    func setUpViews() {
        
        walkButton.backgroundColor = Colors.orange
        sleepButton.backgroundColor = Colors.orange
        sleepButtonView.backgroundColor = Colors.orange
        headerView.backgroundColor = Colors.orange
        walkButtonView.backgroundColor = .white
        tableView.backgroundColor = UIColor.clear
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
        
        guard  let userID = userID else {
            return
        }
        activityList.removeAll()
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if !snapshot.hasChild("Activity") {
                self.view.isUserInteractionEnabled = true
                self.placeholder.isHidden = !self.activityList.isEmpty
                return
            }
        }
        
        ref.child(userID).child("Activities").child(activity).observeSingleEvent(of: .value) { snapshot in
            
            guard let days = snapshot.value as? NSDictionary else { self.tableView.reloadData(); return }
            self.activityIndicator.startAnimating()
            for ( _, value) in days {
                
                guard let walkDetails = value as? NSDictionary,
                let tempDate = walkDetails["date"] as? String,
                let propertyTemp = walkDetails[property] as? Int else { return }
                let date = Date.stringToDate(str: tempDate)
                self.activityList.append(WalkSleep(duration: 0, steps: propertyTemp, date: date))
            }
            self.sort()
            self.view.isUserInteractionEnabled = true
            self.placeholder.isHidden = !self.activityList.isEmpty
            self.tableView.isHidden = self.activityList.isEmpty
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
        
        sort()
        self.placeholder.isHidden = !self.activityList.isEmpty
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
        view.isUserInteractionEnabled = false
        activityList.removeAll()
        populateList(activity: "Walk", property: "steps")
        walkButtonView.backgroundColor = .white
        sleepButtonView.backgroundColor = Colors.orange
        iswalk = !iswalk
    }
    
    @IBAction private func sleepButtonTapped(_ sender: Any) {
        
        if !iswalk {
            return
        }
        placeholder.isHidden = true
        view.isUserInteractionEnabled = false
        activityList.removeAll()
        populateList(activity: "Sleep", property: "duration")
        sleepButtonView.backgroundColor = .white
        walkButtonView.backgroundColor = Colors.orange
        iswalk = !iswalk
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ActivityListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableCell", for: indexPath) as? ActivityTableCell
        
        let row = activityList[indexPath.row]
        cell?.dateLabel.text = Date.dateToString(date: row.date)
        
        var temp: String = ""
        if iswalk {
            temp = "Steps: \(row.steps)"
            if row.steps >= 200 {
                cell?.statusImage.tintColor = .green
                cell?.statusImage.image = UIImage(named: "icons8-checkmark-96")
            } else {
                cell?.statusImage.tintColor = .red
                cell?.statusImage.image = UIImage(named: "icons8-delete-96 copy")
            }
            cell?.durationLabel.text = temp
            
        } else {
            if row.steps >= 200 {
                cell?.statusImage.tintColor = .green
                cell?.statusImage.image = UIImage(named: "icons8-checkmark-96")
            } else {
                cell?.statusImage.tintColor = .red
                cell?.statusImage.image = UIImage(named: "icons8-delete-96 copy")
            }
            let hour = row.steps / 3600
            let minutes = row.steps / 60
            let seconds = row.steps % 60
            temp = "\(hour)h : \(minutes)min : \(seconds)sec"
            cell?.durationLabel.text = temp
        }
        cell?.selectionStyle = .none
        cell?.backgroundColor = UIColor.clear
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return activityList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
}
