//
//  WorkoutListTab.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 24.05.23.
//

import SwiftUI

struct WorkoutListTab: View {
    @StateObject var settings = Settings.shared
    @State var filterShowing = false
    var isDefaultSettings: Bool {
        return settings.defaultSettingsSet()
    }
    
    var body: some View {
            NavigationView {
                VStack {
                    if filterShowing {
                        FilterView().padding()
                        Spacer()
                    }
                    
                    WorkoutListView()
                }
                .scrollIndicators(.never)
                .navigationTitle("scrollbar_title".localized())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        Button {
                            filterShowing.toggle()
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                if filterShowing {
                                    Image(systemName: "gearshape.fill").padding(10)
                                } else {
                                    Image(systemName: "gearshape").padding(10)
                                }
                                Image(systemName: "exclamationmark.bubble.fill").foregroundColor(.accentColor).imageScale(.small).opacity(isDefaultSettings ? 0 : 1)
                            }
                        }
                    })
                }
            }
    }
}

struct WorkoutListTab_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListTab()
    }
}
