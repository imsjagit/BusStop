//
//  LocationTableViewController.swift
//  BusStop
//
//  Created by Hans Scheurlen on 05.07.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit

class LocationTableViewController: UITableViewController {
    override init(style: UITableViewStyle) {
        super.init(style: style)
        // Custom initialization
    }

    required init(coder: NSCoder){
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Haltestellen"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        var count:Int = 0
        let schedule = ScheduleManager.defaultInstance.currentSchedule()
        
        count = schedule.locations.count
        
        return count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
    //override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as UITableViewCell
        let schedule = ScheduleManager.defaultInstance.currentSchedule()
        
        let location = schedule.locations[indexPath.row]
        
        cell.textLabel!.text = location.name
        
        return cell
    }

    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue!.identifier == "StopSegue" {
            
            // Get destination view
            let row = self.tableView.indexPathForSelectedRow()!.row
            let location = ScheduleManager.defaultInstance.currentSchedule().locations[row]
            
            let viewController = segue!.destinationViewController as StopViewController
            
            viewController.stopsByShift = ScheduleManager.defaultInstance.currentSchedule().stopsByShiftForLocation(location)
            viewController.location = location
        }
    }

}
