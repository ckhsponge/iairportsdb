//
//  IADBRunway.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/21/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

@objc(IADBRunway)
open class IADBRunway: IADBModel {
    
    @NSManaged var airportId: Int32
    @NSManaged open var closed: Bool
    @NSManaged open var lighted: Bool
    @NSManaged open var headingTrue: Float
    @NSManaged open var identifierA: String
    @NSManaged open var identifierB: String
    @NSManaged open var lengthFeet: Int32
    @NSManaged open var surface: String
    @NSManaged open var widthFeet: Int32
    
    open weak var airport:IADBAirport? // weak to prevent strong reference cycle
    
    static let HARD_SURFACES = ["ASP", "CON", "PEM"]
    
    // if headingDegrees is valid add the deviation, otherwise return -1
    // CoreLocation doesn't provide deviation :(
    // use identifier to guess heading if there is no true heading
    open func headingMagnetic(_ deviation: CLLocationDirection) -> CLLocationDirection {
        return self.headingTrue >= 0.0 ? IADBConstants.withinZeroTo360(Double(self.headingTrue) - deviation) : self.headingMagneticFromIdentifier()
    }
    
    open func headingMagneticFromIdentifier() -> CLLocationDirection {
        return IADBRunway.identifierDegrees(self.identifierA)
    }
    
    //guess the runway heading from the identifier e.g. 01R heads 10° and 04 or 4 heads 40°
    //returns -1 if guessing fails
    static func identifierDegrees(_ identifier:String) -> CLLocationDirection {
        let digits = CharacterSet.decimalDigits
        let unicodes = identifier.unicodeScalars
        if !unicodes.isEmpty && digits.contains(UnicodeScalar(unicodes[unicodes.startIndex].value)!) {
            if unicodes.count >= 2 && digits.contains(UnicodeScalar(unicodes[unicodes.index(unicodes.startIndex, offsetBy: 1)].value)!) {
                return CDouble(identifier.substring(to: identifier.characters.index(identifier.startIndex, offsetBy: 2)))! * 10.0
            }
            else {
                return CDouble(identifier.substring(to: identifier.characters.index(identifier.startIndex, offsetBy: 1)))! * 10.0
            }
        }
        return -1.0
    }
    
    open func isHard() -> Bool {
        let surface = self.surface.uppercased()
        for match: String in IADBRunway.HARD_SURFACES {
            if surface.contains(match) {
                return true
            }
        }
        return false
    }
    
    override open var description: String {
        return "\(self.identifierA)/\(self.identifierB) \(self.lengthFeet)\(self.widthFeet) \(self.surface) \(self.headingTrue)"
    }
    
    override open func setCsvValues( _ values: [String: String] ) {
        //"id","airport_ref","airport_ident","length_ft","width_ft","surface","lighted","closed","le_ident","le_latitude_deg","le_longitude_deg","le_elevation_ft","le_heading_degT","le_displaced_threshold_ft","he_ident","he_latitude_deg","he_longitude_deg","he_elevation_ft","he_heading_degT","he_displaced_threshold_ft",
        //print(values)
        
        self.airportId = Int32(values["airport_ref"]!)!
        self.closed = "1" == values["closed"]
        self.lighted = "1" == values["lighted"]
        self.headingTrue = Float(values["le_heading_degT"]!) ?? -1
        self.identifierA = values["le_ident"] ?? ""
        self.identifierB = values["he_ident"] ?? ""
        self.lengthFeet = Int32(values["length_ft"]!) ?? -1
        self.surface = values["surface"] ?? ""
        self.widthFeet = Int32(values["width_ft"]!) ?? -1
    }

}
