//
//  HistogramView.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 24.05.23.
//

import SwiftUI
import Charts
import HealthKit

struct noiseBin {
    let index: Int
    let range: ChartBinRange<Double>
    let intervalLength: TimeInterval // add this property to represent the accumulated interval length
    let style: SwiftUI.Color
}

struct HistogramView: View {
    @ObservedObject var workout: Workout
    @StateObject var settings = Settings.shared
    var binnedData: [noiseBin] {
        var allNoiseMeasurements = [NoiseMeasurement]()
        
        // flatten the data
        for workout in [workout] {
            guard let noiseMeasurements = workout.noiseMeasurements else { continue }
            
            for s in noiseMeasurements {
                allNoiseMeasurements.append(s)
            }
        }
        
        let bins = NumberBins(
            data: allNoiseMeasurements.map { $0.sample.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()) },
            desiredCount: 32
        )
        
        let groups = Dictionary(
            grouping: allNoiseMeasurements,
            by: { bins.index(for: $0.sample.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel())) }
        )
        
        let preparedData: [noiseBin] = groups.map { key, values in
            var style: SwiftUI.Color
            if bins[key].upperBound < Double(settings.upperLimitGreen) {
                style = .green
            } else if bins[key].upperBound < Double(settings.upperLimitYellow) {
                style = .yellow
            } else {
                style = .red
            }
            
            let intervalLength = values.reduce(0.0) { $0 + $1.interval.duration }
            
            // TODO: normalize by interval or locations count?
            // https://developer.apple.com/documentation/healthkit/hkquantityaggregationstyle/discreteequivalentcontinuouslevel
            // https://developer.apple.com/videos/play/wwdc2019/218/
            return noiseBin(
                index: key,
                range: bins[key],
                intervalLength: intervalLength / 60,
                style: style )
        }
        return preparedData
    }
    
    var body: some View {
        Chart(self.binnedData, id: \.index) { element in
            BarMark(
                x: .value(
                    "Noise [dBA SPL]",
                    element.range
                ),
                y: .value(
                    "Exposure [min]",
                    element.intervalLength
                )
            ).foregroundStyle(element.style)
        }
        .chartXScale(
            domain: [35,110]
        ).chartYScale(
            domain: .automatic(includesZero: false)
        )
        .chartXAxisLabel("noise_spl".localized(), alignment: .leading)
        .chartYAxisLabel("exposure_min".localized(), alignment: .trailing)
    }
}


struct HistogramView_Previews: PreviewProvider {
    static var previews: some View {
        HistogramView(workout: Workout.example())
    }
}

