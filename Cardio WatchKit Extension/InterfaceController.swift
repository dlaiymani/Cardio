//
//  InterfaceController.swift
//  Cardio WatchKit Extension
//
//  Created by davidlaiymani on 29/08/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import CoreMotion


class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var stepsLabel: WKInterfaceLabel!
    @IBOutlet weak var bpmLabel: WKInterfaceLabel!
    @IBOutlet weak var startButton: WKInterfaceButton!
    
    let healthDataManager = HealthDataManager.sharedManager
    var isWorkoutInProgress = false
    
    var workoutSession: HKWorkoutSession?
    var workoutStartDate: Date?
    var heartRateQuery: HKQuery?
    var heartRateSamples = [HKQuantitySample]()
    
    let pedometer = CMPedometer()
    var totalSteps = 0
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        startButton.setEnabled(false)
        healthDataManager.authorizeHealthKit { (success, error) in
            if let error = error {
                print("Authorization failed with error \(error.localizedDescription)")
            } else {
                print("Authorization successfull")
                self.startButton.setEnabled(true)
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
