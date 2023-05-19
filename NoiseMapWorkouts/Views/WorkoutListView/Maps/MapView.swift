//
//  MapView.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 23.05.23.
//

import SwiftUI
import MapKit
import HealthKit

struct MapWithLegendView: View {
    @ObservedObject var workout: Workout
    var mapDisabled: Bool = true
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapView(workout: workout, mapFinishedLoading: .constant(true), mapFinishedRendering: .constant(true)).disabled(mapDisabled)
            LegendView(alignment: .vertical).font(.footnote).foregroundColor(.black).padding()
        }
    }
}
    
struct MapView: UIViewRepresentable {
    @ObservedObject var workout: Workout
    
    @State private var locationsCount = 0
    @State private var noiseCount = 0

    let padding: CGFloat = 8
    
    @Binding var mapFinishedLoading: Bool
    @Binding var mapFinishedRendering: Bool

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.layer.cornerRadius = 15
        mapView.layer.borderWidth = 5
        mapView.layer.borderColor = Color.clear.cgColor
        
        mapView.pointOfInterestFilter = MKPointOfInterestFilter.excludingAll
        mapView.mapType = .mutedStandard
        
        drawPath(mapView)
        
        mapView.layer.opacity = 0
        return mapView
    }
    
    func convertLocation(_ input: [CLLocation]) -> [CLLocationCoordinate2D] {
        var output = [CLLocationCoordinate2D]()
        for item in input {
            output.append(item.coordinate)
        }
        return output
    }
    
    func drawPath(_ uiView: MKMapView) {
        var polylines_green = [MKPolyline]()
        var polylines_yellow = [MKPolyline]()
        var polylines_red = [MKPolyline]()
        
        guard let locations = workout.path else {
            print("No locations found for workout")
            return
        }
        
        if locations.count < 1 {
            print("Empty path")
            return
        }
        
        // create one line for the whole path
        let polyline = BackgroundPathPolyline(coordinates: convertLocation(locations), count: locations.count)
        uiView.addOverlay(polyline)
        uiView.setVisibleMapRect(uiView.mapRectThatFits(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: padding, left: padding/2, bottom: padding, right: padding/2)), animated: false)
        
        guard let noiseMeasurements = workout.noiseMeasurements else {
            print("Warning: No NoiseMeasurements found for workout.")
            return
        }
        
        // create segments with noise measurements
        // each segment has the same noise value
        for noiseSample in noiseMeasurements {
            let polyline = ColorPolyline(coordinates: convertLocation(noiseSample.locations), count: noiseSample.locations.count)
            let noiseLevel = noiseSample.sample.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel())
            
            // TODO: wrap noise level in a class to provide mapping
            if noiseLevel <= 70 {
                polyline.color = UIColor(Color.green)
                polylines_green.append(polyline)
            } else if noiseLevel <= 85 {
                polyline.color = UIColor(Color.yellow)
                polylines_yellow.append(polyline)
            } else {
                polyline.color = UIColor(Color.red)
                polylines_red.append(polyline)
            }
        }
        
        let polyline_green = ColorMultiPolyline(polylines_green)
        polyline_green.color = UIColor(Color.green)
        uiView.addOverlay(polyline_green)
        
        let polyline_yellow = ColorMultiPolyline(polylines_yellow)
        polyline_yellow.color = UIColor(Color.yellow)
        uiView.addOverlay(polyline_yellow)
        
        let polyline_red = ColorMultiPolyline(polylines_red)
        polyline_red.color = UIColor(Color.red)
        uiView.addOverlay(polyline_red)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        guard let newLocationsCount = workout.path?.count else {
            return
        }
        guard let newNoiseCount = workout.noiseMeasurements?.count else {
            return
        }
        
        if locationsCount == newLocationsCount && noiseCount == newNoiseCount {
            // no new data; no need to refresh
            // return
        }
        
        uiView.removeOverlays(uiView.overlays)
        drawPath(uiView)

        DispatchQueue.main.async {
            locationsCount = newLocationsCount
            noiseCount = newNoiseCount
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class ColorMultiPolyline: MKMultiPolyline {
    var color: UIColor?
}

class ColorPolyline: MKPolyline {
    var color: UIColor?
}

class BackgroundPathPolyline: MKPolyline {
}

class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    
    init(_ parent: MapView) {
        self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? ColorMultiPolyline {
            let renderer = MKMultiPolylineRenderer(multiPolyline: routePolyline)
            renderer.strokeColor = routePolyline.color ?? UIColor.systemBlue
            renderer.lineWidth = 5
            renderer.lineCap = .round
            renderer.lineJoin = .round

            return renderer
        }
        
        if let routePolyline = overlay as? ColorPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = routePolyline.color ?? UIColor.systemBlue
            renderer.lineWidth = 5
            renderer.lineCap = .round
            renderer.lineJoin = .round

            return renderer
        }
        
        if let routePolyline = overlay as? BackgroundPathPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.black
            renderer.lineWidth = 2
            renderer.lineCap = .round
            renderer.lineJoin = .round

            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        UIView.animate(withDuration: 1) {
            mapView.layer.opacity = 1
        }
        
        parent.mapFinishedLoading = true
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        UIView.animate(withDuration: 1) {
            mapView.layer.opacity = 1
        }
        
        parent.mapFinishedRendering = fullyRendered
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapWithLegendView(workout: Workout.example(), mapDisabled: false)
    }
}
