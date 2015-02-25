//
//  Stop.swift
//  BusStop
//
//  Created by Hans Scheurlen on 04.07.14.
//  Copyright (c) 2014 Hans Scheurlen. All rights reserved.
//

import UIKit

class Stop: NSObject {
    let  location:Location
    let  time: NSDate
    var  isPassed:Bool
    
    init(location: Location, at: NSDate){
        self.location = location
        self.time = at
        self.isPassed = false
    }
}
