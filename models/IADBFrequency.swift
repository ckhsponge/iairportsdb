//
//  IADBFrequency.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/18/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreData

@objc(IADBFrequency)
class IADBFrequency: IADBModel {
    @NSManaged var airportId: Int32
    @NSManaged var mhz: Float
    @NSManaged var name: String
    @NSManaged var type: String
    
    override func setCsvValues( values: [String: String] ) {
        //"id","airport_ref","airport_ident","type","description","frequency_mhz"
        //print(values)
        self.name = values["description"] ?? ""
        self.type = values["type"] ?? ""
        self.mhz = Float(values["frequency_mhz"]!)!
        self.airportId = Int32(values["airport_ref"]!)!
    }
}
