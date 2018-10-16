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
        cell?.selectionStyle = .none
        
        guard let unwrappedCell = cell else {
            return UITableViewCell()
        }
        return unwrappedCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        if section == 0 {
            label.text = "USER DETAILS"
        } else if section == 1 {
            label.text = "PHYSICAL DETAILS"
        } else {
            label.text = "SET GOALS"
        }

        label.backgroundColor = Colors.orange
        label.textAlignment = .center
        label.textColor = .white
        
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2 {
            print(indexPath.section)
            let controller = storyboard?.instantiateViewController(withIdentifier: "SetGoalViewController") as? SetGoalViewController
            guard let unwrappedController = controller else {
                return
            }
            self.present(unwrappedController, animated: true, completion: nil)
        }
    }
}
