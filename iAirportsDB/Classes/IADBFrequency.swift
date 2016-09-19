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
open class IADBFrequency: IADBModel {
    @NSManaged var airportId: Int32
    @NSManaged open var mhz: Float
    @NSManaged open var name: String
    @NSManaged open var type: String
    
    override open func setCsvValues( _ values: [String: String] ) {
        //"id","airport_ref","airport_ident","type","description","frequency_mhz"
        //print(values)
        self.name = values["description"] ?? ""
        self.type = values["type"] ?? ""
        self.mhz = Float(values["frequency_mhz"]!)!
        self.airportId = Int32(values["airport_ref"]!)!
    }
}
