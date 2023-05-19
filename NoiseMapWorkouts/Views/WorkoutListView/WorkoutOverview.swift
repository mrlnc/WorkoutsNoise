//
//  WorkoutOverview.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 23.05.23.
//

import SwiftUI

struct WorkoutOverview: View {
    @ObservedObject var workout: Workout
    @State var mapFinishedLoading = false
    @State var mapFinishedRendering = false
    var mapBlur: CGFloat {
        if workout.done && workout.dataQuality == WorkoutDataQuality.OK && mapFinishedLoading && mapFinishedRendering {
            return 0
        }
        return 2
    }
    
    var body: some View {
            VStack {
                    HStack {
                        WorkoutPictogram(workout: workout)
                        Text("\(workout.workout.duration.durationWorkout())").frame(alignment: .trailing)
                        Spacer()
                        Text("\(workout.workout.startDate.formatted())")
                    }
                ZStack(alignment: .center) {
                    ZStack(alignment: .topTrailing) {
                        GeometryReader { geometry in
                            MapView(workout: workout, mapFinishedLoading: $mapFinishedLoading, mapFinishedRendering: $mapFinishedRendering)
                                .disabled(true)
                                .frame(width: geometry.size.width)
                                .onAppear {
                                    workout.fetchWorkoutDetails()
                                }
                                .onDisappear() {
                                    // cancel query when view is not visible in lazy scrollview
                                    workout.stopQuery()
                                }.blur(radius: mapBlur, opaque: false)
                        }
                        if workout.done && workout.dataQuality == WorkoutDataQuality.OK {
                            LegendView(alignment: .vertical).font(.footnote).padding()
                        }
                    }
                    // Map overlay for Progress / Errs
                    if !workout.done || !mapFinishedLoading || !mapFinishedRendering {
                        ProgressView()
                    } else if workout.dataQuality != WorkoutDataQuality.OK {
                        Text(workout.dataQuality.description).fontWeight(.bold)
                    }
                }.frame(maxWidth: .infinity, alignment: .center)
                
                HStack {
                    Text("Max. \(workout.max, specifier: "%.0f") dB")
                    Text("Avg. \(workout.avg, specifier: "%.0f") dB")
                    Text("Min. \(workout.min, specifier: "%.0f") dB")
                    
                }.font(.footnote).opacity(workout.done ? 1 : 0)

                

            }.frame(maxWidth: .infinity)
    }
}

extension TimeInterval {
    func durationWorkout() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: self) ?? "-"
    }
    
    func durationExposure() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: self) ?? "-"
    }
}

struct WorkoutOverview_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutOverview(workout: Workout.example())
    }
}
