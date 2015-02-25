//
//  HomeViewController.swift
//  BusStop
//
//  Created by Hans Scheurlen on 29.07.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doBurscheid(){
    }
    
    @IBAction func doWitzhelden(){
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue!.identifier == "openBurscheid" {
            ScheduleManager.defaultInstance.setScheduleWithName("Burscheid")
        }else{
            ScheduleManager.defaultInstance.setScheduleWithName("Witzhelden")
        }
        
    }

}
