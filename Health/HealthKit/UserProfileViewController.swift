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

class UserProfileViewController: UIViewController {
    
    
    var userDetails: [[String]] = []
    var physicalData: [String] = []
    var sampleTypes: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var tableLabels = [ ["Age", "Gender", "Blood Type"], ["Weight", "Height", "BMI"]]
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
        print(userDetails)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //updateHealthInfo()
    
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
            self.displayAlert(for: error)
            print("From load age sex and blood")
        }
    }
    
    private func updateLabels() {
        
        if let age = userHealthProfile.age {
            sampleTypes.append("\(age)")
        }
        
        if let biologicalSex = userHealthProfile.biologicalSex {
            sampleTypes.append(biologicalSex.stringRepresentation)
        }
        
        if let bloodType = userHealthProfile.bloodType {
            sampleTypes.append(bloodType.stringRepresentation)
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
                    print("From height")
                }
                
                return
            }
            
            //2. Convert the height sample to meters, save to the profile model,
            //   and update the user interface.
            let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
            self.userHealthProfile.heightInMeters = heightInMeters
            self.physicalData.append(String(format: "%.2f m", heightInMeters))
            if self.physicalData.count == 2 {
                self.saveBodyMassIndexToHealthKit()
                let bmi = String(format: "%.2f", self.userHealthProfile.bodyMassIndex!)
                self.physicalData.append(bmi)
                self.userDetails.append(self.physicalData)
                self.tableView.reloadData()
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
                }
                return
            }
            
            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            self.userHealthProfile.weightInKilograms = weightInKilograms
            self.physicalData.append(String(format: "%.2f kg", weightInKilograms))
            if self.physicalData.count == 2 {
                self.saveBodyMassIndexToHealthKit()
                let bmi = String(format: "%.2f", self.userHealthProfile.bodyMassIndex!)
                self.physicalData.append(bmi)
                self.userDetails.append(self.physicalData)
                self.tableView.reloadData()
            }
        }
    }
    
    private func saveBodyMassIndexToHealthKit() {
        
        guard let bodyMassIndex = userHealthProfile.bodyMassIndex else {
            displayAlert(for: ProfileDataError.missingBodyMassIndex)
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
    
    @IBAction func logoutTapped(_ sender: Any) {
        
            do {
                try? Auth.auth().signOut()
                self.dismiss(animated: true, completion: nil)
            }
    }
 }
    
    

