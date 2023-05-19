//
//  ManyMapTab.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 01.06.23.
//

import SwiftUI

struct ManyMapTab: View {
    @StateObject var settings = Settings.shared
    @StateObject var hkmanager = HKManager.shared
    @StateObject var listManager = WorkoutListManager.shared
    @StateObject var model = ManyMapModel()
    
    @ObservedObject var workoutList = WorkoutListManager.shared.workoutList
    
    @State var queryStarted = false
    @State var helpShowing = false
    @State var showingExporter = false
    @State var showExportWarning = false
    
    var csvFilename: String {
        return "export_\(Date.now.formatted(date: .long, time: .shortened)).csv"
    }
    
    var numDone: Double {
        return Double(model.totalDoneWorkouts)
    }
    
    var numTotal: Double {
        return Double(model.totalSelectedWorkouts)
    }
    
    var body: some View {
        let showMap = Binding(get: {return queryStarted && model.allDone}, set: { val in
            DispatchQueue.main.async {
                queryStarted = false
            }
        })
        VStack {
                ZStack (alignment: .bottomTrailing) {
                    ZStack (alignment: .topTrailing, content: {
                        ManyMapView(workouts: model.filteredList, mapFinishedLoading: .constant(true), mapFinishedRendering: .constant(true)).ignoresSafeArea(.all)
                        LegendView(alignment: .vertical).padding()
                    })
                    
                    if (model.allDone) {
                            Button(action: {
                                if settings.showExportWarning {
                                    showExportWarning = true
                                    settings.showExportWarning = false
                                } else {
                                    self.showingExporter = true
                                }
                            }, label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("save_to_csv".localized())
                                }
                            }).padding()
                                .buttonStyle(.borderedProminent)
                                .fileExporter(isPresented: $showingExporter, document: model.toCsv(), contentType: .plainText, defaultFilename: csvFilename) { result in
                                    switch result {
                                    case .success(let url):
                                        print("Saved to \(url)")
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                }
                                .popover(isPresented: $showExportWarning, content: {
                                    Text("export_warning".localized())
                                })
                        }
                        
                }.blur(radius: model.mapBlur)
                    .overlay(content: {
                        VStack {
                            if (!queryStarted && !model.allDone) {
                                Button(action: {
                                    model.startQuery()
                                    queryStarted = true
                                }, label: {
                                    Text("Update")
                                }).buttonStyle(.borderedProminent)
                                    .padding()
                                    .disabled(model.filteredList.isEmpty)
                            }
                            
                            if (queryStarted && !model.allDone) {
                                ProgressView(value: numDone, total: numTotal,
                                             label: { Text("Loading Workouts…")},
                                             currentValueLabel: { Text("\(model.totalDoneWorkouts)/\(model.totalSelectedWorkouts) Workouts loaded") }).progressViewStyle(.circular).padding()
                                
                                Button(role: .cancel, action: {
                                    model.stopQuery()
                                    queryStarted = false
                                }, label: {
                                    Text("Cancel")
                                }).disabled(!queryStarted)
                                    .buttonStyle(.borderedProminent)
                            }
                        }
                    })

            if helpShowing {
                Text("Select filter criteria and show all selected workouts on a map. The database query might run a while.")
            }
            FilterView(showLimit: true).padding(.vertical)
            
            //.navigationTitle("Bulk View")
            //.navigationBarTitleDisplayMode(.inline)
            // .toolbar {
            //    ToolbarItem(placement: .navigationBarTrailing, content: {
            //Button {
            //          helpShowing.toggle()
            //       } label: {
            //             ZStack(alignment: .topTrailing) {
            //               if helpShowing {
            //                    Image(systemName: "questionmark.app.fill").padding(10)
            //                  } else {
            //                     Image(systemName: "questionmark.app").padding(10)
            //                 }
            //              }
            //          }
            //          })
        }
    }
}

struct ManyMapTab_Previews: PreviewProvider {
    static var previews: some View {
        ManyMapTab()
    }
}
