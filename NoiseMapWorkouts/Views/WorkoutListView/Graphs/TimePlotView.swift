//
//  TimePlotView.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 24.05.23.
//

import SwiftUI
import Charts
import HealthKit

struct TimePlotView: View {
    @ObservedObject var workout: Workout
    @StateObject var settings = Settings.shared
    
    var body: some View {
        if let noiseMeasurements = workout.noiseMeasurements {
            Chart(noiseMeasurements) {
                RuleMark(y: .value("limit".localized(), 70)) .foregroundStyle(.orange)
                RuleMark(y: .value("limit".localized(), 85)) .foregroundStyle(.red)
                LineMark(
                    x: .value("time".localized(), $0.interval.start),
                    y: .value("dbA SPL", $0.sample.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()))
                )
                LineMark(
                    x: .value("time".localized(), $0.interval.end),
                    y: .value("dbA SPL", $0.sample.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()))
                )
            }.chartYScale(domain: [45, 110])
                .chartYAxis{
                    AxisMarks(values: [60, settings.upperLimitGreen,
                                       settings.upperLimitYellow, 90, 95]) {
                    }
            }
                .chartLegend(.visible)
                .chartYAxis(.visible)

        }
    }
}

struct TimePlotView_Previews: PreviewProvider {
    static var previews: some View {
        TimePlotView(workout: Workout.example())
    }
}
