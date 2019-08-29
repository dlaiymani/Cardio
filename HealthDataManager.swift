//
//  HealthDataManager.swift
//  Cardio
//
//  Created by davidlaiymani on 29/08/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import Foundation
import HealthKit

class HealthDataManager: NSObject {
    
    static let sharedManager = HealthDataManager()
    
    private var healthStore: HKHealthStore?
    
    private override init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore.init()
        }
    }
    
    func authorizeHealthKit(_ completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
    
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return }
        
        let typesToShare = Set([HKObjectType.workoutType(), heartRateType, stepCountType])
        let typesToRead = Set([HKObjectType.workoutType(), heartRateType, stepCountType])
        
        healthStore?.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if success {
                completion(success, nil)
            } else {
                completion(false, error)
            }
        }
    }
}
