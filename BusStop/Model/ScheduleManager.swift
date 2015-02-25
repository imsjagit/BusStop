//
//  ScheduleManager.swift
//  BusStop
//
//  Created by Hans Scheurlen on 29.07.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit

class ScheduleManager: NSObject {
    var schedules:Dictionary<String,Schedule>
    var _currentSchedule:Schedule = Schedule()
    
    override init(){
        self.schedules = Dictionary<String,Schedule>()
        
        super.init()
        
    }
    
    //Creates singleton
    class var defaultInstance:ScheduleManager {
        get {
            struct Static {
                static var instance : ScheduleManager? = nil
                static var token : dispatch_once_t = 0
            }
            
            dispatch_once(&Static.token) {
                Static.instance = ScheduleManager()
            }
            
            return Static.instance!
        }
    }
    
    func loadSchedules() {
        //Load date from Bundle
        let path:String = NSBundle.mainBundle().pathForResource("Schedules", ofType: "json")!
        var error:NSError?
        
        //let data = NSData.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: &error)
        let data = NSData.dataWithContentsOfMappedFile(path) as NSData
        let jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as NSDictionary!
        
        if error == nil{
            var tmp = jsonDict["schedules"] as Array<Dictionary<String, String>>!
            
            for dict:Dictionary<String, String> in tmp{
                let name = dict["name"] as String!
                let file = dict["file"] as String!
                let schedulePath:String = NSBundle.mainBundle().pathForResource(file, ofType: "json")!
                //let scheduleData = NSData.dataWithContentsOfFile(schedulePath, options: .DataReadingMappedIfSafe, error: &error)
                let scheduleData = NSData.dataWithContentsOfMappedFile(schedulePath) as NSData
                
                if error == nil {
                    let scheduleDict = NSJSONSerialization.JSONObjectWithData(scheduleData, options: nil, error: &error) as NSDictionary
                    let schedule = Schedule()
                    
                    schedule.loadFromDataDictionary( scheduleDict )
                    
                    self.schedules[name] = schedule
                }
            }
        }
        self.setScheduleWithName("Burscheid")
    }
    
    func scheduleNames() -> Array<String>{
        var result = Array<String>()
        let keys = self.schedules.keys
        
        for key in keys{
            result.append( key )
        }
        
        return result
    }
    
    func scheduleWithName(name: String) -> Schedule{
        var result:Schedule?
        let keys = self.schedules.keys
        
        for key in keys{
            if key == name {
                result = self.schedules[key]
                break
            }
        }
        
        return result!
    }
    
    func setScheduleWithName(name: String) {
        let keys = self.schedules.keys
        
        for key in keys{
            if key == name {
                if let tmp:Schedule = self.schedules[key]{
                    self._currentSchedule = tmp
                    break
                }
            }
        }
    }
    
    func currentSchedule() -> Schedule{
        return self._currentSchedule
    }
    
}
