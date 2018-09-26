//
//  WeeklyActivitiesViewController.swift
//  Health
//
//  Created by Vikhyath on 21/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import Firebase
import HealthKit
import UserNotifications
import ResearchKit

class WeeklyActivitiesViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let  alert = UIAlertController(title: "Permission", message: "We need to accesss you health repo", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.authorizeHealthKit()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        UNUserNotificationCenter.current().delegate = self
        setUpNotification()
        createNotification()
    }
    

    func setUpNotification() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (sucess, error) in
            if error != nil {
                print("error registering notification")
            }
//            self.createNotification()
            
            let viewAction = UNNotificationAction(identifier: "ViewAction",
                                                  title: "Take Survey",
                                                  options: [.foreground])
            let category = UNNotificationCategory(identifier: "categoryIdentyifier",
                                                      actions: [viewAction],
                                                      intentIdentifiers: [],
                                                      options: [])
            UNUserNotificationCenter.current().setNotificationCategories([category])
            print("No error")
        }
    }
    
    func createNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "Health"
        content.subtitle = "Its survey time"
        content.body = "Please answer few questions for research purposes"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: "Identifier", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            print("This is title \(request.content.title)")
            print(error?.localizedDescription)
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //authorizeHealthKit()
    }
    @IBAction func logoutButtonTapped(_ sender: Any) {
        do {
            try! Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
    }
        
    
}
    @IBAction func handleWalk(_ sender: UIButton) {
        //var walkingScreen: UIViewController = WalkViewController()
    }
    
    private func authorizeHealthKit() {
        
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                
                return
            }
            
            print("HealthKit Successfully Authorized.")
        }
        
    }
    
}

extension WeeklyActivitiesViewController: UNUserNotificationCenterDelegate, ORKTaskViewControllerDelegate {
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true, completion: nil)
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let taskViewController = ORKTaskViewController(task: QuestionTask, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
        
    }
    
    
}
