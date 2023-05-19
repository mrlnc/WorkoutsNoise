//
//  PieChartView.swift
//  NoiseMapWorkouts
//
//  Created by Merlin Chlosta on 26.05.23.
//

import SwiftUI
import SwiftPieChart

struct ExposureTimeView: View {
    var body: some View {
        VStack {
            PieChartView(values: [1.1, 2.2], names: ["what", "ever"], formatter: { d in
                "\(d)" })
            }
    }
}

struct ExposureTimeView_Previews: PreviewProvider {
    static var previews: some View {
        ExposureTimeView()
    }
}
