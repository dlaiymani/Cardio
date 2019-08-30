//
//  HealthDataManager.swift
//  Cardio
//
//  Created by davidlaiymani on 29/08/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import Foundation
import HealthKit

protocol HeartRateDelegate {
    func heartRateUpdated(heartRateSamples: [HKSample])
}

class HealthDataManager: NSObject {
    
    static let sharedManager = HealthDataManager()
    
    var healthStore: HKHealthStore?
    
    var heartRateDelegate: HeartRateDelegate?
    
    var anchor: HKQueryAnchor?
    
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
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        guard let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return nil
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: compoundPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) in
        guard let newAnchor = newAnchor, let sampleObjects = sampleObjects else {
            return }
        self.anchor = newAnchor
        self.heartRateDelegate?.heartRateUpdated(heartRateSamples: sampleObjects)
        }
        return heartRateQuery
    }
}
