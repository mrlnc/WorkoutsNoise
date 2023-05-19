//
//  WorkoutPictogram.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 30.05.23.
//

import SwiftUI

struct WorkoutPictogram: View {
    var workout: Workout
    
    var body: some View {
        if workout.workout.workoutActivityType == .running {
            Image(systemName: "figure.run")
                .imageScale(.large)
                .foregroundColor(.accentColor).frame(alignment: .leading)
        }
        if workout.workout.workoutActivityType == .walking {
            Image(systemName: "figure.walk")
                .imageScale(.large)
                .foregroundColor(.accentColor).frame(alignment: .leading)
        }
        if workout.workout.workoutActivityType == .hiking {
            Image(systemName: "figure.hiking")
                .imageScale(.large)
                .foregroundColor(.accentColor).frame(alignment: .leading)
        }
        if workout.workout.workoutActivityType == .cycling {
            Image(systemName: "figure.outdoor.cycle")
                .imageScale(.large)
                .foregroundColor(.accentColor).frame(alignment: .leading)
        }    }
}

struct WorkoutPictogram_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutPictogram(workout: Workout.example())
    }
}
