//
//  Workout.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 19.05.23.
//

import Foundation
import HealthKit
import MapKit
import Combine
import UniformTypeIdentifiers
import SwiftUI

enum WorkoutDataQuality: CustomStringConvertible {
    case missingLocationData
    case missingNoiseData
    case missingLocationAndNoiseData
    case OK
    
    var description : String {
        switch self {
        case .missingLocationData: return "dataquality_missing_location".localized()
        case .missingNoiseData: return "dataquality_missing_noise".localized()
        case .missingLocationAndNoiseData: return "dataquality_missing_both".localized()
        case .OK: return "dataquality_ok".localized()
        }
    }
}

struct NoiseMeasurement: Identifiable {
    var id = UUID()
    var sample: HKQuantity
    var interval: DateInterval
    var locations = [CLLocation]()
}

struct HistogramBin {
    var lowerBound: HKQuantity
    var upperBound: HKQuantity
    var duration: Double
    var averageNoise: Double
}

struct LevelExposure {
    var green: TimeInterval
    var yellow: TimeInterval
    var red: TimeInterval
}

class Workout: NSObject, ObservableObject, Identifiable {
    private let healthStore = HKManager.shared.healthStore
    
    static var readableContentTypes = [UTType.plainText]
    var settings = Settings.shared
    
    private(set) var workout: HKWorkout
    private(set) var path: [CLLocation]?
    private(set) var noiseMeasurements: [NoiseMeasurement]?
    private(set) var noiseWarnings: [HKSample]? // TODO
    private(set) var done = false
    
    var dataQuality: WorkoutDataQuality {
        var missingLocation = true
        var missingNoise = true
        
        if let noiseMeasurements = noiseMeasurements {
            missingNoise = noiseMeasurements.isEmpty
        }
        if let path = path {
            missingLocation = path.isEmpty
        }
        
        if missingNoise && missingLocation {
            return WorkoutDataQuality.missingLocationAndNoiseData
        }
        if missingNoise {
            return WorkoutDataQuality.missingNoiseData
        }
        if missingLocation  {
            return WorkoutDataQuality.missingLocationData
        }
        return WorkoutDataQuality.OK
    }
    
    private let changePublisher = PassthroughSubject<Void, Never>()
    
    private var query = [HKQuery]()
    
    var avg: Double = 0
    var min: Double = 0
    var max: Double = 0
    
    var id = UUID()
    
    var levelExposure: LevelExposure {
        var results = LevelExposure(green: 0, yellow: 0, red: 0)
        
        guard let noiseMeasurements = noiseMeasurements else {
            return results
        }
        
        for sample in noiseMeasurements {
            if sample.sample.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()) < Double(settings.upperLimitGreen) {
                results.green += sample.interval.duration
            } else if sample.sample.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()) < Double(settings.upperLimitYellow) {
                results.yellow += sample.interval.duration
            } else {
                results.red += sample.interval.duration
            }
        }
        
        return results
    }
    
    init(workout: HKWorkout) {
        self.workout = workout
        super.init()
    }
    
    // query data from HealthKit
    func fetchWorkoutDetails() {
        let fetchGroup = DispatchGroup()
        let publishGroup = DispatchGroup()
        let backgroundQueue = DispatchQueue.global(qos: .background)
        
        var locations: [CLLocation]?
        var noiseMeasurements: [NoiseMeasurement]?
        var noiseWarnings: [HKSample]?
        var error: Error?
        
        var avg: Double = 0
        var max: Double = 0
        var min: Double = 0
        
        var histogram: [HistogramBin]?
        
        if self.done {
            // we already fetched all data before
            return
        }
        
        publishGroup.enter()
        fetchGroup.enter()
        backgroundQueue.async(group: fetchGroup) {
            self.fetchLocations() { result, resultError in
                locations = result
                error = resultError
                fetchGroup.leave()
            }
        }
        
        fetchGroup.enter()
        backgroundQueue.async(group: fetchGroup) {
            self.fetchNoiseMeasurements(startDate: self.workout.startDate, endDate: self.workout.endDate) { results, resultError in
                noiseMeasurements = results
                error = resultError
                fetchGroup.leave()
            }
        }
        
        fetchGroup.enter()
        backgroundQueue.async(group: fetchGroup) {
            self.fetchAvgWorkoutNoise(startDate: self.workout.startDate, endDate: self.workout.endDate) { results, resultError in
                print("Statistics: \(String(describing: results))")
                if let results = results {
                    avg = results.averageQuantity()?.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()) ?? 0
                    min = results.minimumQuantity()?.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()) ?? 0
                    max = results.maximumQuantity()?.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()) ?? 0
                }
                let workoutDuration = self.workout.endDate.timeIntervalSince(self.workout.startDate)
                print("Workout Len: \(workoutDuration.description)")
                print("Noise duration from Statistics Query: \(results?.duration())")
                fetchGroup.leave()
            }
        }
        
        fetchGroup.enter()
        backgroundQueue.async(group: fetchGroup) {
            self.exposureHistogram(startDate: self.workout.startDate, endDate: self.workout.endDate) { results, resultError in
                histogram = results
                fetchGroup.leave()
            }
        }
        
        
        fetchGroup.notify(queue: backgroundQueue) {
            if let error = error {
                print("Error occurred: \(error)")
                return
            }
            
            for noiseIndex in 0..<(noiseMeasurements?.count ?? 0) {
                guard let oldMeas = noiseMeasurements else {
                    return
                }
                for locationIndex in 0..<(locations?.count ?? 0) {
                    guard let locations = locations else {
                        return
                    }
                    let noiseInterval = oldMeas[noiseIndex].interval
                    let locationTimestamp = locations[locationIndex].timestamp
                    
                    if (locationTimestamp >= noiseInterval.start) &&
                        (locationTimestamp <= noiseInterval.end) {
                        // perfect match
                        noiseMeasurements![noiseIndex].locations.append(locations[locationIndex])
                    }
                }
            }
            
            if locations == nil {
                print("Locations nil")
            }
            publishGroup.leave()
        }
        
        publishGroup.notify(queue: DispatchQueue.main) {
            self.path = locations
            self.noiseMeasurements = noiseMeasurements
            self.avg = avg
            self.min = min
            self.max = max
            
            self.done = true
            
            self.objectWillChange.send()
            self.changePublisher.send()
        }
    }
    
    func observeChanges() -> AnyPublisher<Void, Never> {
        changePublisher.eraseToAnyPublisher()
    }
    
    // fetch route for a given workout
    private func fetchLocations(completion: @escaping ([CLLocation]?, Error?) -> Void) {
        var allLocations = [CLLocation]()
        let workoutPredicate = HKQuery.predicateForObjects(from: self.workout)
        let workoutQuery = HKSampleQuery(sampleType: HKSeriesType.workoutRoute(), predicate: workoutPredicate, limit:
                                            HKObjectQueryNoLimit, sortDescriptors: nil) { query, routeSamples, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let routeSamples = routeSamples as? [HKWorkoutRoute] else {
                print("Workout has no route recording.")
                completion(nil, nil)
                return
            }
            if routeSamples.count == 0 {
                print("Workout has no route recording.")
                completion(nil, nil)
            }
            for route in routeSamples {
                // returns locations in batches; use allLocations and call completion handler once done
                let locationQuery = HKWorkoutRouteQuery(route: route) { (routeQuery, locations, done, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    guard let locations = locations else {
                        completion(nil, nil)
                        return
                    }
                    allLocations += locations
                    if done {
                        completion(allLocations, nil)
                    }
                }
                self.query.append(locationQuery)
                self.healthStore.execute(locationQuery)
            }
        }
        self.query.append(workoutQuery)
        healthStore.execute(workoutQuery)
    }
    
    private func fetchNoiseMeasurements(startDate: Date, endDate: Date, completion: @escaping ([NoiseMeasurement]?, Error?) -> Void) {
        var noiseSamples = [HKQuantity]()
        var intervals = [DateInterval]()
        
        let audioType = HKQuantityType(.environmentalAudioExposure)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        let query = HKQuantitySeriesSampleQuery(quantityType: audioType, predicate: predicate) { query, quantity, interval, quantitySamples, done, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let quantity = quantity else {
                completion(nil, nil)
                return
            }
            guard let interval = interval else {
                completion(nil, nil)
                return
            }
            noiseSamples.append(quantity)
            intervals.append(interval)
            if done {
                if (noiseSamples.count != intervals.count) {
                    print("Noise measurement sample count and timestamp count does not match.")
                    completion(nil, nil)
                }
                // combine samples and timestamps
                var measurements = [NoiseMeasurement]()
                for i in 0..<noiseSamples.count {
                    measurements.append(NoiseMeasurement(sample: noiseSamples[i], interval: intervals[i]))
                }
                let noiseMeasurements = measurements.sorted(by: { a, b in
                    a.interval.start < b.interval.start
                })
                completion(noiseMeasurements, nil)
            }
        }
        query.includeSample = true
        self.query.append(query)
        healthStore.execute(query)
    }
    
    private func fetchAvgWorkoutNoise(startDate: Date, endDate: Date, completion: @escaping (HKStatistics?, Error?) -> Void) {
        let audioType = HKQuantityType(.environmentalAudioExposure)
        print("Audio aggregation style: \(audioType.aggregationStyle)")
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let query = HKStatisticsQuery(quantityType: audioType, quantitySamplePredicate: predicate,
                                      options: [.discreteAverage, .discreteMax, .discreteMin , .duration] ) { query, statistics, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let statistics = statistics else {
                completion(nil, nil)
                return
            }
            print("Statistics: \(statistics)")
            completion(statistics, nil)
        }
        // TODO getting some segfaults here?
        self.query.append(query)
        healthStore.execute(query)
    }
    
    private func exposureHistogram(startDate: Date, endDate: Date, completion: @escaping ([HistogramBin]?, Error?) -> Void) {
        let audioType = HKQuantityType(.environmentalAudioExposure)
        
        let binSize = 1.0 // In dB
        let minDecibels = 0.0
        let maxDecibels = 120.0
        
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        var histogram = [HistogramBin]()
        let binCount = Int((maxDecibels - minDecibels) / binSize)
        
        let group = DispatchGroup()
        
        for bin in 0..<binCount {
            let lowerBound = HKQuantity(unit: HKUnit.decibelAWeightedSoundPressureLevel(), doubleValue: Double(bin) * binSize + minDecibels)
            let lowerBoundPredicate = HKQuery.predicateForQuantitySamples(with: .greaterThanOrEqualTo, quantity: lowerBound)
            let upperBound = HKQuantity(unit: HKUnit.decibelAWeightedSoundPressureLevel(), doubleValue: Double(bin + 1) * binSize + minDecibels)
            let upperBoundPredicate = HKQuery.predicateForQuantitySamples(with: .lessThanOrEqualTo, quantity: upperBound)
            
            let query = HKStatisticsQuery(quantityType: audioType,
                                          quantitySamplePredicate: NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, lowerBoundPredicate, upperBoundPredicate]),
                                          options: [.discreteMin, .discreteMax, .discreteAverage, .duration, .separateBySource]) { query, result, error in
                defer {
                    group.leave()
                }
                if let error = error {
                    histogram.append(HistogramBin(lowerBound: lowerBound, upperBound: lowerBound, duration: 0, averageNoise: 0))
                    return
                }
                guard let result = result else {
                    histogram.append(HistogramBin(lowerBound: lowerBound, upperBound: lowerBound, duration: 0, averageNoise: 0))
                    return
                }
                
                print("Bin \(bin) (\(lowerBound) - \(upperBound)): Min = \(String(describing: result.minimumQuantity()?.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()))), Max = \(String(describing: result.maximumQuantity()?.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()))) Avg = \(String(describing: result.averageQuantity()?.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()))), Duration: \(String(describing: result.duration()))")
                histogram.append(HistogramBin(lowerBound: lowerBound, upperBound: lowerBound,
                                              duration: result.duration()?.doubleValue(for: HKUnit.second()) ?? 0,
                                              averageNoise: result.averageQuantity()?.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()) ?? 0))
            }
            
            group.enter()
            self.query.append(query)
            healthStore.execute(query)
        }
        group.wait()
        let hist_sorted = histogram.sorted(by: { a, b in
            a.lowerBound.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()) < b.lowerBound.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel())
        })
        
        let workoutDuration = endDate.timeIntervalSince(startDate)
        print("Workout Len: \(workoutDuration.description)")
        var totalDuration: Double = 0
        for bin in 0..<binCount {
            totalDuration += hist_sorted[bin].duration
        }
        print("Noise Duration: \(totalDuration)")
        
        completion(hist_sorted, nil)
    }
    
    func stopQuery() {
        for query in self.query {
            healthStore.stop(query)
        }
    }
}

extension Workout {
    static func example() -> Workout {
        let workoutStartDate = Date()
        let workoutSplitDate = workoutStartDate.addingTimeInterval(60 * 30) // half hour later
        let workoutEndDate = workoutStartDate.addingTimeInterval(60 * 60) // one hour later
        let workoutDuration = workoutEndDate.timeIntervalSince(workoutStartDate)
        
        let energyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: 300)
        let distance = HKQuantity(unit: .mile(), doubleValue: 3.5)
        
        let exampleWorkout = HKWorkout(activityType: .running, start: workoutStartDate, end: workoutEndDate, duration: workoutDuration, totalEnergyBurned: energyBurned, totalDistance: distance, metadata: nil)
        
        let workout = Workout(workout: exampleWorkout)
        
        let location1 = CLLocation(latitude: 37.33233141, longitude: -122.0312186) // Apple Campus
        let location2 = CLLocation(latitude: 37.77492950, longitude: -122.4194155) // San Francisco
        let location3 = CLLocation(latitude: 36.002235, longitude: -120.243683)
        let location4 = CLLocation(latitude: 34.052235, longitude: -118.243683) // Los Angeles
        
        let decibelUnit = HKUnit(from: "dBASPL") // dBASPL is the unit for environmental noise level
        
        var decibelValue = 70.0
        var decibelQuantity = HKQuantity(unit: decibelUnit, doubleValue: decibelValue)
        
        let noise1 = NoiseMeasurement(sample: decibelQuantity, interval: DateInterval(start: workoutStartDate, end: workoutSplitDate), locations: [location1, location2])

        decibelValue = 90.0
        decibelQuantity = HKQuantity(unit: decibelUnit, doubleValue: decibelValue)
        
        let noise2 = NoiseMeasurement(sample: decibelQuantity, interval: DateInterval(start: workoutSplitDate, end: workoutEndDate), locations: [location3, location4])

        workout.path = [location1, location2, location3, location4]
                
        workout.noiseMeasurements = [noise1, noise2]
        return workout
    }
}
