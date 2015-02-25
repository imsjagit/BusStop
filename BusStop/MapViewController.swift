//
//  MapViewController.swift
//  BusStop
//
//  Created by Hans Scheurlen on 03.07.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView:MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set annonations
        let locations = ScheduleManager.defaultInstance.currentSchedule().locations
        var annotations = Array<LocationAnnotation>()
        
        //Define required region
        var topLeftCoord = CLLocationCoordinate2D(latitude: -90.0, longitude: 180.0)
        var bottomRightCoord = CLLocationCoordinate2D(latitude: 90.0, longitude: -180.0)
        
        for location in locations{
            let annotation = LocationAnnotation(location:location)
            annotations.append(annotation)
            
            self.mapView!.addAnnotation(annotation)
            
            let coordinate = annotation.coordinate
            if(coordinate.longitude != 0 && coordinate.latitude != 0){
                
                topLeftCoord.longitude = fmin(topLeftCoord.longitude, coordinate.longitude);
                topLeftCoord.latitude = fmax(topLeftCoord.latitude, coordinate.latitude);
                
                bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, coordinate.longitude);
                bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, coordinate.latitude);
            }
        }
        var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta:0.0, longitudeDelta:0.0))
        
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        if annotations.count <= 1{
            region.span.longitudeDelta = 0.01
            region.span.latitudeDelta = 0.01
        } else {
            var span = MKCoordinateSpan(latitudeDelta:fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.02, longitudeDelta:fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.02)
            
            region.span.latitudeDelta = span.latitudeDelta > 2.0 ? 2.0 : span.latitudeDelta // Add a little extra space on the sides
            region.span.longitudeDelta = span.longitudeDelta > 2.0 ? 2.0 : span.longitudeDelta // Add a little extra space on the sides
        }
        //region = [mapView regionThatFits:region];
        //HSLog(@"Center %f - %f : Span %f - %f", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta);
        
        self.mapView.setRegion(region,  animated:true)
}
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        self.mapView.setUserTrackingMode(.Follow, animated: true)
    }

    override func viewDidDisappear(animated: Bool) {
        self.mapView.setUserTrackingMode(.None, animated: true)
        
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

