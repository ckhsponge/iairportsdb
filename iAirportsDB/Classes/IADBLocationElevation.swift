//
//  IADBLocationElevation.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/23/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreLocation

open class IADBLocationElevation: IADBLocation {
    @NSManaged open var name: String
    @NSManaged open var type: String
    @NSManaged open var elevationFeet: NSNumber? // for objc compatibility Int32? is not allowed, -1 is a valid elevation
    
    //meters
    override func elevationForLocation() -> CLLocationDistance {
        if let feet = self.elevationFeet {
            return feet.doubleValue / IADBConstants.feetPerMeter
        }
        return super.elevationForLocation()
    }
}
