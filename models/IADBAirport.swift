//
//  IADBAirport.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/21/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreData

@objc(IADBAirport)
class IADBAirport: IADBLocationElevation {
    //identifier: String (defined in IADBLocation) // identifier or gps code e.g. RKSI, use this for pilot navigation
    @NSManaged var airportId: Int32
    @NSManaged var code: String // iata code e.g. ICN, this is what is printed on boarding passes
    @NSManaged var municipality: String // e.g. Seoul
    
    enum AirportType: String {
        case Large = "large_airport", Medium = "medium_airport", Small = "small_airport",
        Seaplane = "seaplane_base", Heliport = "heliport", Balloonport = "balloonport", Closed = "closed"
        
        static let allValues = [Large, Medium, Small, Seaplane, Heliport, Balloonport, Closed]
    }
    
    class func findByAirportId(airportId: Int32) -> IADBAirport? {
        let context = IADBModel.managedObjectContext()
        let entityDescription = NSEntityDescription.entityForName("IADBAirport", inManagedObjectContext: context)
        let request = NSFetchRequest()
        request.entity = entityDescription!
        // Set example predicate and sort orderings...
        let predicate = NSPredicate(format: "(airportId = %d)", airportId)
        request.predicate = predicate
        
        do {
            let array = try context.executeFetchRequest(request)
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
    
    // returns locations that begin with identifier with K prepended or the leading K removed
    // or that begin with code
    
    class func findAllByIdentifierOrCode(identifier: String, withTypes types: [String]?) -> IADBCenteredArray {
        return self.findAllByIdentifierOrCode(identifier, orMunicipality: nil, withTypes: types)
    }
    
    class func findAllByIdentifierOrCodeOrMunicipality(identifier: String, withTypes types: [String]?) -> IADBCenteredArray {
        return self.findAllByIdentifierOrCode(identifier, orMunicipality: identifier, withTypes: types)
    }
    
    class func findAllByIdentifierOrCode(identifier: String, orMunicipality municipality: String?, withTypes types: [String]?) -> IADBCenteredArray {
        if identifier.isEmpty {
            return IADBCenteredArray()
        }
        var identifierB = ""
        if identifier.characters.count >= 2 && identifier.uppercaseString.hasPrefix("K") {
            //allow "KCVH" to find CVH
            identifierB = identifier.substringFromIndex(identifier.startIndex.advancedBy(1))
            // strip off K at beginning
        }
        else {
            identifierB = "K\(identifier)"
            // add K to beginning
        }
        return self.findAllByIdentifiers([identifier, identifierB], orCode: identifier, orMunicipality: municipality, withTypes: types)
    }
    // similar to some code in IADBLocation finders
    
    class func findAllByIdentifiers(identifiers: [String], orCode code: String?, orMunicipality municipality: String?, withTypes types: [String]?) -> IADBCenteredArray {
        var arguments = [String]()
        var predicates = [String]()
        for identifier: String in identifiers {
            if !identifier.isEmpty {
                predicates.append("(identifier BEGINSWITH[c] %@)")
                arguments.append(identifier)
            }
        }
        if let _code = code where _code.characters.count > 0 {
            predicates.append("(code BEGINSWITH[c] %@)")
            arguments.append(_code)
        }
        if let _municipality = municipality where _municipality.characters.count > 0 {
            predicates.append("(municipality BEGINSWITH[c] %@)")
            arguments.append(_municipality)
        }
        if predicates.count == 0 {
            // no inputs results in no outputs
            return IADBCenteredArray()
        }
        var predicateString = predicates.joinWithSeparator(" or ")
        predicateString = "(\(predicateString)) AND \(self.predicateTypes(types))"
        let predicate = NSPredicate(format: predicateString, argumentArray: arguments)
        return self.findAllByPredicate(predicate)
    }
    
    lazy var frequencies:[IADBFrequency] = {
        if let models = IADBFrequency.findAllByAirportId(self.airportId) as? [IADBFrequency] {
            return models
        } else {
            print("!!! Invalid frequency type for airport")
        }
        return []
    }()
    
    
    lazy var runways:[IADBRunway] = {
        if let models = IADBRunway.findAllByAirportId(self.airportId) as? [IADBRunway] {
            return models
        } else {
            print("!!! Invalid runway type for airport")
        }
        return []
    }()
    
    func hasRunways() -> Bool {
        return self.runways.count > 0
    }
    
    func longestRunwayFeet() -> Int16 {
        var length:Int16 = -1
        for runway: IADBRunway in self.runways {
            if !runway.closed {
                length = max(length, runway.lengthFeet)
            }
        }
        return length
    }
    
    func longestRunway() -> IADBRunway? {
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
    
    func hasHardRunway() -> Bool {
        for runway: IADBRunway in self.runways {
            if runway.isHard() && !runway.closed {
                return true
            }
        }
        return false
    }
    
    func frequencyForName(name: String) -> IADBFrequency? {
        for f: IADBFrequency in self.frequencies {
            if name.isEqual(f.name) {
                return f
            }
        }
        return nil
    }
    
    func klessIdentifier() -> String {
        if (self.identifier.substringToIndex(self.identifier.startIndex.advancedBy(1)).uppercaseString == "K") {
            return self.identifier.substringFromIndex(self.identifier.startIndex.advancedBy(1))
        }
        return self.identifier
    }
    
    func title() -> String {
        return "\(self.identifier): \(self.name)"
    }
    
    override var description: String {
        return "<\(self.identifier) (\(self.code)) \(self.name) \(self.latitude) \(self.longitude) \(self.elevationFeet) <\(self.type)>"
    }
    
    func asDictionary() -> [NSObject : AnyObject] {
        return ["identifier": self.identifier, "name": self.name, "type": self.type, "latitude": Int(self.latitude), "longitude": Int(self.latitude), "elevationFeet": self.elevationForLocation()]
    }
    
    override func setCsvValues( values: [String: String] ) {
        //"id","ident","type","name","latitude_deg","longitude_deg","elevation_ft","continent","iso_country","iso_region","municipality","scheduled_service","gps_code","iata_code","local_code","home_link","wikipedia_link","keywords"
        //print(values)
        
        self.airportId = Int32(values["id"]!)!
        self.code = values["iata_code"] ?? ""
        let elevationString = values["elevation_ft"] ?? ""
        self.identifier = (values["gps_code"] ?? "").isEmpty ? values["ident"] ?? "" : values["gps_code"] ?? ""
        self.latitude = Double(values["latitude_deg"]!)!
        self.longitude = Double(values["longitude_deg"]!)!
        self.municipality = values["municipality"] ?? ""
        self.name = values["name"] ?? ""
        self.type = values["type"] ?? ""
        self.elevationFeet = elevationString.isEmpty ? nil : Int( elevationString )
    }

}
