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

// TODO: App in the background
// TODO: test different activity for the workout session (walking)

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
                self.createWorkoutSession()
            }
        }
    }
    
    
    func createWorkoutSession() {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other
        workoutConfiguration.locationType = .unknown
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthDataManager.healthStore!, configuration: workoutConfiguration)
            workoutSession?.delegate = self
        } catch {
            print(error)
        }
    }
    
    
    @IBAction func startOrStopWorkout() {
        
        if isWorkoutInProgress {
            endWorkoutSession()
        } else {
            startWorkoutSession()
        }
        isWorkoutInProgress = !isWorkoutInProgress
        print("yo")

        startButton.setTitle(isWorkoutInProgress ? "Stop" : "Start")
    }
    
    
    func startWorkoutSession() {
        print("yo")

        if self.workoutSession == nil {
            createWorkoutSession()
        }
        
        guard let session = workoutSession else {
            print("Cannot start a workout without a workout session")
            return
        }
        healthDataManager.healthStore!.start(session)
        self.workoutStartDate = Date()
    }
    
    func endWorkoutSession() {
        guard let session = workoutSession else {
            print("Cannot start a workout without a workout session")
            return
        }
        healthDataManager.healthStore!.end(session)
        saveWorkout()
    }
    
    
    func saveWorkout() {
        
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


extension InterfaceController: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            guard let workoutStartDate = workoutStartDate else { return }
            if let query = healthDataManager.createHeartRateStreamingQuery(workoutStartDate) {
                heartRateQuery = query
                healthDataManager.heartRateDelegate = self
                healthDataManager.healthStore!.execute(query)
                print("Running...")

            }
        case .ended:
            if let query = heartRateQuery {
                healthDataManager.healthStore!.stop(query)
            }
        default:
            print("Other workout state")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
                print("Workout failed with error \(error)")
    }
}


extension InterfaceController: HeartRateDelegate {
    func heartRateUpdated(heartRateSamples: [HKSample]) {
        guard let heartRateSamples = heartRateSamples as? [HKQuantitySample] else {
            return
        }
        
        DispatchQueue.main.async {
            guard let sample = heartRateSamples.first else { return }
        
            let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            let heartRateString = String(format: "%.00F", value)
            self.bpmLabel.setText(heartRateString)
        }
    }
}
