//
//  WeeklyActivities+tableView.swift
//  Health
//
//  Created by Vikhyath on 05/10/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import UIKit

extension WeeklyActivitiesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksIdentifierCell") as? TasksIdentifierCell
        if indexPath.row == 0 {
            cell?.taskLabel.text = "Walk Tracker"
            cell?.imageView?.image = UIImage(named: "icons8-walking-96")
        } else {
            cell?.taskLabel.text = "Sleep Tracker"
            cell?.imageView?.image = UIImage(named: "icons8-sleep-96")
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let walk = storyboard?.instantiateViewController(withIdentifier: "WalkViewController") as? WalkViewController
            present(walk!, animated: true, completion: nil)
        } else {
            let sleep = storyboard?.instantiateViewController(withIdentifier: "SleepViewController") as? SleepViewController
            present(sleep!, animated: true, completion: nil)
        }
    }
    
}
