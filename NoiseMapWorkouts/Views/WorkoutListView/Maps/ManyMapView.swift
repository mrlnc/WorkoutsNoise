//
//  ManyMapView.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 01.06.23.
//

import SwiftUI
import MapKit
import HealthKit

struct ManyMapView: UIViewRepresentable {
    var workouts: ArraySlice<Workout>
    
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
        
        if workouts.isEmpty {
            return
        }
        
        for workout in workouts {
            guard let locations = workout.path else {
                print("No locations found for workout")
                continue
            }
            
            if locations.count < 1 {
                print("Empty path")
                continue
            }
            
            // create one line for the whole path
            let polyline = BackgroundPathPolyline(coordinates: convertLocation(locations), count: locations.count)
            uiView.addOverlay(polyline)
            uiView.setVisibleMapRect(uiView.mapRectThatFits(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: padding, left: padding/2, bottom: padding, right: padding/2)), animated: false)
            
            guard let noiseMeasurements = workout.noiseMeasurements else {
                print("Warning: No NoiseMeasurements found for workout.")
                continue
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
        uiView.removeOverlays(uiView.overlays)
        drawPath(uiView)
    }
    
    func makeCoordinator() -> ManyMapCoordinator {
        ManyMapCoordinator(self)
    }
}

class ManyMapCoordinator: NSObject, MKMapViewDelegate {
    var parent: ManyMapView
    
    init(_ parent: ManyMapView) {
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



struct ManyMapView_Previews: PreviewProvider {
    static var previews: some View {
        ManyMapView(workouts: [Workout.example()], mapFinishedLoading: .constant(true), mapFinishedRendering: .constant(true))
    }
}
