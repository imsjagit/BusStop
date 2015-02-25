//
//  Schedule.swift
//  BusStop
//
//  Created by Hans Scheurlen on 04.07.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit

class Schedule: NSObject {
    var line:String?
    var locations:Array<Location>
    var shifts:Array<Shift>

    override init(){
        self.locations = Array<Location>()
        self.shifts = Array<Shift>()
        
        super.init()
        
    }

    //Creates singleton
    class var defaultInstance:Schedule {
        get {
            struct Static {
                static var instance : Schedule? = nil
                static var token : dispatch_once_t = 0
            }
            
            dispatch_once(&Static.token) {
                Static.instance = Schedule()
            }
            
            return Static.instance!
        }
    }
    
    var timeShift:Double {
        get{
           let userDefault = NSUserDefaults.standardUserDefaults()
            let result:Double? = userDefault.doubleForKey(kKeyTimeShift)

            return result != nil ? result! : 0.0
        }
        set(newValue){
            let userDefault = NSUserDefaults.standardUserDefaults()
            
            userDefault.setDouble(newValue, forKey: kKeyTimeShift)
            
            userDefault.synchronize()
        }
    }
    
    func loadFromDataDictionary(dictionary: NSDictionary){
        //Reset the container objects
        self.locations = [Location]()//Array<Location>()
        self.shifts = [Shift]()//Array<Shift>()
        
        self.line = dictionary["line"] as String
        
        var tmp = dictionary["locations"] as [NSDictionary]
        
        //Calculate components of current day
        let options:NSCalendarUnit = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit

        var calendar =  NSCalendar.currentCalendar();
        calendar.timeZone = NSTimeZone.localTimeZone()
        let dateComponents:NSDateComponents = calendar.components( options, fromDate:  self.shiftedTime())
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        
        //Get the locations
        for dict:NSDictionary in tmp{
            let name = dict["name"] as String
            let lng = dict["lng"] as Double
            let lat = dict["lat"] as Double
            let id = dict["id"] as Int
            
            let location = Location(id: id, name:name, lng:lng, lat:lat)
            
            self.locations.append(location)
        }

        tmp = dictionary["shifts"] as [NSDictionary]

        for dict:NSDictionary in tmp{
            let name = dict["name"] as String
            
            let shift = Shift(name:name)
            self.shifts.append( shift)
            
            //Assign the stops
            let stops = dict["stops"] as [NSDictionary]
            
            for stopDict in stops{
                let locationid = stopDict["locationid"] as Int
                
                //Find location for id
                var foundLocation:Location?

                for location in self.locations{
                    if (location.id == locationid) {
                        foundLocation = location
                        break
                    }
                }
                
                if foundLocation != nil {
                    let date = self.shiftedTime()
                    let timeString:String = stopDict["at"] as String
                    
                    let timeToken = timeString.componentsSeparatedByString(":") as [String]
                    
                    if timeToken.count == 2{
                        let hour = timeToken[0].toInt()
                        let minute = timeToken[1].toInt()
                        
                        dateComponents.hour = hour!
                        dateComponents.minute = minute!
                        
                        let stopDate = calendar.dateFromComponents( dateComponents)
                        
                        //println("Date: \(dateFormatter.stringFromDate(stopDate))")
                        
                        let stop = Stop(location: foundLocation!, at: stopDate!)
                        shift.addStop( stop )
                    }
                }
            }
        }
        //println("Locations \(self.locations.count) Shifts: \(self.shifts.count) TimeZone: \(NSTimeZone.localTimeZone())")
    }
    
    func actualShiftForDate(date: NSDate) -> Shift?{
        var result:Shift?
        
        for shift in self.shifts{
            if shift.fitsIntoDate(date){
                result = shift
                break
            }
        }
            
        return result
    }
    
    func shiftedTime() -> NSDate{
        var result = NSDate(timeIntervalSince1970: (NSDate().timeIntervalSince1970 - self.timeShift))
        
        return result
    }
    
    func stopsByShiftForLocation(location: Location) -> Dictionary<String, Array<Stop>>{
        var result = Dictionary<String, Array<Stop>>()
        
        for shift in self.shifts{
            var stopArray = Array<Stop>()

            for stop in shift.stops{
                let stopLocation = stop.location
                if stopLocation.name == location.name{
                    stopArray.append(stop)
                }
            }
            result[shift.name] = stopArray            
        }
        
        return result
    }
}
