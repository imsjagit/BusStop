//
//  Clock.swift
//  BusStop
//
//  Created by Hans Scheurlen on 04.07.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit
import Foundation

class Clock: NSOperation {
    let delay:Double
    let message: String
    
    init(delay:Double, message:String){
        self.delay = delay
        self.message = message
    }
    
    override func main(){
        let nc = NSNotificationCenter.defaultCenter()
        
        while(!self.cancelled){
        
            NSThread.sleepForTimeInterval(self.delay)

            nc.postNotificationName(message, object: nil)
        }
    }
}
