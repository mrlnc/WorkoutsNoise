//
//  HealthKit.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 25.05.23.

// source: Good Spirits by Alexei Baboulevitch, GPLv3

import Foundation
import HealthKit

class HealthKit
{
    static let shared = HealthKit()
    
    let typesToRead: Set = [
        // Workouts and their locations
        HKSeriesType.workoutType(),
        HKSeriesType.workoutRoute(),
        
        // Environmental noise
        HKQuantityType(.environmentalAudioExposure),
        HKCategoryType(.environmentalAudioExposureEvent)
    ]
    
    public enum HealthKitError: StringLiteralType, Error, LocalizedError
    {
        case notAvailable
        case notAuthorized
        case notEnabled
        case notReady
        case unknown
        
        public var errorDescription: String?
        {
            return self.rawValue
        }
    }
    
    // TOOD: should have enabledAndUnauthorized so that we can still disable HK even when unauthorized
    private var loginPending: Bool = false
    public enum HealthKitLoginStatus
    {
        case unavailable
        case unauthorized
        case disabled
        case pendingAuthorization
        case enabledAndAuthorized
        case unknown
    }
    
    var loginStatus: HealthKitLoginStatus
    {
        if self.loginPending
        {
            return .pendingAuthorization
        }
        
        if let status = HealthKit.shared.authStatus()
        {
            switch status
            {
            case .notDetermined:
                return .disabled
            case .sharingAuthorized:
                return .enabledAndAuthorized
            case .sharingDenied:
                return .unauthorized
            @unknown default:
                return .unknown
            }
        }
        else
        {
            return .unavailable
        }
    }
    
    var store: HKHealthStore? =
    {
        if HKHealthStore.isHealthDataAvailable()
        {
            let store = HKHealthStore()
            return store
        }
        else
        {
            return nil
        }
    }()
    
    func authStatus() -> HKAuthorizationStatus?
    {
        let type = HKQuantityType.quantityType(forIdentifier: .environmentalAudioExposure)!
        return self.store?.authorizationStatus(for: type)
    }
}

// Model interface.
extension HealthKit
{
    func authorize(block: @escaping (Error?)->Void)
    {
        switch self.loginStatus
        {
        case .unavailable:
            block(HealthKitError.notAvailable)
            return
        case .unauthorized:
            block(HealthKitError.notAuthorized)
            return
        case .disabled:
            break
        case .pendingAuthorization:
            block(HealthKitError.notReady)
        case .enabledAndAuthorized:
            block(nil)
            return
        case .unknown:
            block(nil)
            return
        }
                
    authorizeHealthKit: do
    {
        // no need to authorize, already done
        if HealthKit.shared.authStatus() == .sharingAuthorized
        {
            block(nil)
        }
        // need to attempt authorization
        else
        {
            self.loginPending = true
            
            HealthKit.shared.store?.requestAuthorization(toShare: nil, read: typesToRead)
            { [weak `self`] (success, error) in
                onMain
                {
                    self?.loginPending = false
                    
                    if success
                    {
                        block(nil)
                    }
                    else
                    {
                        if let error = error
                        {
                            block(error)
                        }
                        else
                        {
                            block(HealthKitError.unknown)
                        }
                    }
                }
            }
        }
    }
    }
}
