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
    var userID: String!
    var didLoad: Bool = false
    
    
    @IBOutlet weak var walkButtonView: UIView!
    @IBOutlet weak var sleepButtonView: UIView!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        walkButtonView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if didLoad {
            tableView.reloadData()
        }
        didLoad = true
    }
    
    
    @IBAction func walkButtonTapped(_ sender: Any) {
        walkButtonView.backgroundColor = .white
        sleepButtonView.backgroundColor = .blue
    }
    
    @IBAction func sleepButtonTapped(_ sender: Any) {
        sleepButtonView.backgroundColor = .white
        walkButtonView.backgroundColor = .blue
    }
    
}

