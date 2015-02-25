//
//  Shift.swift
//  BusStop
//
//  Created by Hans Scheurlen on 04.07.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit
import CoreLocation

class Shift: NSObject {
    var  stops:Array<Stop>
    var  name:String
    var delay = 0.0
    
    init(name:String){
        self.stops = Array<Stop>()
        self.name = name
    }
    
    func addStop(stop: Stop){
        self.stops.append(stop)
    }
    
    func fitsIntoDate(date: NSDate)->Bool{
        var result:Bool = false
        
        if self.stops.count >= 2{
            let firstStop = self.stops[0]
            let lastStop = self.stops[self.stops.count - 1]
            
            let firstMilli = firstStop.time.timeIntervalSince1970
            let lastMilli = lastStop.time.timeIntervalSince1970
            let dateMilli = date.timeIntervalSince1970
            
            if firstMilli < dateMilli && lastMilli > dateMilli{
                result = true
            }
        }
        return result
    }
    
    func takeDelayFromStop( stop: Stop ){
        self.delay = NSDate().timeIntervalSince1970 - stop.time.timeIntervalSince1970
    }
    
    func nextLocations(lng:Double, lat:Double, date: NSDate) -> (actual: Location?, next: Stop?){
        var next: Stop?
        var nextStop:Stop?
        let dateMilli = date.timeIntervalSince1970  - self.delay
        var index = 0
        let limit = self.stops.count

        for stop in self.stops{
            let stopMilli = stop.time.timeIntervalSince1970
            let location = stop.location
            let stopCoordinate = location.coordinate

            /*
            if stopMilli >= dateMilli && index + 1 < limit{
                next = self.stops[index+1].location
                break
            }*/
            if stopMilli >= dateMilli{
                next = stop
                break
            }
            index++
        }
        return (self.actualLocation(lng, lat: lat), next)
    }

    func remainingStops(date: NSDate) -> Array<Stop>{
        var result = Array<Stop>()
        let dateMilli = date.timeIntervalSince1970 - self.delay
        
        for stop in self.stops{
            let stopMilli = stop.time.timeIntervalSince1970
            
            if stopMilli >= dateMilli{
                stop.isPassed = false
            }else{
                stop.isPassed = true
            }
            //Capture all stops not being older than 20 minutes after current time
            if stopMilli >= dateMilli - 1200 {
                result.append(stop)
            }
        }
        return result
    }
    

    
    func actualLocation(lng:Double, lat:Double) -> Location?{
        var result:Location?
        let limit:Double = 150.0
        let locations = ScheduleManager.defaultInstance.currentSchedule().locations

        for location in locations{
            let actualCoordinate = CLLocation(latitude:lat, longitude: lng)
            
            let distance = abs(location.coordinate.distanceFromLocation(actualCoordinate))
            
            if distance < limit{
                result = location
                break
            }
        }
        return result
    }
    
}
