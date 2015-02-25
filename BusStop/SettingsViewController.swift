//
//  SettingsViewController.swift
//  BusStop
//
//  Created by Hans Scheurlen on 08.07.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet   var lblTimeShift: UILabel!
    @IBOutlet   var stepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        self.lblTimeShift.text = "\(ScheduleManager.defaultInstance.currentSchedule().timeShift)"
        self.stepper.value = 0.0
        
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        let schedule = ScheduleManager.defaultInstance.currentSchedule()
        schedule.timeShift = schedule.timeShift + self.stepper.value
        
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTimeShift(id:AnyObject){
        self.lblTimeShift.text = "\(ScheduleManager.defaultInstance.currentSchedule().timeShift + self.stepper.value)"
    }
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
