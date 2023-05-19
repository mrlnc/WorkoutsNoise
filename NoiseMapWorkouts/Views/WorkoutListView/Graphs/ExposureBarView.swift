//
//  ExposureBarView.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 26.05.23.
//

import SwiftUI
import Charts

struct PlotLevelExposure: Identifiable {
    let id = UUID()
    let color: Color
    let interval: TimeInterval
}

struct ExposureBarView: View {
    @ObservedObject var workout: Workout
    
    var noDataInterval: TimeInterval {
        return workout.workout.duration - workout.levelExposure.green
                                        - workout.levelExposure.yellow
                                        - workout.levelExposure.red
    }
    
    var plotData: [PlotLevelExposure] {
        return [
            PlotLevelExposure(color: Color.blue, interval: noDataInterval/60),
            PlotLevelExposure(color: Color.green, interval: workout.levelExposure.green/60),
            PlotLevelExposure(color: Color.yellow, interval: workout.levelExposure.yellow/60),
            PlotLevelExposure(color: Color.red, interval: workout.levelExposure.red/60)
        ]
    }
    
    var body: some View {
        Chart(plotData) { elem in
            BarMark(
                x: .value("", elem.interval)
            ).foregroundStyle(elem.color)
        }.labelsHidden().chartLegend(.hidden)
            .chartXScale(domain: [0, workout.workout.duration/60])
    }
}

struct ExposureBarView_Previews: PreviewProvider {
    static var previews: some View {
        ExposureBarView(workout: Workout.example())
    }
}
