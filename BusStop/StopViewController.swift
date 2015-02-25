//
//  StopViewController.swift
//  BusStop
//
//  Created by Hans Scheurlen on 08.07.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit
import MapKit

class StopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet   var    tableView:UITableView?
    @IBOutlet   var     mapView:MKMapView?
    
    var location     : Location?
    var stopsByShift : Dictionary<String, Array<Stop>>?
    var formatter:NSDateFormatter?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.formatter = NSDateFormatter()
        self.formatter!.dateFormat = "HH:mm"
        
        //Set annonations
        var annotations = Array<LocationAnnotation>()
        
        self.title = self.location!.name
        
        
        //Define required region
        var topLeftCoord = CLLocationCoordinate2D(latitude: -90.0, longitude: 180.0)
        var bottomRightCoord = CLLocationCoordinate2D(latitude: 90.0, longitude: -180.0)
        
        let annotation = LocationAnnotation(location:self.location!)
        annotations.append(annotation)
        
        self.mapView!.addAnnotation(annotation)
        
        let coordinate = annotation.coordinate
        if(coordinate.longitude != 0 && coordinate.latitude != 0){
            
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, coordinate.longitude);
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, coordinate.latitude);
            
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, coordinate.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, coordinate.latitude);
        }
        
        var region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 200.0,  200.0)
        self.mapView!.setRegion(region,  animated:true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        var result = 1
        
        if let tmp = self.stopsByShift{
            result = tmp.count
        }
        return result
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String! {
        let keys = Array(self.stopsByShift!.keys)
        
        return keys[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let keys = Array(self.stopsByShift!.keys)
        let key = keys[section]
        let values = self.stopsByShift![key] as Array<Stop>!

        return values.count
    }

    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView!, forSection section: Int){
        let header = view as UITableViewHeaderFooterView
        
        header.contentView.backgroundColor = UIColor.whiteColor();
        header.textLabel.textColor = UIColor.blackColor()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StopCell")  as UITableViewCell
        let keys = Array(self.stopsByShift!.keys)
        let key = keys[indexPath.section]
        let values = self.stopsByShift![key] as Array<Stop>!
        let stop = values[indexPath.row] as Stop

        // Configure the cell...

        cell.textLabel!.text = self.formatter!.stringFromDate(stop.time)
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

}
