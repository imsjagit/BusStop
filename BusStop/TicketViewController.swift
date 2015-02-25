//
//  TicketViewController.swift
//  BusStop
//
//  Created by Hans Scheurlen on 15.10.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit

class TicketViewController: UIViewController {
    var stop:Stop?
    
    @IBOutlet   weak var stpSingle:UIStepper?
    @IBOutlet   weak var stpAbo:UIStepper?
    @IBOutlet   weak var stpFree:UIStepper?
    @IBOutlet   weak var stpLeft:UIStepper?
    
    @IBOutlet   weak var lblSingle:UILabel?
    @IBOutlet   weak var lblAbo:UILabel?
    @IBOutlet   weak var lblFree:UILabel?
    @IBOutlet   weak var lblLeft:UILabel?

    @IBAction func onSave(){
        let noOfSingle: Int = NSString(string:self.lblSingle!.text!).integerValue
        let noOfAbo: Int = NSString(string:self.lblAbo!.text!).integerValue
        let noOfFree: Int = NSString(string:self.lblFree!.text!).integerValue
        let noOfLeft: Int = NSString(string:self.lblLeft!.text!).integerValue

        TicketManager.defaultInstance.addTicketEntry(locationName: self.stop!.location.name, single: noOfSingle, abo: noOfAbo, free: noOfFree, left: noOfLeft)
        
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func onCancel(){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func onStepperChange(sender:AnyObject){
        let stepper = sender as UIStepper
        let valueAsText = "\(Int(stepper.value))"
        
        if stepper == self.stpSingle{ self.lblSingle!.text = valueAsText}
        if stepper == self.stpAbo{ self.lblAbo!.text = valueAsText}
        if stepper == self.stpFree{ self.lblFree!.text = valueAsText}
        if stepper == self.stpLeft{ self.lblLeft!.text = valueAsText}
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Add bar button
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "onSave")
        
        self.navigationItem.rightBarButtonItem = button
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
