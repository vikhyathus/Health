//
//  UserProfileDetails + tableView.swift
//  Health
//
//  Created by Vikhyath on 01/10/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import UIKit

extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userDetails[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(userDetails.count)
        return userDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileViewCell") as? ProfileViewCell
        cell?.titleLabel.text = tableLabels[indexPath.section][indexPath.row]
        cell?.valueLabel.text = userDetails[indexPath.section][indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.text = "HEADER"
        label.backgroundColor = UIColor.blue
        label.textColor = .white
        
        return label
    }
}
