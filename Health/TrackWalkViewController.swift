//
//  TrackWalkViewController.swift
//  Health
//
//  Created by Vikhyath on 24/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit

class TrackWalkViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    
    
    var time = 0
    var timer = Timer()
    var startTime: Date!
    var endTime: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func startButtonTapped(_ sender: Any) {
        startTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(action), userInfo: nil, repeats: true)
        startButton.isEnabled = false
        startButton.alpha = 0.3
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        endTime = Date()
        timer.invalidate()
        startButton.isEnabled = true
        startButton.alpha = 1
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        timer.invalidate()
        time = 0
        timeLabel.text = String(time)
        startButton.isEnabled = true
        startButton.alpha = 1
    }
    
    @objc func action()  {
        time+=1
        timeLabel.text = String(time)
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
    }
}
