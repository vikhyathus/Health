//
//  SurveyViewController.swift
//  Health
//
//  Created by Vikhyath on 20/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit
import ResearchKit

class SurveyViewController: UIViewController {
    
    var surveyTaskviewController: ORKTaskViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        surveyTaskviewController = ORKTaskViewController(task: SurveyTask, taskRun: nil)
        surveyTaskviewController.delegate = self
        present(surveyTaskviewController, animated: true, completion: nil)
    }
    
}

extension SurveyViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        surveyTaskviewController.dismiss(animated: true, completion: nil)
        let tabView: UIViewController = storyboard?.instantiateViewController(withIdentifier: "TabViewController") as! UIViewController
        navigationController?.pushViewController(tabView, animated: true)
    }
}
