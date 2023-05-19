//
//  SettingsView.swift
//  NoiseMap: Workouts
//
//  Created by Merlin Chlosta on 19.05.23.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = Settings.shared

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
