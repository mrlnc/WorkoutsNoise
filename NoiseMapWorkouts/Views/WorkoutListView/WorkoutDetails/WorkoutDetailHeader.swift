//
//  WorkoutDetailHeader.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 31.05.23.
//

import SwiftUI

struct WorkoutDetailHeader: View {
    @ObservedObject var workout: Workout
    
    var body: some View {
        HStack {
            WorkoutPictogram(workout: workout)
            Text("\(workout.workout.duration.durationWorkout())").frame(alignment: .trailing).font(.headline)
            Spacer()
            Text("\(workout.workout.startDate.formatted())").frame(alignment: .trailing).font(.headline)
        }
    }
}

struct WorkoutDetailHeader_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetailHeader(workout: Workout.example())
    }
}
