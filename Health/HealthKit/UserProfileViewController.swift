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

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var bloodTypeLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!
    
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
        updateHealthInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateHealthInfo()
    }
    
    func updateHealthInfo() {
        loadAndDisplayAgeSexAndBloodType()
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
        }
    }
    
    private func updateLabels() {
        
        if let age = userHealthProfile.age {
            ageLabel.text = "\(age)"
        }
        
        if let biologicalSex = userHealthProfile.biologicalSex {
            genderLabel.text = biologicalSex.stringRepresentation
        }
        
        if let bloodType = userHealthProfile.bloodType {
            bloodTypeLabel.text = bloodType.stringRepresentation
        }
        
        if let weight = userHealthProfile.weightInKilograms {
            let weightFormatter = MassFormatter()
            weightFormatter.isForPersonMassUse = true
            weightLabel.text = weightFormatter.string(fromKilograms: weight)
        }
        
        if let height = userHealthProfile.heightInMeters {
            let heightFormatter = LengthFormatter()
            heightFormatter.isForPersonHeightUse = true
            heightLabel.text = heightFormatter.string(fromMeters: height)
        }
        
        if let bodyMassIndex = userHealthProfile.bodyMassIndex {
            bmiLabel.text = String(format: "%.02f", bodyMassIndex)
        }
    }
    
    private func loadAndDisplayMostRecentHeight() {
        
        //1. Use HealthKit to create the Height Sample Type
        guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
            print("Height Sample Type is no longer available in HealthKit")
            return
        }
        
        ProfileDataStore.getMostRecentSample(for: heightSampleType) { (sample, error) in
            
            guard let sample = sample else {
                
                if let error = error {
                    self.displayAlert(for: error)
                }
                
                return
            }
            
            //2. Convert the height sample to meters, save to the profile model,
            //   and update the user interface.
            let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
            self.userHealthProfile.heightInMeters = heightInMeters
            self.updateLabels()
        }
    }
    
    private func loadAndDisplayMostRecentWeight() {
        
        guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            print("Body Mass Sample Type is no longer available in HealthKit")
            return
        }
        
        ProfileDataStore.getMostRecentSample(for: weightSampleType) { (sample, error) in
            
            guard let sample = sample else {
                
                if let error = error {
                    self.displayAlert(for: error)
                }
                return
            }
            
            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            self.userHealthProfile.weightInKilograms = weightInKilograms
            self.updateLabels()
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
    
    
}
