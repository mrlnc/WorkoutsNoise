//
//  WorkoutDetailView.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 24.05.23.
//

import SwiftUI
import UniformTypeIdentifiers

struct CsvFile: FileDocument {
    // tell the system we support only plain text
    static var readableContentTypes = [UTType.plainText]
    
    // by default our document is empty
    var text = ""
    
    // a simple initializer that creates new, empty documents
    init(initialText: String = "") {
        text = initialText
    }
    
    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }
    
    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}

struct WorkoutDetailView: View {
    @ObservedObject var workout: Workout
    @StateObject var settings = Settings.shared
    @State private var showingExporter = false
    @State private var showExportWarning = false
    @State private var showingMap = false
    @State private var selection = 0
        
    var csvFile: CsvFile = CsvFile()
    var csvFilename: String {
        return "export_workout_\(workout.workout.startDate.formatted())"
    }
    var body: some View {
        VStack(alignment: .center) {
            WorkoutDetailHeader(workout: workout).padding(.horizontal)
            
            ZStack (alignment: .topLeading) {
                    MapWithLegendView(workout: workout, mapDisabled: true)
                Button(action: {
                    showingMap = true
                }, label: {
                    Image(systemName: "arrow.up.backward.and.arrow.down.forward.circle")
                }).buttonStyle(.bordered).padding()
            }
                .padding()
                .sheet(isPresented: $showingMap) {
                    VStack {
                        
                        Divider().frame(width:50).padding(.top)
                        
                        ZStack(alignment: .topLeading) {
                            MapWithLegendView(workout: workout, mapDisabled: false)
                            Button(action: {
                                showingMap = false
                            }, label: {
                                Image(systemName: "arrow.down.forward.and.arrow.up.backward.circle")
                            }).buttonStyle(.bordered).padding()
                        }
                    }
                }
            HStack {
                Text("Max.")
                Text("\(workout.max, specifier: "%.0f") dB")
                Spacer()
                Text("Min.")
                Text("\(workout.min, specifier: "%.0f") dB")
                Spacer()
                Text("Avg.")
                Text("\(workout.avg, specifier: "%.0f") dB")
            }.padding(.horizontal).padding(.bottom)
            // ExposureBarView(workout: workout)

            //  Section("exposure_time".localized()) {
            //      HStack {
            //                    VStack(alignment: .trailing) {
            //                        Text("< \(settings.upperLimitGreen) dB")
            //                        Text("\(settings.upperLimitGreen) - \(settings.upperLimitYellow)dB")
            //          Text("> \(settings.upperLimitYellow) dB")
            //      }.padding(.horizontal)
            //      VStack(alignment: .trailing) {
            //          Text("\(workout.levelExposure.yellow.durationExposure())")
            //          Text("\(workout.levelExposure.green.durationExposure())")
            //          Text("\(workout.levelExposure.red.durationExposure())")
            //      }.padding(.horizontal)
            //  }
            //}


            //TabView(selection: $selection) {
                VStack {
                    Text("Histogram (Total Exposure)").font(.headline).padding([.leading])
                    HistogramView(workout: workout).padding([.bottom, .leading, .trailing])
                }.tag(0)
                
                VStack {
                    Text("Noise over Time").font(.headline).padding([.leading])
                    TimePlotView(workout: workout).padding([.bottom, .leading, .trailing])
                }.tag(1)
            //}
            //.tabViewStyle(.page(indexDisplayMode: .always))
            //.indexViewStyle(.page(backgroundDisplayMode: .always))
            
            Button(action: {
                if (settings.showExportWarning) {
                    settings.showExportWarning = false
                    showExportWarning = true
                } else {
                    self.showingExporter = true
                }
            }, label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("save_to_csv".localized())
                }
            }).padding(.bottom)
            .buttonStyle(.borderedProminent)
            .fileExporter(isPresented: $showingExporter, document: workout.toCsv(), contentType: .plainText, defaultFilename: csvFilename) { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {

            }
        }
    }
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutDetailView(workout: Workout.example())
        }
    }
}
