//
//  WorkoutListManager.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 23.05.23.
//

import Foundation
import HealthKit
import MapKit
import Combine

struct WorkoutListManagerStatus {
    var queryStatus: WorkoutOverviewQueryStatus
    var queryResult: WorkoutOverviewQueryResult
}

enum WorkoutOverviewQueryStatus {
    case workoutQueryPending
    case workoutQueryCompleted
}

enum WorkoutOverviewQueryResult {
    case noWorkoutsFound
    case done
}

class WorkoutList: ObservableObject, Sequence {
    @Published var workouts: [Workout]
    
    var count: Int {
        return workouts.count
    }
    
    private var cancellables: [AnyCancellable] = []
    
    init() {
        self.workouts = [Workout]()
    }
    
    init(workouts: [HKWorkout]) {
        self.workouts = [Workout]()
        self.add(newWorkouts: workouts)
    }
    
    init(workouts: [Workout]) {
        self.workouts = [Workout]()
        self.add(newWorkouts: workouts)
    }
    
    func makeIterator() -> IndexingIterator<[Workout]> {
        return workouts.makeIterator()
    }
    
    func forEach(_ body: (Workout) throws -> Void) rethrows {
        try workouts.forEach(body)
    }

    
    func add(newWorkouts: [Workout]) {
        for newWorkout in newWorkouts {
            if self.workouts.contains(newWorkout) {
                continue
            }
            
            DispatchQueue.main.async {
                self.workouts.append(newWorkout)
                let cancellable = NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: newWorkout)
                    .sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }
                
                newWorkout.observeChanges()
                    .sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }
                    .store(in: &self.cancellables)
                self.cancellables.append(cancellable)
            }
        }
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func add(newWorkouts: [HKWorkout]) {
        var w = [Workout]()
        for workoutHK in newWorkouts {
            let newWorkout = Workout(workout: workoutHK)
            w.append(newWorkout)
        }
        self.add(newWorkouts: w)
    }
}

class WorkoutListManager: ObservableObject {
    static let shared = WorkoutListManager()
    
    @Published var workoutList = WorkoutList()

    private let healthStore = HKHealthStore()
    private let workoutQueryFinished = false
    private var allWorkouts: [HKWorkout] = []
    
    init() {
        queryAllWorkouts() { workouts, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            guard let workouts = workouts else {
                print("Error! No workouts.")
                return
            }
            
            self.allWorkouts = workouts.sorted(by: { a, b in
                a.startDate < b.startDate
            })
            
            self.workoutList.add(newWorkouts: workouts)
        }
    }
    
    
    // get all relevant Workouts (running, cycling, walking) without any filtering
    // only includes HKWorkout, no path etc.
    private func queryAllWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        let runningPredicate = HKQuery.predicateForWorkouts(with: .running)
        let cyclingPredicate = HKQuery.predicateForWorkouts(with: .cycling)
        let walkingPredicate = HKQuery.predicateForWorkouts(with: .walking)
        let hikingPredicate = HKQuery.predicateForWorkouts(with: .hiking)
        let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [runningPredicate, cyclingPredicate, walkingPredicate, hikingPredicate])
        
        let sortByDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleType = HKSampleType.workoutType()
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: combinedPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortByDate]) { (query, results, error) in
            if let error = error {
                completion(nil, error)
            }
            guard let results = results as? [HKWorkout] else {
                completion(nil, nil)
                return
            }
            completion(results, nil)
        }
        healthStore.execute(query)
    }
}

extension WorkoutList {
    static func example(count: Int = 1) -> WorkoutList {
        let workoutList = WorkoutList()
        if count < 1 {
            return workoutList
        }
        
        for _ in 1...count {
            workoutList.workouts.append(Workout.example())
        }
        
        workoutList.workouts = workoutList.workouts.sorted(by: { a, b in
            a.workout.startDate < b.workout.startDate
        })
        
        return workoutList
    }
}

extension WorkoutListManager {
    static func example() -> WorkoutListManager {
        WorkoutListManager.shared.workoutList.add(newWorkouts: [Workout.example()])
        return WorkoutListManager.shared
    }
}
