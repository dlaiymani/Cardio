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
    
    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore.init()
        }
    }
}
