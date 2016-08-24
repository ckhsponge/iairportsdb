//
//  IADBLocationElevation.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/23/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreLocation

class IADBLocationElevation: IADBLocation {
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var elevationFeet: NSNumber?
    
    //meters
    override func elevationForLocation() -> CLLocationDistance {
        if let feet = self.elevationFeet {
            return feet.doubleValue / IADBConstants.feetPerMeter
        }
        return super.elevationForLocation()
    }
}
