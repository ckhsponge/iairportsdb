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
public class IADBRunway: IADBModel {
    
    @NSManaged var airportId: Int32
    @NSManaged public var closed: Bool
    @NSManaged public var lighted: Bool
    @NSManaged public var headingTrue: Float
    @NSManaged public var identifierA: String
    @NSManaged public var identifierB: String
    @NSManaged public var lengthFeet: Int16
    @NSManaged public var surface: String
    @NSManaged public var widthFeet: Int16
    
    public var airport:IADBAirport?
    
    static let HARD_SURFACES = ["ASP", "CON", "PEM"]
    
    // if headingDegrees is valid add the deviation, otherwise return -1
    // CoreLocation doesn't provide deviation :(
    // use identifier to guess heading if there is no true heading
    public func headingMagnetic(deviation: CLLocationDirection) -> CLLocationDirection {
        return self.headingTrue >= 0.0 ? IADBConstants.withinZeroTo360(Double(self.headingTrue) - deviation) : self.headingMagneticFromIdentifier()
    }
    
    public func headingMagneticFromIdentifier() -> CLLocationDirection {
        return IADBRunway.identifierDegrees(self.identifierA)
    }
    
    //guess the runway heading from the identifier e.g. 01R heads 10° and 04 or 4 heads 40°
    //returns -1 if guessing fails
    static func identifierDegrees(identifier:String) -> CLLocationDirection {
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        let unicodes = identifier.unicodeScalars
        if !unicodes.isEmpty && digits.longCharacterIsMember(unicodes[unicodes.startIndex].value) {
            if unicodes.count >= 2 && digits.longCharacterIsMember(unicodes[unicodes.startIndex.advancedBy(1)].value) {
                return CDouble(identifier.substringToIndex(identifier.startIndex.advancedBy(2)))! * 10.0
            }
            else {
                return CDouble(identifier.substringToIndex(identifier.startIndex.advancedBy(1)))! * 10.0
            }
        }
        return -1.0
    }
    
    public func isHard() -> Bool {
        let surface = self.surface.uppercaseString
        for match: String in IADBRunway.HARD_SURFACES {
            if surface.containsString(match) {
                return true
            }
        }
        return false
    }
    
    override public var description: String {
        return "\(self.identifierA)/\(self.identifierB) \(self.lengthFeet)\(self.widthFeet) \(self.surface) \(self.headingTrue)"
    }
    
    override public func setCsvValues( values: [String: String] ) {
        //"id","airport_ref","airport_ident","length_ft","width_ft","surface","lighted","closed","le_ident","le_latitude_deg","le_longitude_deg","le_elevation_ft","le_heading_degT","le_displaced_threshold_ft","he_ident","he_latitude_deg","he_longitude_deg","he_elevation_ft","he_heading_degT","he_displaced_threshold_ft",
        //print(values)
        
        self.airportId = Int32(values["airport_ref"]!)!
        self.closed = "1" == values["closed"]
        self.lighted = "1" == values["lighted"]
        self.headingTrue = Float(values["le_heading_degT"]!) ?? -1
        self.identifierA = values["le_ident"] ?? ""
        self.identifierB = values["he_ident"] ?? ""
        self.lengthFeet = Int16(values["length_ft"]!) ?? -1
        self.surface = values["surface"] ?? ""
        self.widthFeet = Int16(values["width_ft"]!) ?? -1
    }

}
