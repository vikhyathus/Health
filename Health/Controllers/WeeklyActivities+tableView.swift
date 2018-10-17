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
            cell?.imageView?.image = UIImage(named: "group6")
        } else {
            cell?.taskLabel.text = "Sleep Tracker"
            cell?.imageView?.image = UIImage(named: "group11")
        }
        cell?.selectionStyle = .none
        guard let unwrappedCell = cell else {
            return UITableViewCell()
        }
        return unwrappedCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            guard let walk = storyboard?.instantiateViewController(withIdentifier: "TrackWalkViewController") as? TrackWalkViewController else { return }
            walk.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(walk, animated: true)
        } else {
            guard let sleep = storyboard?.instantiateViewController(withIdentifier: "SleepViewController") as? SleepViewController else { return }
            sleep.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(sleep, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100.0
    }
}
