//
//  Location.swift
//  Location
//
//  Created by Hans Scheurlen on 04.07.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation

class Location: NSObject {
    let coordinate:CLLocation
    let name:String
    let id: Int
    var player:AVPlayer?
    
    init(id: Int, name:String, lng: Double, lat: Double){
        self.id = id
        self.name = name
        self.coordinate = CLLocation(latitude: lat, longitude: lng)
    }
    
    func speak(){
        /*
        let audioPath = NSBundle.mainBundle().pathForResource(self.name, ofType: "m4a")
        
        if let path = audioPath{
            let audioURL = NSURL.fileURLWithPath( path)
            
            self.player = AVPlayer(URL: audioURL)
            
            self.player!.play()
        }
        */
        self.name.speak()
    }
}
