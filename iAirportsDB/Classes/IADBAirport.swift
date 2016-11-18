//
//  IADBAirport.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/21/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

/// Represents an airport, seaplane base, balloonport, or heliport
@objc(IADBAirport)
open class IADBAirport: IADBLocationElevation {
    //identifier: String (defined in IADBLocation) // identifier or gps code e.g. RKSI, use this for pilot navigation
    @NSManaged var airportId: Int32
    
    /// iata code e.g. ICN, this is what is printed on boarding passes
    @NSManaged open var code: String
    
    /// Normally the nearby city e.g. Seoul
    @NSManaged open var municipality: String
    
    /// Use in type finders
    public enum AirportType: String {
        case Large = "large_airport", Medium = "medium_airport", Small = "small_airport",
        Seaplane = "seaplane_base", Heliport = "heliport", Balloonport = "balloonport", Closed = "closed"
        
        static let all = [Large, Medium, Small, Seaplane, Heliport, Balloonport, Closed]
        
        public static func parse(strings:[String]) -> [AirportType] {
            return strings.flatMap { parse(string:$0) }
        }
        
        public static func parse(string:String) -> AirportType? {
            return all.filter { $0.rawValue == string }.first
        }
        
        public static func strings(types:[AirportType]) -> [String] {
            return types.map { $0.rawValue }
        }
    }
    
    /**
     Finds using the internal airportId
    */
    open class func find(airportId: Int32) -> IADBAirport? {
        let (request, context) = fetchRequestContext()
        // Set example predicate and sort orderings...
        let predicate = NSPredicate(format: "(airportId = %d)", airportId)
        request.predicate = predicate
        
        do {
            let array = try context.fetch(request)
            if array.isEmpty {
                return nil
            }
            if let airports = array as? [IADBAirport] {
                if airports.count > 1 {
                    print("WARNING: more than 1 \(self.description) found with id \(airportId)")
                }
                return airports[0]
            } else {
                print("Fetch contained an invalid type \(array)")
            }
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
        return nil
    }
    
    /** 
     returns locations that begin with identifier with K prepended or the leading K removed
     or that begin with code
     */
    open class func findAll(identifierOrCode identifier: String)-> IADBCenteredArrayAirports {
        let types:[String]? = nil
        return self.findAll(identifierOrCode: identifier, types: types)
    }
    open class func findAll(identifierOrCode identifier: String, types: [IADBAirport.AirportType]?) -> IADBCenteredArrayAirports {
        return self.findAll(identifierOrCode: identifier, types: typesStrings(types))
    }
    open class func findAll(identifierOrCode identifier: String, types: [String]?) -> IADBCenteredArrayAirports {
        return self.findAll(identifierOrCode:identifier, orMunicipality: nil, types: types)
    }
    
    open class func findAll(identifierOrCodeOrMunicipality identifier: String) -> IADBCenteredArrayAirports  {
        let types:[String]? = nil
        return self.findAll(identifierOrCodeOrMunicipality:identifier, types: types)
    }
    open class func findAll(identifierOrCodeOrMunicipality identifier: String, types: [IADBAirport.AirportType]?) -> IADBCenteredArrayAirports  {
        return self.findAll(identifierOrCodeOrMunicipality:identifier, types: typesStrings(types))
    }
    open class func findAll(identifierOrCodeOrMunicipality identifier: String, types: [String]?) -> IADBCenteredArrayAirports  {
        return self.findAll(identifierOrCode:identifier, orMunicipality: identifier, types: types)
    }
    
    open class func findAll(identifierOrCode identifier: String, orMunicipality municipality: String?, types: [String]?) -> IADBCenteredArrayAirports  {
        if identifier.isEmpty {
            return IADBCenteredArrayAirports()
        }
        var identifierB = ""
        if identifier.characters.count >= 2 && identifier.uppercased().hasPrefix("K") {
            //allow "KCVH" to find CVH
            identifierB = identifier.substring(from: identifier.characters.index(identifier.startIndex, offsetBy: 1))
            // strip off K at beginning
        }
        else {
            identifierB = "K\(identifier)"
            // add K to beginning
        }
        return self.findAll(identifiers:[identifier, identifierB], orCode: identifier, orMunicipality: municipality, types: types)
    }
    
    // similar to some code in IADBLocation finders
    open class func findAll(identifiers: [String], orCode code: String?, orMunicipality municipality: String?, types: [String]?) -> IADBCenteredArrayAirports  {
        var arguments = [String]()
        var predicates = [String]()
        for identifier: String in identifiers {
            self.beginsWith(column: "identifier", value: identifier, predicates: &predicates , arguments: &arguments)
        }
        self.beginsWith(column: "code", value: code, predicates: &predicates , arguments: &arguments)
        self.beginsWith(column: "municipality", value: municipality, predicates: &predicates, arguments: &arguments, upcase:false)
        if predicates.count == 0 {
            // no inputs results in no outputs
            return IADBCenteredArrayAirports()
        }
        var predicateString = predicates.joined(separator: " or ")
        predicateString = "(\(predicateString)) AND \(self.predicateTypes(types))"
        let predicate = NSPredicate(format: predicateString, argumentArray: arguments)
        return self.findAll(predicate:predicate)
    }
    
    open lazy var frequencies:[IADBFrequency] = {
        if let models = IADBFrequency.findAllByAirportId(self.airportId) as? [IADBFrequency] {
            return models
        } else {
            print("!!! Invalid frequency type for airport")
        }
        return []
    }()
    
    
    open lazy var runways:[IADBRunway] = {
        if let models = IADBRunway.findAllByAirportId(self.airportId) as? [IADBRunway] {
            for model in models {
                model.airport = self
            }
            return models
        } else {
            print("!!! Invalid runway type for airport")
        }
        return []
    }()
    
    open func hasRunways() -> Bool {
        return self.runways.count > 0
    }
    
    open func longestRunwayFeet() -> Int {
        var length:Int = -1
        for runway: IADBRunway in self.runways {
            if !runway.closed {
                length = max(length, Int(runway.lengthFeet))
            }
        }
        return length
    }
    
    open func longestRunway() -> IADBRunway? {
        var maxRunway: IADBRunway? = nil
        for runway: IADBRunway in self.runways {
            if let max = maxRunway {
                if (max.lengthFeet < runway.lengthFeet) || (max.lengthFeet == runway.lengthFeet && max.widthFeet < runway.widthFeet) {
                    if !runway.closed {
                        maxRunway = runway
                    }
                }
            } else {
                maxRunway = runway
            }
        }
        return maxRunway
    }
    
    open func hasHardRunway() -> Bool {
        for runway: IADBRunway in self.runways {
            if runway.isHard() && !runway.closed {
                return true
            }
        }
        return false
    }
    
    open func frequencyForName(_ name: String) -> IADBFrequency? {
        for f: IADBFrequency in self.frequencies {
            if name.isEqual(f.name) {
                return f
            }
        }
        return nil
    }
    
    open func klessIdentifier() -> String {
        if (self.identifier.substring(to: self.identifier.characters.index(self.identifier.startIndex, offsetBy: 1)).uppercased() == "K") {
            return self.identifier.substring(from: self.identifier.characters.index(self.identifier.startIndex, offsetBy: 1))
        }
        return self.identifier
    }
    
    open func title() -> String {
        return "\(self.identifier): \(self.name)"
    }
    
    override open var description: String {
        return "<\(self.identifier) (\(self.code)) \(self.name) \(self.latitude) \(self.longitude) \(self.elevationFeet) <\(self.type)>"
    }
    
    open func asDictionary() -> [AnyHashable: Any] {
        return ["identifier": self.identifier, "name": self.name, "type": self.type, "latitude": Int(self.latitude), "longitude": Int(self.latitude), "elevationFeet": self.elevationForLocation()]
    }
    
    /// sets data based on a hash that probably came from a CSV row
    override open func setCsvValues( _ values: [String: String] ) {
        //"id","ident","type","name","latitude_deg","longitude_deg","elevation_ft","continent","iso_country","iso_region","municipality","scheduled_service","gps_code","iata_code","local_code","home_link","wikipedia_link","keywords"
        //print(values)
        
        self.airportId = Int32(values["id"]!)!
        self.code = values["iata_code"] ?? ""
        self.identifier = (values["gps_code"] ?? "").isEmpty ? values["ident"] ?? "" : values["gps_code"] ?? ""
        self.latitude = Double(values["latitude_deg"]!)!
        self.longitude = Double(values["longitude_deg"]!)!
        self.municipality = values["municipality"] ?? ""
        self.name = values["name"] ?? ""
        self.type = values["type"] ?? ""
        self.elevationFeet = IADBModel.parseIntNumber(text:values["elevation_ft"])
    }
    
    //begin convenience functions for type casting
    open override class func findNear(_ location: CLLocation, withinNM distance: CLLocationDistance) -> IADBCenteredArrayAirports {
        return IADBCenteredArrayAirports(centeredArray: super.findNear(location, withinNM: distance))
    }
    /// this is for objc compatibility, use Strings instead of enum
    override open class func findNear(_ location: CLLocation, withinNM distance: CLLocationDistance, types: [String]?) -> IADBCenteredArrayAirports {
        return IADBCenteredArrayAirports(centeredArray: super.findNear(location, withinNM: distance, types: types))
    }
    open class func findNear(_ location: CLLocation, withinNM distance: CLLocationDistance, types: [IADBAirport.AirportType]?) -> IADBCenteredArrayAirports {
        return self.findNear(location, withinNM: distance, types: typesStrings(types))
    }
    open override class func find(identifier: String) -> IADBAirport? {
        let model = super.find(identifier:identifier)
        guard let typed = model as? IADBAirport else {
            print("Invalid type found \(model)")
            return nil
        }
        return typed
    }
    
    open class func typesStrings(_ types: [IADBAirport.AirportType]?) -> [String]? {
        if let types = types {
            return AirportType.strings(types: types)
        } else {
            return nil
        }
    }
    open override class func findAll(identifier: String) -> IADBCenteredArrayAirports {
        return IADBCenteredArrayAirports(centeredArray: super.findAll(identifier:identifier))
    }
    open class func findAll(identifier: String, types: [IADBAirport.AirportType]?) -> IADBCenteredArrayAirports {
        return self.findAll(identifier:identifier, types: typesStrings(types))
    }
    open override class func findAll(identifier: String, types: [String]?) -> IADBCenteredArrayAirports {
        return IADBCenteredArrayAirports(centeredArray: super.findAll(identifier:identifier, types: types))
    }
    open class func findAll(identifiers: [String], types: [IADBAirport.AirportType]?) -> IADBCenteredArrayAirports {
        return self.findAll(identifiers:identifiers, types: typesStrings(types))
    }
    open override class func findAll(identifiers: [String], types: [String]?) -> IADBCenteredArrayAirports {
        return IADBCenteredArrayAirports(centeredArray: super.findAll(identifiers:identifiers, types: types))
    }
    open override class func findAll(predicate: NSPredicate) -> IADBCenteredArrayAirports {
        return IADBCenteredArrayAirports(centeredArray: super.findAll(predicate:predicate))
    }
    //end convenience functions
    
}
