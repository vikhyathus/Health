//
//  ActivityListViewController+TableView.swift
//  Health
//
//  Created by Vikhyath on 25/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import UIKit

extension ActivityListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableCell", for: indexPath) as? ActivityTableCell
        let row = activityList[indexPath.row]
        cell?.dateLabel.text =  Date.dateToString(date: row.date)
        
        var temp: String!
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
    
}
