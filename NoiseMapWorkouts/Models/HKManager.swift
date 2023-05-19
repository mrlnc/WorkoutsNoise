import Foundation
import HealthKit

class HKManager: NSObject, ObservableObject {
    static let shared = HKManager()
    let healthStore = HKHealthStore()
    
    let typesToRead: Set = [
        // Workouts and their locations
        HKSeriesType.workoutType(),
        HKSeriesType.workoutRoute(),
        
        // Environmental noise
        HKQuantityType(.environmentalAudioExposure),
        HKCategoryType(.environmentalAudioExposureEvent)
    ]
    
    var authorizationStatus: Bool {
        var authorized = true
        let semaphore = DispatchSemaphore(value: 0)
        
        healthStore.getRequestStatusForAuthorization(toShare: [], read: typesToRead) { status, error in
            if let error = error {
                fatalError("*** Error during HealthKit status request: \(error.localizedDescription) ***")
            }
            print("HealthKit authorization status: \(status)")
            switch status {
            case .unknown:
                authorized = false
                print("Authorization request status unknown")
            case .shouldRequest:
                authorized = false
                print("Authorization request should be made")
            case .unnecessary:
                print("Authorization is unnecessary")
            @unknown default:
                break
            }
            semaphore.signal()
        }
        semaphore.wait()
        return authorized
    }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }
}

