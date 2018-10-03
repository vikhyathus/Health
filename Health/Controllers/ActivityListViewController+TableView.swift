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
        } else {
            let hour = Double(row.steps)/3600
            temp = String(format: "Duration: %.2f hr", hour)
        }
        cell?.durationLabel.text = temp
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
}
