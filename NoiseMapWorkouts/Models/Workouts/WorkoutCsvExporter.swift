//
//  WorkoutCsvExporter.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 27.05.23.
//

import Foundation
import HealthKit

extension Workout {
    func toCsv(includeHeader: Bool = true) -> CsvFile {
        // flattens all location arrays. FIXME: probably high overhead and big files
        var header: String = "id, sample_interval_start, sample_interval_end, sample_interval_duration_s, sample, lat, lon\n"
        var csv = CsvFile()

        if includeHeader {
            csv.text += header
        }
    
        guard let noiseMeasurements = self.noiseMeasurements else {
            return csv
        }
        
        for sample in noiseMeasurements {

            for location in sample.locations {
                let line = "\(sample.id), \(sample.interval.start), \(sample.interval.end), \(sample.interval.duration), \(sample.sample.to_dba_spl()), \(location.coordinate.latitude), \(location.coordinate.longitude)\n"
                csv.text += line
                }
        }
        
        return csv
    }
}
