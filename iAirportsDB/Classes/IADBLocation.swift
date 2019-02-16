//
//  IADBLocation.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/23/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

open class IADBLocation: IADBModel, Comparable {
    @NSManaged open var identifier: String
    @NSManaged open var latitude: Double
    @NSManaged open var longitude: Double
    
    private static let location_timestamp = Date(timeIntervalSince1970: 0)
    
    var distance:CLLocationDistance = 999999999999
    
    //don't trust the altitude, self.elevationFeet may be null
    open lazy var location: CLLocation = {
        return CLLocation(coordinate: CLLocationCoordinate2DMake(self.latitude, self.longitude), altitude: self.elevationForLocation(), horizontalAccuracy: 0.0, verticalAccuracy: 0.0, timestamp: IADBLocation.location_timestamp)
    }()
    
    //This scalar is used when constructing a CLLocation. Meters.
    func elevationForLocation() -> CLLocationDistance {
        return 0.0
    }
    
    public static func <(a:IADBLocation, b:IADBLocation) -> Bool {
        return a.distance < b.distance
    }
    
    class func subclassNames() -> [String] {
        return ["IADBAirport", "IADBNavigationAid", "IADBFix"]
    }
    
    class func subclasses() -> [IADBLocation.Type] {
        return [IADBAirport.self, IADBNavigationAid.self] //, IADBFix.self]
    }
    
    // returns true if this is exactly an IADBLocation and not a subclass
    class func isLocationSuperclass() -> Bool {
        return self.descriptionShort() == "IADBLocation"
    }
    
    class func eachSubclass(_ block: (_ klass: IADBLocation.Type) -> IADBCenteredArray) -> IADBCenteredArray {
        let result = IADBCenteredArray()
        for klass: IADBLocation.Type in self.subclasses() {
            let array = block(klass)
            result.addCenteredArray(array)
        }
        result.sortInPlace()
        return result
    }
    
    //returns airports near a location sorted by distance
    open class func findNear(_ location: CLLocation, withinNM distance: CLLocationDistance) -> IADBCenteredArray {
        if self.isLocationSuperclass() {
            return self.eachSubclass({(klass: IADBLocation.Type) -> IADBCenteredArray in
                return klass.findNear(location, withinNM: distance)
            })
        }
        else {
            return self.findNear(location, withinNM: distance, types: nil)
        }
    }
    
    // finds locations within distance of location with a type in types
    // if types is nil then ignore types i.e. return all types
    // if types is [] then return nothing
    // results are sorted by distance from location
    open class func findNear(_ location: CLLocation, withinNM distance: CLLocationDistance, types: [String]?) -> IADBCenteredArray {
        // Set example predicate and sort orderings...
        var latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        latitude = max(min(latitude, 89.0), -89.0)
        //don't allow calculations at the poles or there will be divide-by-zero errors
        let degreesLatitude = IADBConstants.latitudeDegreesFromNM(distance)
        //approximate because earth is an ellipse
        let degreesLongitude = IADBConstants.longitudeDegreesFromNM(distance, latitude: latitude)
        //longitude degrees are smaller further from equator
        var predicateString: String
        if longitude - degreesLongitude < -180.0 || longitude + degreesLongitude > 180.0 {
            //if the search spans the date line then use 'or' instead of 'and' because one parameter will have wrapped
            predicateString = "(%lf < latitude) AND (latitude < %lf) AND ((%lf < longitude) OR (longitude < %lf))"
        }
        else {
            predicateString = "(%lf < latitude) AND (latitude < %lf) AND ((%lf < longitude) AND (longitude < %lf))"
        }
        predicateString = "\(predicateString) AND \(self.predicateTypes(types))"
        //finds all airports within a box to take advantage of database indexes
        let predicate = NSPredicate(format: predicateString, latitude - degreesLatitude, latitude + degreesLatitude, IADBConstants.within180To180(longitude - degreesLongitude), IADBConstants.within180To180(longitude + degreesLongitude))
        let airports:IADBCenteredArray = self.findAll(predicate:predicate)
        airports.center = location
        airports.excludeOutsideNM(distance, fromCenter: location)
        //trims airports to be within circle i.e. distance
        airports.sortInPlace(location)
        return airports
    }
    
    //creates predicate ORing types
    class func predicateTypes(_ types: [String]?) -> String {
        guard let _types = types else {
            return "(1==1)"
        }
        if _types.isEmpty {
            return "(0==1)"
        }
        var predicateTypes = [String]()
        for type in _types {
            predicateTypes.append("(type = '\(type)')")
        }
        return "(\(predicateTypes.joined(separator: " OR ")))"
    }
    
    
    @objc open class func find(identifier: String) -> IADBLocation? {
        let predicate = NSPredicate(format: "identifier = %@", identifier)
        let array = self.findAll(predicate:predicate)
        if array.array.count != 1 {
            print("WARNING! findByIdentifier \(identifier) returned \(UInt(array.array.count)) results")
        }
        return array.array.count > 0 ? array.array[0] : nil
    }
    
    //[IADBLocation findAllByIdentifier:] unions finds across all subclasses
    //IADBAirport uses findAllByIdentifierOrCode: to include K airports
    @objc open class func findAll(identifier: String) -> IADBCenteredArray {
        if self.isLocationSuperclass() {
            return self.eachSubclass({(klass: IADBLocation.Type) -> IADBCenteredArray in
                if klass.descriptionShort() == "IADBAirport" {
                    //downcast for collation with other types
                    let types:[String]? = nil
                    return IADBAirport.findAll(identifierOrCode:identifier, types: types)
                } else {
                    return klass.findAll(identifier:identifier)
                }
            })
        }
        else {
            return self.findAll(identifier:identifier, types: nil)
        }
    }
    //returns locations that begin with identifier
    
    @objc open class func findAll(identifier: String, types: [String]?) -> IADBCenteredArray {
        if identifier.isEmpty {
            return IADBCenteredArray()
        }
        return self.findAll(identifiers:[identifier], types: types)
    }
    // similar to some code in IADBAirport finders
    
    @objc open class func findAll(identifiers: [String], types: [String]?) -> IADBCenteredArray {
        var arguments = [String]()
        var predicates = [String]()
        for identifier: String in identifiers {
            self.beginsWith(column: "identifier", value: identifier, predicates: &predicates , arguments: &arguments)
        }
        if predicates.count == 0 {
            // no inputs results in no outputs
            return IADBCenteredArray()
        }
        var predicateString = predicates.joined(separator: " or ")
        predicateString = "(\(predicateString)) AND \(self.predicateTypes(types))"
        let predicate = NSPredicate(format: predicateString, argumentArray: arguments)
        return self.findAll(predicate:predicate)
    }
    
    class func beginsWith(column:String, value:String?, predicates:inout [String], arguments:inout [String], upcase:Bool = true) {
        guard var value = value, !value.isEmpty else { return }
        if upcase {
            value = value.uppercased()
        }
        //predicates.append("(identifier BEGINSWITH[c] %@)")
        //arguments.append(identifier)
        var scalars = Array.init(value.unicodeScalars)
        if let last = scalars.popLast(), let unicode = UnicodeScalar(last.value + 1) {
            scalars.append(unicode)
        }
        predicates.append("((\(column) >= %@) AND (\(column) < %@))")
        arguments.append(value)
        var scalarsString = ""
        scalarsString.unicodeScalars.append(contentsOf: scalars)
        arguments.append(scalarsString)
    }
    
    @objc open class func findAll(predicate: NSPredicate) -> IADBCenteredArray {
        let (request, context) = fetchRequestContext()
        request.predicate = predicate
        //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
        //                                        initWithKey:@"name" ascending:YES];
        //    [request setSortDescriptors:@[sortDescriptor]];
        print("fetch \(self.descriptionShort()): \(request)")
        let time = Date()
        
        var resultError:Error?
        var result:IADBCenteredArray?
        do {
            try TryCatch.try({
                do {
                    let array = try context.fetch(request)
                    print("fetched \(array.count) in \(-1.0*time.timeIntervalSinceNow)s")
                    if let models = array as? [IADBLocation] {
                        result =  IADBCenteredArray.init(array: models)
                    } else {
                        print("Fetch contained an invalid type \(array)")
                        let message = "Fetch contained an invalid type: \(array) -- fetch \(self.descriptionShort()): \(request)"
                        resultError = NSError(domain: "net.toonsy.iairportsdb", code: 1, userInfo: ["message": message])
                    }
                } catch {
                    resultError = error
                }
            })
        } catch let errorCaught as NSError {
            // failure
            print("Fetch failed: \(errorCaught.localizedDescription)")
            resultError = errorCaught
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
            resultError = error
        }
        //catch invalidArgument as NSInvalidArgumentException {
        //    error = invalidArgument
        //}
        if resultError != nil {
            return IADBCenteredArray(error:resultError)
        }
        if let r = result {
            return r
        }
        resultError = NSError(domain: "net.toonsy.iairportsdb", code: 1, userInfo: ["message": "nothing found"])
        return IADBCenteredArray(error:resultError)
    }
}
