//
//  ManyMapModel.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 02.06.23.
//

import Foundation

class ManyMapModel: ObservableObject {
    var settings = Settings.shared
    var workoutList = WorkoutListManager.shared.workoutList
    
    var filteredList: ArraySlice<Workout> {
        let activityFilter = workoutList.filter {
            (settings.walkingEnabled && $0.workout.workoutActivityType == .walking) ||
            (settings.runningEnabled && $0.workout.workoutActivityType == .running) ||
            (settings.hikingEnabled && $0.workout.workoutActivityType == .hiking) ||
            (settings.cyclingEnabled && $0.workout.workoutActivityType == .cycling)
        }
        
        return activityFilter.prefix(settings.displayLimit)
    }
    
    var allDone: Bool {
        for workout in filteredList {
            if !workout.done {
                return false
            }
        }
        return true
    }
    
    var mapBlur: CGFloat {
        if allDone && totalDoneWorkouts > 0 {
            return 0
        }
        return 7
    }
    
    var totalSelectedWorkouts: Int {
        return filteredList.count
    }
    
    var totalDoneWorkouts: Int {
        var count = 0
        for workout in filteredList {
            if workout.done {
                count += 1
            }
        }
        return count
    }
    
    func toCsv() -> CsvFile {
        var csvFile = CsvFile()
        
        for workout in filteredList {
            var csvWorkout = workout.toCsv(includeHeader: workout == filteredList.first)
            csvFile.text += csvWorkout.text
        }
        
        return csvFile
    }
    
    func startQuery() {
        for workout in filteredList {
            workout.fetchWorkoutDetails()
        }
    }
    
    func stopQuery() {
        for workout in filteredList {
            workout.stopQuery()
        }
        
        for workout in workoutList {
            if !filteredList.contains(workout) {
                workout.stopQuery()
            }
        }
    }
}
