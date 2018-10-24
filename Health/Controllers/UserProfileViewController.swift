//
//  UserProfileViewController.swift
//  Health
//
//  Created by Vikhyath on 26/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

//
//  UserProfileDetailViewController.swift
//  ResearchKit
//
//  Created by Vikhyath on 26/09/18.
//  Copyright © 2018 researchkit.org. All rights reserved.
//

import UIKit
import HealthKit
import Firebase
import NotificationCenter
import UserNotifications
import CoreData

class UserProfileViewController: UIViewController {
    
    var userDetails: [[String]] = []
    var physicalData: [String] = []
    var sampleTypes: [String] = []
    var isHealthKit: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var rewardLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var tableLabels = [["Age", "Gender", "Blood Type"], ["Weight", "Height", "BMI"], ["Goal"]]
    let userHealthProfile = UserHealthProfile()
    
    private enum ProfileDataError: Error {
        
        case missingBodyMassIndex
        
        var localizedDescription: String {
            switch self {
            case .missingBodyMassIndex:
                return "Unable to calculate body mass index with available profile data."
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        activityIndicator.startAnimating()
        print(userDetails)
        activityIndicator.hidesWhenStopped = true
        getUserNameEmail()
        tableView.delegate = self
        tableView.dataSource = self
        emailLabel.textColor = Colors.white
        NameLabel.textColor = Colors.white
        headerView.setGradientBackground(colorOne: Colors.orange, colorTwo: Colors.brightOrange)
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear
        imageView.layer.cornerRadius = imageView.frame.width / 2
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserDetailsFromFirebase()
        retrivePreviousReward()
    }
    
    func retrivePreviousReward() {
        
        let (status, userID) = FireBaseHelper.getUserID()
        guard status else {
            print(userID)
            return
        }
        let ref = Database.database().reference(fromURL: Urls.userurl).child(userID)
        ref.observeSingleEvent(of: .value) { datasnapshot in
            
            if datasnapshot.hasChild("rewardpoints") {
                guard let reward = datasnapshot.childSnapshot(forPath: "rewardpoints").value as? Int else { return }
                self.rewardLabel.text = "Reward points \(reward)"
            } else {
                self.rewardLabel.text = "0"
                return
            }
        }
    }
    
    func getUserNameEmail() {
        
        let (status, userId) = FireBaseHelper.getUserID()
        guard status else {
            print(userId)
            return
        }
        
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com/Users")
        ref.child(userId).observeSingleEvent(of: .value) { snapshot in
            
            guard let dataSnap = snapshot.value as? NSDictionary else {
                print("error fetching")
                return
            }
            guard let email = dataSnap.value(forKey: "email") as? String,
                let name = dataSnap.value(forKey: "name") as? String else {
                    self.activityIndicator.stopAnimating()
                    self.emailLabel.text = "Not available"
                    self.NameLabel.text = "Not available"
                    return
            }
            self.activityIndicator.stopAnimating()
            self.emailLabel.text = email
            self.NameLabel.text = name
        }
    }
    
    func updateHealthInfo() {
        
        userDetails.removeAll()
        physicalData.removeAll()
        sampleTypes.removeAll()
        loadAndDisplayAgeSexAndBloodType()
        userDetails.append(sampleTypes)
        loadAndDisplayMostRecentWeight()
        loadAndDisplayMostRecentHeight()
    }
    
    private func loadAndDisplayAgeSexAndBloodType() {
        
        do {
            let userAgeSexAndBloodType = try ProfileDataStore.getAgeSexAndBloodType()
            userHealthProfile.age = userAgeSexAndBloodType.age
            userHealthProfile.biologicalSex = userAgeSexAndBloodType.biologicalSex
            userHealthProfile.bloodType = userAgeSexAndBloodType.bloodType
            updateLabels()
        } catch let error {
            sampleTypes = ["unknown", "unknown", "unknown"]
            self.displayAlert(for: error)
            print("From load age sex and blood")
        }
    }
    
    private func updateLabels() {
        
        if let age = userHealthProfile.age {
            sampleTypes.append("\(age)")
        } else {
            sampleTypes.append("Not available")
        }
        
        if let biologicalSex = userHealthProfile.biologicalSex {
            sampleTypes.append(biologicalSex.stringRepresentation)
        } else {
            sampleTypes.append("Not available")
        }
        
        if let bloodType = userHealthProfile.bloodType {
            sampleTypes.append(bloodType.stringRepresentation)
        } else {
            sampleTypes.append("Not available")
        }
    }
    
    private func loadAndDisplayMostRecentHeight() {
        
        //1. Use HealthKit to create the Height Sample Type
        guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
            print("Height Sample Type is no longer available in HealthKit")
            return
        }
        
        ProfileDataStore.getMostRecentSample(for: heightSampleType) { sample, error in
            
            guard let sample = sample else {
                
                if let error = error {
                    self.displayAlert(for: error)
                    self.physicalData.append("Not available")
                    print("From height")
                    if self.physicalData.count == 2 {
                        self.saveBodyMassIndexToHealthKit()
                        self.userDetails.append(self.physicalData)
                        self.userDetails.append([">"])
                        self.tableView.reloadData()
                        //self.updateDatabase()
                        return
                    }
                }
                self.physicalData.append("Not available")
                if self.physicalData.count == 2 {
                    self.saveBodyMassIndexToHealthKit()
                    self.userDetails.append(self.physicalData)
                    self.userDetails.append([">"])
                    self.tableView.reloadData()
                    //self.updateDatabase()
                    return
                }
                return
            }
            
            //2. Convert the height sample to meters, save to the profile model,
            //   and update the user interface.
            let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
            self.userHealthProfile.heightInMeters = heightInMeters
            self.physicalData.append(String(format: "%.2f m", heightInMeters))
            if self.physicalData.count == 2 {
                self.tableLabels[1][1] = "Height"
                self.tableLabels[1][0] = "Weight"
                self.saveBodyMassIndexToHealthKit()
                if let bmi = self.userHealthProfile.bodyMassIndex {
                    let bmi2 = String(format: "%.2f", bmi)
                    self.physicalData.append(bmi2)
                } else {
                     self.physicalData.append("Unknown")
                }
                self.userDetails.append(self.physicalData)
                self.userDetails.append([">"])
                self.tableView.reloadData()
                //self.updateDatabase()
            }
        }
    }
    
    private func loadAndDisplayMostRecentWeight() {
        
        guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            print("Body Mass Sample Type is no longer available in HealthKit")
            return
        }
        
        ProfileDataStore.getMostRecentSample(for: weightSampleType) { sample, error in
            
            guard let sample = sample else {
                if let error = error {
                    self.displayAlert(for: error)
                    print("From weight")
                    self.physicalData.append("Not available")
                    if self.physicalData.count == 2 {
                        self.saveBodyMassIndexToHealthKit()

                        self.userDetails.append(self.physicalData)
                        self.userDetails.append([">"])
                        self.tableView.reloadData()
                        //self.updateDatabase()
                        return
                    }
                }
                self.physicalData.append("Not available")
                if self.physicalData.count == 2 {
                    self.saveBodyMassIndexToHealthKit()
                    self.userDetails.append(self.physicalData)
                    self.userDetails.append([">"])
                    self.tableView.reloadData()
                    //self.updateDatabase()
                    return
                }
                return
            }
            
            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            self.userHealthProfile.weightInKilograms = weightInKilograms
            self.physicalData.append(String(format: "%.2f kg", weightInKilograms))
            if self.physicalData.count == 2 {
                self.tableLabels[1][1] = "Weight"
                self.tableLabels[1][0] = "Height"
                self.saveBodyMassIndexToHealthKit()
                if let bmi = self.userHealthProfile.bodyMassIndex {
                    let bmi2 = String(format: "%.2f", bmi)
                    self.physicalData.append(bmi2)
                } else {
                    self.physicalData.append("Unknown")
                }
                self.userDetails.append(self.physicalData)
                self.userDetails.append([">"])
                self.tableView.reloadData()
                //self.updateDatabase()
            }
        }
    }
    
    private func saveBodyMassIndexToHealthKit() {
        
        guard let bodyMassIndex = userHealthProfile.bodyMassIndex else {
            //self.physicalData.append("Not available")
            //displayAlert(for: ProfileDataError.missingBodyMassIndex)
            return
        }
        ProfileDataStore.saveBodyMassIndexSample(bodyMassIndex: bodyMassIndex,
                                                 date: Date())
        
    }
    
    private func displayAlert(for error: Error) {
        
        let alert = UIAlertController(title: nil,
                                      message: "Fill the details in the health repository of your device",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "O.K.",
                                      style: .default,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func logoutTapped(_ sender: Any) {
        
            do {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                deleteObject()
                try? Auth.auth().signOut()
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.openHomeScreen()
                self.dismiss(animated: true, completion: nil)
            }
    }
    
//    func updateDatabase() {
//
//        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com")
//        let (status, message) = FireBaseHelper.getUserID()
//        guard status else {
//            print(message)
//            return
//        }
//        let userReference = ref.child("Users").child(message).child("userdetail")
//        var values = [String: String]()
//
//        for index in 0..<2 {
//            for rowIndex in 0..<userDetails[index].count {
//                values[tableLabels[index][rowIndex]] = userDetails[index][rowIndex]
//            }
//        }
//
//        userReference.updateChildValues(values, withCompletionBlock: { error, _ in
//            if error != nil {
//                print(error?.localizedDescription as Any)
//            }
//            print("saved successfully")
//        })
//    }
    
    func deleteObject() {
        
            let request1 = NSFetchRequest<WalkDetail>(entityName: "WalkDetail")
            let context1 = managedObjectContext()
            do {
                let obj = try context1.fetch(request1)
                for item in obj {
                    context1.delete(item)
                }
                try context1.save()
            } catch {
                print("error fetching walk")
            }
     
            let request2 = NSFetchRequest<SleepDetail>(entityName: "SleepDetail")
            let context2 = managedObjectContext()
            do {
                let obj = try context2.fetch(request2)
                for item in obj {
                    context2.delete(item)
                }
                try context2.save()
            } catch {
                print("error fetching sleep")
            }
    }
    
    func managedObjectContext() -> NSManagedObjectContext {
        
        let appdelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appdelegate?.persistentContainer.viewContext
        
        return context!
        
    }
    
    func fetchUserDetailsFromFirebase() {
        
        userDetails.removeAll()
        sampleTypes.removeAll()
        physicalData.removeAll()
        let (status, userID) = FireBaseHelper.getUserID()
        guard status else {
            print(userID)
            return
        }
        let ref = Database.database().reference(fromURL: Urls.userurl).child(userID).child("userdetail")
        ref.observeSingleEvent(of: .value, with: { data in

            guard let userDetails = data.value as? NSDictionary else {
                return
            }
            if let age = userDetails["Age"] as? String {
                self.sampleTypes.append(age)
            }
            if let gender = userDetails["Gender"] as? String {
                self.sampleTypes.append(gender)
            }
            if let bloodtype = userDetails["Blood Type"] as? String {
                self.sampleTypes.append(bloodtype)
            }
            if let weight = userDetails["Weight"] as? String {
                self.tableLabels[1][0] = "Weight"
                self.physicalData.append("\(weight) kg")
            }
            if let height = userDetails["Height"] as? String {
                self.tableLabels[1][1] = "Height"
                self.physicalData.append("\(height) m")
            }
            if let bmi = userDetails["Bmi"] as? String {
                self.physicalData.append(bmi)
            }

            self.userDetails.append(self.sampleTypes)
            self.userDetails.append(self.physicalData)
            self.userDetails.append([">"])
            self.tableView.reloadData()
        })
    }
    
    @IBAction private func syncButtonTapped(_ sender: Any) {
        
        if isHealthKit {
            fetchUserDetailsFromFirebase()
        } else {
             let alert = UIAlertController(title: "Sync", message: "Do you want to sync your profile with Health Kit", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                self.updateHealthInfo()
            }
            let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alert.addAction(yesAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }
        isHealthKit = !isHealthKit
    }
    
    @IBAction private func editButtonTapped(_ sender: Any) {
        guard let editScreen = storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController else {
            return
        }
        editScreen.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(editScreen, animated: true)
    }
    
 }
