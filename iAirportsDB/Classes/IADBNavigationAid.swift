//
//  IADBNavigationAid.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/21/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreData

@objc(IADBNavigationAid)
public class IADBNavigationAid: IADBLocation {
    @NSManaged public var dmeKhz: Int32
    @NSManaged public var elevationFeet: NSNumber?
    @NSManaged public var khz: Int32
    @NSManaged public var name: String
    @NSManaged public var type: String
    
    public lazy var mhz:Double = {
        return Double(self.khz) / 1000.0
    }()

    override public func setCsvValues( values: [String: String] ) {
        //"id","filename","ident","name","type","frequency_khz","latitude_deg","longitude_deg","elevation_ft","iso_country","dme_frequency_khz","dme_channel","dme_latitude_deg","dme_longitude_deg","dme_elevation_ft","slaved_variation_deg","magnetic_variation_deg","usageType","power","associated_airport",
        //print(values)
        
        self.dmeKhz = Int32(values["dme_frequency_khz"]!) ?? -1
        let elevationString = values["elevation_ft"] ?? ""
        self.elevationFeet = elevationString.isEmpty ? nil : Int( elevationString )
        self.identifier = values["ident"] ?? ""
        self.khz = Int32(values["frequency_khz"]!) ?? -1
        self.latitude = Double(values["latitude_deg"]!)!
        self.longitude = Double(values["longitude_deg"]!)!
        self.name = values["name"] ?? ""
        self.type = values["type"] ?? ""
    }

}
