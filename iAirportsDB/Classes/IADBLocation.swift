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

public class IADBLocation: IADBModel {
    @NSManaged public var identifier: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    
    //don't trust the altitude, self.elevationFeet may be null
    public lazy var location: CLLocation = {
        return CLLocation(coordinate: CLLocationCoordinate2DMake(self.latitude, self.longitude), altitude: self.elevationForLocation(), horizontalAccuracy: 0.0, verticalAccuracy: 0.0, timestamp: NSDate())
    }()
    
    //This scalar is used when constructing a CLLocation. Meters.
    func elevationForLocation() -> CLLocationDistance {
        return 0.0
    }
    
    class func entityName() -> String {
        return self.description()
    }
    
    class func subclassNames() -> [String] {
        return ["IADBAirport", "IADBNavigationAid", "IADBFix"]
    }
    
    class func subclasses() -> [IADBLocation.Type] {
        return [IADBAirport.self, IADBNavigationAid.self] //, IADBFix.self]
    }
    
    class func isLocationSuperclass() -> Bool {
        return (self.entityName() == "IADBLocation" || self.entityName() == "iAirportsDB.IADBLocation")
    }
    
    class func eachSubclass(block: (klass: IADBLocation.Type) -> IADBCenteredArray) -> IADBCenteredArray {
        var result: IADBCenteredArray?
        for klass: IADBLocation.Type in self.subclasses() {
            let array = block(klass: klass)
            if let r = result {
                r.addCenteredArray(array)
            }
            else {
                result = array
            }
        }
        result!.sort()
        return result!
    }
    //returns airports near a location sorted by distance
    
    public class func findNear(location: CLLocation, withinNM distance: CLLocationDistance) -> IADBCenteredArray {
        if self.isLocationSuperclass() {
            return self.eachSubclass({(klass: IADBLocation.Type) -> IADBCenteredArray in
                return klass.findNear(location, withinNM: distance)
            })
        }
        else {
            return self.findNear(location, withinNM: distance, withTypes: nil)
        }
    }
    
    public class func findNear(location: CLLocation, withinNM distance: CLLocationDistance, withTypes types: [String]?) -> IADBCenteredArray {
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
        let airports = self.findAllByPredicate(predicate)
        airports.center = location
        airports.excludeOutsideNM(distance, fromCenter: location)
        //trims airports to be within circle i.e. distance
        airports.sortByCenter(location)
        return airports
    }
    
    //creates predicate ORing types
    class func predicateTypes(types: [String]?) -> String {
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
        return "(\(predicateTypes.joinWithSeparator(" OR ")))"
    }
    
    
    public class func findByIdentifier(identifier: String) -> IADBLocation? {
        let predicate = NSPredicate(format: "identifier = %@", identifier)
        let array = self.findAllByPredicate(predicate)
        if array.array.count != 1 {
            print("WARNING! findByIdentifier \(identifier) returned \(UInt(array.array.count)) results")
        }
        return array.array.count > 0 ? array.array[0] : nil
    }
    //[IADBLocation findAllByIdentifier:] unions finds across all subclasses
    //IADBAirport uses findAllByIdentifierOrCode: to include K airports
    
    public class func findAllByIdentifier(identifier: String) -> IADBCenteredArray {
        if self.isLocationSuperclass() {
            return self.eachSubclass({(klass: IADBLocation.Type) -> IADBCenteredArray in
                return (klass.entityName() == "IADBAirport") ? IADBAirport.findAllByIdentifierOrCode(identifier, withTypes: nil) : klass.findAllByIdentifier(identifier)
            })
        }
        else {
            return self.findAllByIdentifier(identifier, withTypes: nil)
        }
    }
    //returns locations that begin with identifier
    
    public class func findAllByIdentifier(identifier: String, withTypes types: [String]?) -> IADBCenteredArray {
        if identifier.isEmpty {
            return IADBCenteredArray()
        }
        return self.findAllByIdentifiers([identifier], withTypes: types)
    }
    // similar to some code in IADBAirport finders
    
    public class func findAllByIdentifiers(identifiers: [String], withTypes types: [String]?) -> IADBCenteredArray {
        var arguments = [String]()
        var predicates = [String]()
        for identifier: String in identifiers {
            if !identifier.isEmpty {
                predicates.append("(identifier BEGINSWITH[c] %@)")
                arguments.append(identifier)
            }
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
    
    public class func findAllByPredicate(predicate: NSPredicate) -> IADBCenteredArray {
        let context = IADBModel.managedObjectContext()
        //test
        //let object = context.objectWithID(NSManagedObjectID(38694))
        //print(object)
        //let _predicate = NSPredicate(format: "code = null")
        //end test
        let entityDescription = NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: context)
        let request = NSFetchRequest()
        request.entity = entityDescription!
        request.predicate = predicate
        //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
        //                                        initWithKey:@"name" ascending:YES];
        //    [request setSortDescriptors:@[sortDescriptor]];
        print("fetch \(self.entityName()): \(request)")
        
        do {
            let array = try context.executeFetchRequest(request)
            if let models = array as? [IADBLocation] {
                return IADBCenteredArray.init(array: models)
            } else {
                print("Fetch contained an invalid type \(array)")
            }
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
        return IADBCenteredArray()
    }
}