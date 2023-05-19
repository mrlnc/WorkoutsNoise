//
//  Created by Merlin Chlosta on 17.03.23.
//

import SwiftUI

struct FilterView: View {
    @ObservedObject var settings = Settings.shared
    var showLimit = false
    
    var measurementsImpaired: Bool {
        return settings.cyclingEnabled || settings.runningEnabled
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Toggle(isOn: $settings.cyclingEnabled, label: {
                    Image(systemName: "figure.outdoor.cycle")
                }).fixedSize()
                Spacer()
                Toggle(isOn: $settings.runningEnabled, label: {
                    Image(systemName: "figure.run")
                }).fixedSize()
                Spacer()
                Toggle(isOn: $settings.walkingEnabled, label: {
                    Image(systemName: "figure.walk")
                }).fixedSize()
                Toggle(isOn: $settings.hikingEnabled, label: {
                    Image(systemName: "figure.hiking")
                }).fixedSize()
                Spacer()
            }.padding(.vertical)
            
            if ( !( settings.cyclingEnabled
                    || settings.runningEnabled
                    || settings.walkingEnabled
                    || settings.hikingEnabled)) {
                Text("select_one_category".localized())
            }
            
            if (measurementsImpaired) {
                HStack(alignment: .center) {
                    Image(systemName: "exclamationmark.triangle.fill").padding()
                    Spacer()
                    Text("measurements_impaired".localized()).padding(.bottom)
                }
            }
            
            if showLimit {
                VStack {
                    Stepper(value: $settings.displayLimit, in: 1...Constants.maximumDisplayLimit, step: 1, label: {
                        HStack {
                            Text("display_limit")
                            Text("\(settings.displayLimit)".localized())
                        }
                    })
                }.padding(.horizontal)
            }

            
            if (!settings.defaultSettingsSet()) {
                HStack(alignment: .center) {
                    Image(systemName: "exclamationmark.bubble.fill").foregroundColor(.accentColor)

                    Button(action: {
                        settings.setDefaults()
                    }, label: {
                        HStack {
                            Text("restore_default_settings".localized())
                            Image(systemName: "arrow.counterclockwise")
                        }
                    })
                }
            }
        }
    }
}

struct FilterLimitView: View {
    @ObservedObject var settings = Settings.shared

    var body: some View {
        VStack {
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section("Filter View EN") {
                FilterView()
            }
            Section("Filter View DE") {
                FilterView().environment(\.locale, .init(identifier: "de"))
            }
            Section("Filter View DE") {
                FilterView(showLimit: true).environment(\.locale, .init(identifier: "de"))
            }
        }
    }
}
