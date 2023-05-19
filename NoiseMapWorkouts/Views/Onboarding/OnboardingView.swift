//
//  OnboardingView.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 19.05.23.
//

import SwiftUI
import HealthKit

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss

    @State var selection = 0

    let settings = Settings.shared
    let hkmanager = HKManager.shared
    let maxTabs = 3
    
    var body: some View {
        VStack {
            TabView(selection: $selection) {
                WelcomeView().tag(0)
                PermissionsView().tag(1)
            }
            .tabViewStyle(PageTabViewStyle())
            .padding(.vertical)
            
            Button(action: {
                if selection < 1 {
                    selection += 1
                } else {
                    HealthKit.shared.authorize() {_ in
                        // authorized
                        settings.onboardingFinished = true
                    }
                }
            }, label: {
                Text("continue".localized())
            })
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

func openAppSettings() {
    if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
        UIApplication.shared.open(appSettings)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
        OnboardingView().environment(\.locale, .init(identifier: "de"))
    }
}
