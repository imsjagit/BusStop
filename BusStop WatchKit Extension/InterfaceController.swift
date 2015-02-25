//
//  InterfaceController.swift
//  BusStop WatchKit Extension
//
//  Created by Hans Scheurlen on 20.01.15.
//  Copyright (c) 2015 Hans Scheurlen. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

class InterfaceController: WKInterfaceController,CLLocationManagerDelegate {
    @IBOutlet weak var lblLocationName: WKInterfaceLabel?
    
    private var locationManager:CLLocationManager?
    private var currentLocation:CLLocation?
    private var lastLocationName = ""
    private var operationQueue:NSOperationQueue?

    ////////////////////////////////////////
    //System functions
    ////////////////////////////////////////
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        let sm = ScheduleManager.defaultInstance
        sm.loadSchedules()
        sm.setScheduleWithName("Burscheid")
        
        //Start timer trigger
        self.operationQueue = NSOperationQueue()
        
        //Register for events
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "onPositionChangeEvent", name: kPositionChangeEvent, object: nil)
        
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        self.locationManager!.distanceFilter = kCLDistanceFilterNone
        self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationManager!.requestWhenInUseAuthorization()
        self.locationManager!.requestAlwaysAuthorization()
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        self.startBackGroundOperations()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    ////////////////////////////////////////
    //Private functions
    ////////////////////////////////////////
    
    private func  startBackGroundOperations(){
        //Add background operations
        self.operationQueue!.addOperation( Clock(delay:5.0, message: kPositionChangeEvent))
        
        //Start location tracking
        self.locationManager!.startUpdatingLocation()
    }
    
    private func onShiftChange(){
        /*
        self.items = self.currentShift.remainingStops(ScheduleManager.defaultInstance.currentSchedule().shiftedTime())
        
        self.tableView.reloadData()
        */
    }
    
    ////////////////////////////////////////
    //NSNotification messages
    ////////////////////////////////////////

    func onPositionChangeEvent(){
        let schedule = ScheduleManager.defaultInstance.currentSchedule()
        let shift = schedule.shifts[0] //self.segShifts.selectedSegmentIndex]
        var actualName = "- - -"
        var nextLocationName = "- - -"
        var nextLocation:Location?
        var nextStop:Stop?
        var nextTime:NSDate?
        
        // the system has found the actual location
        if let current = self.currentLocation{
            let lat = self.currentLocation!.coordinate.latitude
            let lng = self.currentLocation!.coordinate.longitude
            
            let locations = shift.nextLocations(lng, lat: lat, date:ScheduleManager.defaultInstance.currentSchedule().shiftedTime())
            
            if let actual = locations.actual{
                actualName = actual.name
            }
            
            if let next = locations.next{
                nextStop = locations.next
                nextTime = nextStop!.time
                nextLocationName = next.location.name
                nextLocation = next.location
            }
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.lblLocationName!.setText(nextLocationName)
            
            //Preparing for audio playing
            if nextLocationName != self.lastLocationName{
                if let location = nextLocation{
                    location.speak()
                    
                    self.lastLocationName = nextLocationName
                }
            }
        })
    }
    
    ////////////////////////////////////////
    //CLLocationManagerDelegate
    ////////////////////////////////////////

    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!){
        self.currentLocation = newLocation
    }
    

}
