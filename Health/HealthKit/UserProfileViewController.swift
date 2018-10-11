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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var tableLabels = [ ["Age", "Gender", "Blood Type"], ["Weight", "Height", "BMI"], ["Walk Goal", "Sleep Goal"]]
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
        updateHealthInfo()
        activityIndicator.startAnimating()
        print(userDetails)
        activityIndicator.hidesWhenStopped = true
        getUserNameEmail()
        tableView.delegate = self
        tableView.dataSource = self
        emailLabel.textColor = Colors.white
        NameLabel.textColor = Colors.white
        headerView.setGradientBackground(colorOne: Colors.orange, colorTwo: Colors.brightOrange)
        //navigationBar.setGradientBackground(colorOne: Colors.brightOrange, colorTwo: Colors.orange)
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //updateHealthInfo()
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func updateHealthInfo() {
        
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
    
    private func updateSamples() {
        
        if let weight = userHealthProfile.weightInKilograms {
            let weightFormatter = MassFormatter()
            weightFormatter.isForPersonMassUse = true
            physicalData.append(weightFormatter.string(fromKilograms: weight))
        }
        
        if let height = userHealthProfile.heightInMeters {
            let heightFormatter = LengthFormatter()
            heightFormatter.isForPersonHeightUse = true
            physicalData.append(heightFormatter.string(fromMeters: height))
        }
        
        if let bodyMassIndex = userHealthProfile.bodyMassIndex {
            physicalData.append(String(format: "%.02f", bodyMassIndex))
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
                        //let bmi = String(format: "%.2f", self.userHealthProfile.bodyMassIndex!)
                        //self.physicalData.append(bmi)
                        self.userDetails.append(self.physicalData)
                        self.userDetails.append([">", ">"])
                        self.tableView.reloadData()
                        self.updateDatabase()
                        return
                    }
                }
                self.physicalData.append("Not available")
                if self.physicalData.count == 2 {
                    self.saveBodyMassIndexToHealthKit()
                    //let bmi = String(format: "%.2f", self.userHealthProfile.bodyMassIndex!)
                    //self.physicalData.append(bmi)
                    self.userDetails.append(self.physicalData)
                    self.userDetails.append([">", ">"])
                    self.tableView.reloadData()
                    self.updateDatabase()
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
                self.userDetails.append([">", ">"])
                self.tableView.reloadData()
                self.updateDatabase()
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
                        self.userDetails.append([">", ">"])
                        self.tableView.reloadData()
                        self.updateDatabase()
                        return
                    }
                }
                self.physicalData.append("Not available")
                if self.physicalData.count == 2 {
                    self.saveBodyMassIndexToHealthKit()
                    self.userDetails.append(self.physicalData)
                    self.userDetails.append([">", ">"])
                    self.tableView.reloadData()
                    self.updateDatabase()
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
                self.userDetails.append([">", ">"])
                self.tableView.reloadData()
                self.updateDatabase()
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
    
    func updateDatabase() {
        
        let ref = Database.database().reference(fromURL: "https://health-d776c.firebaseio.com")
        let (status, message) = FireBaseHelper.getUserID()
        guard status else {
            print(message)
            return
        }
        let userReference = ref.child("Users").child(message).child("userdetail")
        var values = [String: String]()
        
        for index in 0..<2 {
            for rowIndex in 0..<userDetails[index].count {
                values[tableLabels[index][rowIndex]] = userDetails[index][rowIndex]
            }
        }
        
        userReference.updateChildValues(values, withCompletionBlock: { error, _ in
            if error != nil {
                print(error?.localizedDescription)
            }
            print("saved successfully")
        })
    }
    
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
    
 }
