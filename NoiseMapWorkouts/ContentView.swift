//
//  ContentView.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 19.05.23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var workoutListManager = WorkoutListManager.shared
    @StateObject var settings = Settings.shared
    @StateObject var hkmanager = HKManager.shared

    var body: some View {
        let showOnboarding = Binding(get: {return !settings.onboardingFinished}, set: { val in
            DispatchQueue.main.async {
                settings.onboardingFinished = !val
            }
        })
        
        TabView(selection: $settings.currentTab) {
            WorkoutListTab()
                .tabItem {
                    Label("Workouts", systemImage: "figure.run")
                }.tag(Tab.home)
            
            ManyMapTab()
                .tabItem {
                    Label("Map", systemImage: "map")
                }.tag(Tab.map)
            
            AboutTab()
                .tabItem {
                    Label("About", systemImage: "list.bullet.circle.fill")
                }.tag(Tab.about)
        }
        .fullScreenCover(isPresented: showOnboarding) {
            if (!settings.appLaunchedBefore || !settings.onboardingFinished) {
                OnboardingView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
