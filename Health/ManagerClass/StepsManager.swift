//
//  StepsManager.swift
//  Health
//
//  Created by Vikhyath on 28/11/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import CoreMotion

var pedometer = CMPedometer()
var isStepCountStarted = false
var stepCounter = 0

class StepManager: NSObject {
    
    //var pedometer: CMPedometer?
    var counter = 0
    var stepHandler: ((NSNumber)->Void)?
    
    //A singleton instance
    static let sharedInstance: StepManager = StepManager()
    
    private override init() {
        super.init()
        pedometer = CMPedometer()
    }
    
    func startPadameterUpdates() {
        
        pedometer.startUpdates(from: Date(), withHandler: { pedometerData, error in
            
            isStepCountStarted = true
            if let handler = self.stepHandler {
                handler(pedometerData?.numberOfSteps ?? 0)
            }
        })
    }

}
