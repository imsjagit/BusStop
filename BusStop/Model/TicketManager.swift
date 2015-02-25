//
//  TicketManager.swift
//  BusStop
//
//  Created by Hans Scheurlen on 15.10.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit

class TicketEntry : NSObject{
    let single, abo, free, left:Int
    let locationName:String
    
    init(locationName:String, single: Int, abo: Int, free: Int, left: Int){
        self.locationName = locationName
        self.single = single
        self.abo = abo
        self.free = free
        self.left = left
        
        super.init()
    }
}

class TicketManager: NSObject {
    private var tickets: [TicketEntry]

    override init(){
        self.tickets = [TicketEntry]()
        
        super.init()
        
    }
    
    //Creates singleton
    class var defaultInstance:TicketManager {
        get {
            struct Static {
                static var instance : TicketManager? = nil
                static var token : dispatch_once_t = 0
            }
            
            dispatch_once(&Static.token) {
                Static.instance = TicketManager()
            }
            
            return Static.instance!
        }
    }
    
    func addTicketEntry(#locationName: String, single: Int, abo: Int, free: Int, left: Int){
        self.tickets.append(TicketEntry(locationName: locationName, single: single, abo:abo, free:free, left:left))
        
        //Upload to Parse
        var po = PFObject(className: "Stop")
        po.setObject(locationName, forKey: "stopname")
        po.setObject(single, forKey: "enteredSingle")
        po.setObject(abo, forKey: "enteredAbo")
        po.setObject(free, forKey: "enteredFree")
        po.setObject(left, forKey: "left")
        po.setObject(ScheduleManager.defaultInstance.currentSchedule().line!, forKey: "line")
        
        po.saveInBackgroundWithBlock(
            {(success: Bool!, error: NSError!) -> Void in
                if success == true {
                    println("Object created with id: \(po.objectId)")
                } else {
                    println("Error while inserting into Parse: \(error)")
                }
            }
        )
        
        println(locationName)
    }
    
}
