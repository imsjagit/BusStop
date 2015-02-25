//
//  DutyManager.swift
//  BusStop
//
//  Created by Hans Scheurlen on 10.02.15.
//  Copyright (c) 2015 Hans Scheurlen. All rights reserved.
//

import UIKit
import Parse

class DutyManager: NSObject {
    //Creates singleton
    class var defaultInstance:DutyManager {
        get {
            struct Static {
                static var instance : DutyManager? = nil
                static var token : dispatch_once_t = 0
            }
            
            dispatch_once(&Static.token) {
                Static.instance = DutyManager()
            }
            
            return Static.instance!
        }
    }

    class func loadDataFromParse(){
        self.loadClassWithName("Driver", orderBy: "name")
        self.loadClassWithName("Schedule", orderBy: "date")
        
        //Notify GUI
        //NSNotificationCenter.defaultCenter().postNotificationName(kEventDataDownloadSuccess, object: nil)
    }
    
    private class func loadClassWithName(className : String, orderBy: String) -> [PFObject]{
        return self.loadClassWithName(className, orderBy: orderBy, limit: 100)
    }
    
    private class func loadClassWithName(className : String, orderBy: String?, limit: Int) -> [PFObject]{
        var result = [PFObject]()
        var error:NSError?
        var loopCount = 0
        var query = PFQuery(className: className)
        query.limit = limit
        
        if let ob = orderBy{
            query.orderByAscending( ob)
        }
        
        //Delete records from local datastore
        PFObject.unpinAllObjectsWithName(className)

        while(true){
            let records = query.findObjects( &error) as [PFObject]
            
            //Bring records to local datastore
            PFObject.pinAll(records, withName: className)
            
            result += records
            
            if records.count < limit || error != nil{
                if error != nil{
                    println("Parse download error for class \(className): \(error?.description)")
                }
                break
            }else{
                query.skip = ++loopCount * limit
            }
        }
        
        return result
    }
    
    ///////////////////////////////////////////
    // Date methods
    ///////////////////////////////////////////
    class func currentMonth() -> Int{
        var result = 0
        
        if let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar){
            var components = calendar.components(NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay, fromDate: NSDate())
            
            result = components.month
        }
        return result
    }
    
    class func weekDayForDuty(duty: PFObject) -> Int{
        var result = 0
        
        if let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar){
            let date = duty["date"] as NSDate
            var components = calendar.components(NSCalendarUnit.WeekdayCalendarUnit, fromDate: date)
            
            result = components.weekday - 2
        }
        return result
    }

    ///////////////////////////////////////////
    // Duty methods
    ///////////////////////////////////////////
    class func dutiesForMonth(month: Int, callback:(duties:[PFObject])->()){
        if let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar){
            var components = calendar.components(NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay, fromDate: NSDate())
            
            components.month = month + 1 % 12
            components.day = 1
            
            let startDate = calendar.dateFromComponents(components)
            
            components.month = month + 2 % 12
            components.day = 1
            
            let endDate = calendar.dateFromComponents(components)
            
            var query = PFQuery(className: "Schedule")
            query.fromLocalDatastore()
            query.whereKey("date", greaterThanOrEqualTo: startDate)
            query.whereKey("date", lessThan: endDate)
            query.addAscendingOrder("date")

            query.findObjectsInBackgroundWithBlock({(data:[AnyObject]!, error:NSError!) in
                if error != nil{
                    callback(duties: [PFObject]())
                }else{
                    callback(duties: data as [PFObject])
                }
            })
        }
    }
    
    class func driversForDuty(duty:PFObject) ->[PFObject]{
        var query = PFQuery(className: "Driver")
        query.fromLocalDatastore()
        
        let job1 = duty["job1"] as PFObject
        let driver1 = query.getObjectWithId(job1.objectId)
        let job2 = duty["job2"] as PFObject
        let driver2 = query.getObjectWithId(job2.objectId)
        
        return [driver1, driver2]
    }
    
    class func loadImageForParseObject(object: PFObject,callCack:(image:UIImage)->()){
        //Try to load from documents folder
        var documentsPath = AppDocumentsPath()
        var found = false
        var tmpImage:UIImage?
        
        documentsPath = documentsPath.stringByAppendingPathComponent("Images")
        
        //Test if path exists
        let fm = NSFileManager.defaultManager()
        if !fm.fileExistsAtPath( documentsPath ){
            var error:NSError?
            fm.createDirectoryAtPath(documentsPath, withIntermediateDirectories: true, attributes: nil, error: &error)
            
            if error != nil {
                println("Cannot create images path at: \(documentsPath)")
                return
            }
        }
        let imageFilePath = documentsPath.stringByAppendingPathComponent("\(object.objectId).jpg")
        if fm.fileExistsAtPath(imageFilePath){
            //Load image data from local folder
            tmpImage = UIImage(contentsOfFile: imageFilePath)
            found = true
        }else{
            //Load image data from local folder
            tmpImage = UIImage(named: "noimage.png")
            
            let data = UIImageJPEGRepresentation(tmpImage!, 1.0)
            data.writeToFile(imageFilePath, atomically: true)
        }
        callCack(image: tmpImage!)
        
        //Try to update from backend
        if found == false && nil != object.objectForKey("image"){
            var imageFile = object["image"] as PFFile
            imageFile.getDataInBackgroundWithBlock({(imageData:NSData!, error:NSError!) in
                if error == nil{
                    tmpImage = UIImage(data: imageData)
                    //Resize image
                    tmpImage = tmpImage!.squareToSize(CGSize(width: CGFloat(kImageWidth), height: CGFloat(kImageHeight)))
                    
                    callCack(image: tmpImage!)
                    
                    let data = UIImageJPEGRepresentation(tmpImage, 1.0)
                    data.writeToFile(imageFilePath, atomically: true)
                }
            })
        }
        
    }
    
}
