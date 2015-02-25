//
//  BusStopViewController.swift
//  BusStop
//
//  Created by Hans Scheurlen on 03.07.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class BusStopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate {
    @IBOutlet   var tableView: UITableView!
    @IBOutlet   var lblTime: UILabel!
    @IBOutlet   var lblNextLocation: UILabel!
    @IBOutlet   var lblCurrentLocation: UILabel!
    @IBOutlet   var segShifts: UISegmentedControl!

    var operationQueue:NSOperationQueue?
    var locationManager:CLLocationManager?
    var currentLocation:CLLocation?
    var lastLocationName = ""
    var currentStop:Stop?
    var schedule:Schedule?
    var clockFormatter:NSDateFormatter?
    var nextStopFormatter:NSDateFormatter?
    var items:Array<Stop>?
    
    var currentShift:Shift{
        get{
            return ScheduleManager.defaultInstance.currentSchedule().shifts[self.segShifts.selectedSegmentIndex] as Shift
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.schedule = ScheduleManager.defaultInstance.currentSchedule()
        
        self.clockFormatter = NSDateFormatter()
        self.clockFormatter!.dateFormat = "HH:mm:ss"
        
        self.nextStopFormatter = NSDateFormatter()
        self.nextStopFormatter!.dateFormat = "HH:mm"
        
        //Start timer trigger
        self.operationQueue = NSOperationQueue()
        
        //Register for events
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "onClockEvent", name: kClockEvent, object: nil)
        nc.addObserver(self, selector: "onPositionChangeEvent", name: kPositionChangeEvent, object: nil)
        
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        self.locationManager!.distanceFilter = kCLDistanceFilterNone
        self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        
        //Only for iOS 8
        if self.locationManager!.respondsToSelector("requestWhenInUseAuthorization"){
            self.locationManager!.requestWhenInUseAuthorization()
            self.locationManager!.requestAlwaysAuthorization()
        }
        
        //Start operations in background
        self.startBackGroundOperations()
        
        //Load items
        self.onShiftChange()
    }
    
    private func  startBackGroundOperations(){
        //Add background operations
        self.operationQueue!.addOperation( Clock(delay:1.0, message: kClockEvent))
        self.operationQueue!.addOperation( Clock(delay:5.0, message: kPositionChangeEvent))
        
        //Start location tracking
        self.locationManager!.startUpdatingLocation()
    }

    private func stopBackgroundOperations(){
        //Stop background operations
        self.operationQueue!.cancelAllOperations()
        
        //Stop location tracking
        self.locationManager!.stopUpdatingLocation()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Callback functions
    @IBAction func doGoBack() {
        
        //Stop operations in background
        self.stopBackgroundOperations()
        
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    //NSNotification messages
    func onClockEvent(){
        let timeString = self.clockFormatter!.stringFromDate(ScheduleManager.defaultInstance.currentSchedule().shiftedTime())

        dispatch_async(dispatch_get_main_queue(), {
            self.lblTime.text = timeString
        })
    }
    
    func onPositionChangeEvent(){
        let schedule = ScheduleManager.defaultInstance.currentSchedule()
        let shift = schedule.shifts[self.segShifts.selectedSegmentIndex]
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
            self.lblCurrentLocation.text = actualName
            let nextTimeAsString = nextTime != nil ? self.nextStopFormatter!.stringFromDate(nextTime!) : ""
            self.lblNextLocation.text = nextLocationName + "\n" + nextTimeAsString
            
            self.onShiftChange()
            
            //Preparing for audio playing
            if nextLocationName != self.lastLocationName{
                if let location = nextLocation{
                    location.speak()
                    
                    self.lastLocationName = nextLocationName
                }
            }
        })
    }
    

    @IBAction func onShiftChange(){
        self.items = self.currentShift.remainingStops(ScheduleManager.defaultInstance.currentSchedule().shiftedTime())
        
        self.tableView.reloadData()
    }
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int = 0
        
        count = self.items!.count
        
        return count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("StopCell") as UITableViewCell
        let schedule = ScheduleManager.defaultInstance.currentSchedule()
        
        let stop = self.items![indexPath.row]
        cell.textLabel!.textColor = stop.isPassed ? UIColor.redColor() : UIColor.greenColor()
        cell.textLabel!.text = stop.location.name
        cell.detailTextLabel!.text = self.clockFormatter!.stringFromDate(stop.time)
        
        return cell
    }
    

    //UITableViewDataDelegate
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        self.currentStop = self.items![indexPath.row]
        
        UIAlertView(title: "Achtung", message: "Willst Du den aktuellen Ort ändern?" , delegate: self, cancelButtonTitle: "Abbruch", otherButtonTitles: "Ändern" ).show()
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc:TicketViewController = storyBoard.instantiateViewControllerWithIdentifier("TicketViewController") as TicketViewController

        vc.stop = self.items![indexPath.row]
        
        self.navigationController!.pushViewController( vc, animated: true)
        //self.presentViewController(vc, animated: true, {})
    }
    
    //CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!){
        self.currentLocation = newLocation
    }

    //UIAlertViewDelegate
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        //Change actual stop
        if buttonIndex == 1 {
            let stop = self.currentStop!
            let shift = self.currentShift
            
            //Adjust delay for current shift
            shift.takeDelayFromStop(stop)
            
            self.onShiftChange()
        }
    }
}