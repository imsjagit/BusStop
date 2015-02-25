//
//  LocationAnnotation.swift
//  BusStop
//
//  Created by Hans Scheurlen on 05.07.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    let locationTitle:String
    var coordinate:CLLocationCoordinate2D
    
    init(location:Location){
        self.locationTitle = location.name
        self.coordinate = location.coordinate.coordinate
    }
    
    func title()->String{
        return self.locationTitle
    }

    func subtitle()->String{
        return ""
    }
    
}
