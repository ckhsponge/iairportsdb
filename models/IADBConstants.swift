//
//  IADBConstants.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/23/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreLocation

struct IADBConstants {
    static let metersPerNM = (1852.0)
    static let metersPerKTS = (metersPerNM / 3600.0)
    static func nm(x:Double) -> Double {
        return round(x/metersPerNM)
    }
    static let nmPerLatitude = (60.0)
    static func latitudeDegreesFromNM(nm: Double) -> Double {
        return nm/nmPerLatitude
    }
    static func longitudeDegreesFromNM(nm: Double, latitude: Double) -> Double {
        return nm/(nmPerLatitude*cos(latitude*M_PI/180.0))
    }
    static let feetPerMeter = (3.28084)
    
    static func withinZeroTo360(degrees: Double) -> Double {
        return (degrees - (360.0 * floor(degrees / 360.0)))
    }
    
    static func within180To180 (degrees: Double) -> Double {
        let d = withinZeroTo360(degrees)
        return d > 180.0 ? d - 360.0 : d
    }

}