//
//  ActivityListViewController.swift
//  Health
//
//  Created by Vikhyath on 25/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import Firebase
import CoreData

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
        fetch()
        //populateList(activity: "Walk", property: "steps")
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
        //headerView.setGradientBackground(colorOne: Colors.orange, colorTwo: Colors.brightOrange)
        //walkButton.setGradientBackground(colorOne: Colors.brightOrange, colorTwo: Colors.orange)
        //sleepButton.setGradientBackground(colorOne: Colors.orange, colorTwo: Colors.brightOrange)
        walkButtonView.backgroundColor = .white
        walkButton.layer.borderWidth = 0
        sleepButton.layer.borderWidth = 0
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
        
        activityList.removeAll()
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if !snapshot.hasChild("Activity") {
                self.view.isUserInteractionEnabled = true
                self.placeholder.isHidden = !self.activityList.isEmpty
                return
            }
        }
        
        fetch()
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                self.callAPI(activity: activity, property: property)
            } else {
                self.fetch()
                self.view.isUserInteractionEnabled = true
            }
        })
        self.placeholder.isHidden = !self.activityList.isEmpty
    }
    
    func callAPI(activity: String, property: String) {
        
        guard  let userID = userID else {
            return
        }
        
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
            ref.child(userID).child("Activities").child(activity).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let days = snapshot.value as? NSDictionary else { self.tableView.reloadData(); return }
            self.activityList.removeAll()
            self.activityIndicator.startAnimating()
            for ( _, value) in days {
                
                guard let walkDetails = value as? NSDictionary,
                    let tempDate = walkDetails["date"] as? String,
                    let propertyTemp = walkDetails[property] as? Int else { return }
                let date = Date.stringToDate(str: tempDate)
                self.activityList.append(WalkSleep(duration: 0, steps: propertyTemp, date: date))
            }
            self.addToCoreData()
            self.fetch()
            self.view.isUserInteractionEnabled = true
            self.placeholder.isHidden = !self.activityList.isEmpty
            self.tableView.isHidden = self.activityList.isEmpty
            //self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        })
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
        fetch()
        iswalk = !iswalk
        
        view.isUserInteractionEnabled = false
        activityList.removeAll()
        populateList(activity: "Walk", property: "steps")
        walkButtonView.backgroundColor = .white
        sleepButtonView.backgroundColor = Colors.orange
    }
    
    @IBAction private func sleepButtonTapped(_ sender: Any) {
        
        if !iswalk {
            return
        }
        fetch()
        iswalk = !iswalk
        placeholder.isHidden = true
        view.isUserInteractionEnabled = false
        activityList.removeAll()
        populateList(activity: "Sleep", property: "duration")
        sleepButtonView.backgroundColor = .white
        walkButtonView.backgroundColor = Colors.orange
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

extension ActivityListViewController {
    
    func addToCoreData() {
        deleteObject()
        for activity in activityList {
            addObject(object: activity)
        }
        //fetch()
    }
    
    func deleteObject() {
        
        if iswalk {
            let request = NSFetchRequest<WalkDetail>(entityName: "WalkDetail")
            let context = managedObjectContext()
            do {
                let obj = try context.fetch(request)
                for item in obj {
                    context.delete(item)
                }
                try context.save()
            } catch {
                print("error fetching walk")
            }
        } else {
            let request = NSFetchRequest<SleepDetail>(entityName: "SleepDetail")
            let context = managedObjectContext()
            do {
                let obj = try context.fetch(request)
                for item in obj {
                    context.delete(item)
                }
                try context.save()
            } catch {
                print("error fetching sleep")
            }
        }
    }

    func fetch() {
        
        let context = managedObjectContext()
        activityList.removeAll()
        
        if iswalk {
            let request = NSFetchRequest<WalkDetail>(entityName: "WalkDetail")
            request.returnsObjectsAsFaults = false
            do {
                let walkHistory = try context.fetch(request)
                for walk in walkHistory {
                    activityList.append(WalkSleep(duration: 0, steps: Int(walk.steps), date: (walk.date as Date?)!))
                }
                print(activityList)
                self.sort()
                tableView.reloadData()
                //view.isUserInteractionEnabled = true
            } catch {
                print("Error fetching data from core data")
            }
        } else {
            let request = NSFetchRequest<SleepDetail>(entityName: "SleepDetail")
            request.returnsObjectsAsFaults = false
            do {
                let sleepHistory = try context.fetch(request)
                for sleep in sleepHistory {
                    activityList.append(WalkSleep(duration: 0, steps: Int(sleep.duration), date: (sleep.date as Date?)!))
                }
                self.sort()
                tableView.reloadData()
                //view.isUserInteractionEnabled = true
            } catch {
                print("Error fetching data from core data")
            }
        }
    }
    
    func addObject(object: WalkSleep) {
        
        let context = managedObjectContext()
        
        if iswalk {
            let entity = NSEntityDescription.insertNewObject(forEntityName: "WalkDetail", into: context) as? WalkDetail
            entity?.date = object.date as? NSDate
            entity?.steps = Int32(object.steps)
            do {
                try context.save()
            } catch {
                print("error")
            }
        } else {
            let entity = NSEntityDescription.insertNewObject(forEntityName: "SleepDetail", into: context) as? SleepDetail
            entity?.date = object.date as? NSDate
            entity?.duration = Int32(object.steps)
            do {
                try context.save()
            } catch {
                print("error")
            }
        }
        

    }
    
    func managedObjectContext() -> NSManagedObjectContext {
        
        let appdelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appdelegate?.persistentContainer.viewContext
        
        return context!
        
    }
}
