//
//  LegendView.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 23.05.23.
//

import SwiftUI

enum LegendAlignment {
    case horizontal
    case vertical
}

struct LegendView: View {
    var alignment: LegendAlignment
    @StateObject var settings = Settings.shared
    
    var body: some View {
        let p = 7.0
        switch alignment {
        case .horizontal:
            HStack {
                ZStack {
                    Capsule().fill(Color.green)
                    Text("< \(settings.upperLimitGreen) dB").padding(p).foregroundColor(.black)
                }
                ZStack {
                    Capsule().fill(Color.yellow)
                    Text("\(settings.upperLimitGreen) - \(settings.upperLimitYellow) dB").padding(p).foregroundColor(.black)
                }
                ZStack {
                    Capsule().fill(Color.red)
                    Text("> \(settings.upperLimitYellow) dB").padding(p).foregroundColor(.black)
                }
            }.fixedSize(horizontal: true, vertical: true)
        case .vertical:
            VStack {
                ZStack(alignment: .trailing) {
                    Capsule().fill(Color.green)
                    Text("< \(settings.upperLimitGreen) dB").padding(p).foregroundColor(.black)
                }
                ZStack(alignment: .trailing)  {
                    Capsule().fill(Color.yellow)
                    Text("\(settings.upperLimitGreen) - \(settings.upperLimitYellow) dB").padding(p).foregroundColor(.black)
                }
                ZStack(alignment: .trailing)  {
                    Capsule().fill(Color.red)
                    Text("> \(settings.upperLimitYellow) dB").padding(p).foregroundColor(.black)
                }
            }.fixedSize(horizontal: true, vertical: true)
        }
    }
}

struct LegendView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section("Horizontal") {
                LegendView(alignment: .horizontal)
            }
            Section("Vertical") {
                LegendView(alignment: .vertical)
            }
        }
    }
}
