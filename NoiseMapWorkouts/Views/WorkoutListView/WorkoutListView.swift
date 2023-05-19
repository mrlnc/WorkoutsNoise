//
//  WorkoutListView.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 23.05.23.
//

import SwiftUI

struct WorkoutListView: View {
    @StateObject var settings = Settings.shared
    @StateObject var hkmanager = HKManager.shared
    @StateObject var listManager = WorkoutListManager.shared
    @ObservedObject var workoutList = WorkoutListManager.shared.workoutList
    
    var filteredList: [Workout] {
        return workoutList.filter {
            (settings.walkingEnabled && $0.workout.workoutActivityType == .walking) ||
            (settings.runningEnabled && $0.workout.workoutActivityType == .running) ||
            (settings.hikingEnabled && $0.workout.workoutActivityType == .hiking) ||
            (settings.cyclingEnabled && $0.workout.workoutActivityType == .cycling)
        }
    }

    var body: some View {
            VStack {
                if filteredList.count > 0 {
                    ScrollView(.vertical) {
                        LazyVStack {
                            ForEach(filteredList, id: \.self) { workout in
                                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                        VStack {
                                            WorkoutOverview(workout: workout).frame(height: 300)
                                        }.padding(Edge.Set.horizontal, 20)
                                            .frame(maxWidth: .infinity)
                                        
                                    }.font(.body).foregroundColor(.primary)
                                    .disabled(!workout.done)
                                
                                if filteredList.last != workout {
                                    Divider().padding()
                                }
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
        }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Count: \(WorkoutListManager.example().workoutList.count)")
            WorkoutListView()
        }
    }
}
