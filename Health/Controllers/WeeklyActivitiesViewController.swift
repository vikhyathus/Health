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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var headerView: UIView!
    
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().delegate = self
        setUpNotification()
        createNotification()
        view.setGradientBackground(colorOne: Colors.blue, colorTwo: Colors.white)
        pageControl.pageIndicatorTintColor = Colors.lightorange
        pageControl.currentPageIndicatorTintColor = Colors.brightOrange
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        headerView.setGradientBackground(colorOne: Colors.lightorange, colorTwo: Colors.brightOrange)
        collectionView.reloadData()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        accessHealthKit()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func accessHealthKit() {
        
        guard   let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount) else {
                
            return
        }
        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
                                                        activeEnergy,
                                                        stepCount,
                                                        HKObjectType.workoutType()]
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       bloodType,
                                                       biologicalSex,
                                                       bodyMassIndex,
                                                       height,
                                                       bodyMass,
                                                       stepCount,
                                                       HKObjectType.workoutType()]
        
        if #available(iOS 12.0, *) {
            HKHealthStore().getRequestStatusForAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { requestStatus, error in
                print(requestStatus)
                if requestStatus == .shouldRequest {
                    let alert = UIAlertController(title: "Permission", message: "We need to accesss you health repo", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.authorizeHealthKit()
                    }))
                    
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { _, error in
                print(error)
            }
        }
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }

    func setUpNotification() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if error != nil {
                print("error registering notification")
            }
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
        UNUserNotificationCenter.current().add(request) { _ in
            print("This is title \(request.content.title)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //authorizeHealthKit()
    }

    @IBAction private func handleWalk(_ sender: UIButton) {
        //var walkingScreen: UIViewController = WalkViewController()
    }
    
    private func authorizeHealthKit() {
        
        HealthKitSetupAssistant.authorizeHealthKit { authorized, error in
            
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
    
    func retrieveGoal(completion: @escaping (Int, Int) -> ()) {
        
        var goalWalk = 200
        var goalSleep = 4 * 3600
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        let (status, message) = FireBaseHelper.getUserID()
        guard status else {
            print(message)
            completion(goalWalk, goalSleep)
            return
        }
        
        ref.child(message).observeSingleEvent(of: .value, with: { data in
            
            guard data.hasChild("goal") else {
                goalWalk = 200
                goalSleep = 4 * 3600
                return
            }
            let goalValue = data.childSnapshot(forPath: "goal")
            guard let goalDictionary = goalValue.value as? NSDictionary else {
                return
            }
            guard let previousWalk = goalDictionary["walkgoal"] as? Int else {
                return
            }
            guard let previousSleep = goalDictionary["sleepgoal"] as? Int else {
                return
            }
            goalWalk = previousWalk
            goalSleep = previousSleep
            completion(goalWalk, goalSleep)
        })
    }
    
    func fetchSleepWalkDetails(activity: String, property: String, completion: @escaping (Int) -> ()) {
        
        let userID = Auth.auth().currentUser?.uid
        var previousWalkDetails = 0
        
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        ref.child(userID!).child("Activities").child(activity).observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.hasChild(Date.getKeyFromDate()) {
                let snapshotData = snapshot.childSnapshot(forPath: Date.getKeyFromDate())
                guard let sleepDetails = snapshotData.value as? NSDictionary else { print("error"); return }
                previousWalkDetails = sleepDetails[property] as? Int ?? 0
                completion(previousWalkDetails)
                return
            } else {
                completion(previousWalkDetails)
            }
        }
        print("Outside \(previousWalkDetails)")
        completion(previousWalkDetails)
    }
}

extension WeeklyActivitiesViewController: UNUserNotificationCenterDelegate, ORKTaskViewControllerDelegate {
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        guard let results = taskViewController.result.results as? [ORKStepResult] else { return }
        let userID = Auth.auth().currentUser?.uid
        var values = [String: String]()
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        for stepResult: ORKStepResult in results {
            let stepResultCast = stepResult.results
            for result in stepResultCast! {
                if let questionResult = result as? ORKQuestionResult {
                    if questionResult.isMember(of: ORKChoiceQuestionResult.self) {
                        if let choiceAnswers = questionResult.answer as? NSArray {
                            let choiceIs = choiceAnswers.firstObject as? String
                            values[questionResult.identifier] = choiceIs
                            print(choiceIs)
                        }
                    }
                }
            }
        }
        print(values)
        ref.child(userID!).child("survey").child(Date.getKeyFromDate()).updateChildValues(values) { error, ref in
            if error != nil {
                print("error saing user data!")
                taskViewController.dismiss(animated: true, completion: nil)
                return
            }
            print("Successfull saved survey details")
        }
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

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension WeeklyActivitiesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeScreenCVCell", for: indexPath) as? HomeScreenCVCell
        
        if indexPath.row == 0 {
            retrieveGoal { (walkGoal, sleepGoal) in
                self.fetchSleepWalkDetails(activity: "Walk", property: "steps", completion: { (stepCount) in
                    let percent = CGFloat(stepCount) / CGFloat(walkGoal)
                    cell?.percentageLabel.text = "\(Int(percent * 100))%"
                    cell?.sleepWalkCountLabel.text = "\(stepCount) steps"
                    cell?.shapeLayer.strokeEnd = percent
                })
            }
        } else {
            retrieveGoal { (walkGoal, sleepGoal) in
                self.fetchSleepWalkDetails(activity: "Sleep", property: "duration", completion: { (sleepCount) in
                    let percent = CGFloat(sleepCount) / CGFloat(sleepGoal * 3600)
                    cell?.percentageLabel.text = "\(Int(percent * 100))%"
                    let hrs = sleepCount / 3600
                    let min = sleepCount / 60
                    let sec = sleepCount % 60
                    cell?.sleepWalkCountLabel.text = "\(hrs)hrs:\(min)min:\(sec)"
                    cell?.shapeLayer.strokeEnd = percent
                })
            }
        }
        return cell!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.x
        if contentOffset < UIScreen.main.bounds.width {
            pageControl.currentPage = 0
        } else {
            pageControl.currentPage = 1
        }
        print(contentOffset)
    }
    
}
