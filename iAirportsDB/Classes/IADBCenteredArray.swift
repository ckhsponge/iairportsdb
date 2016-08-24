//
//  IADBCenteredArray.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/21/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import CoreLocation

public class IADBCenteredArray: NSObject {
    public var array = [IADBLocation]()
    public var center: CLLocation?
    
    override public init() {
        
    }
    
    public init(array a: [IADBLocation]) {
        do {
            super.init()
            
            self.array = a
            self.center = nil
        }
    }
    
    public func count() -> Int {
        return array.count
    }
    
    public func addCenteredArray(array: IADBCenteredArray) {
        self.array.appendContentsOf(array.array)
    }
    
    public func sort() {
        if let center = self.center {
            self.sortByCenter(center)
        }
    }
    
    public func sortByCenter(center: CLLocation) {
        array.sortInPlace { (a: IADBLocation, b: IADBLocation) -> Bool in
            let distanceA = a.location.distanceFromLocation(center)
            let distanceB = b.location.distanceFromLocation(center)
            return distanceA < distanceB
        }
    }
    
    public func removeObjectsUsingBlock(block: (airport: IADBLocation) -> Bool) {
        var i = array.count - 1
        while i >= 0 {
            if block(airport: array[i]) {
                array.removeAtIndex(i)
            }
            i -= 1
        }
    }
    
    public func excludeOutsideNM(nm: CLLocationDistance, fromCenter center: CLLocation) {
        let m = nm * IADBConstants.metersPerNM
        //    for( NSInteger i = _array.count - 1; i >= 0; i--) {
        //        CLLocationDistance distance = [center distanceFromLocation:((Airport *) _array[i]).location];
        //        if ( distance > m) {
        //            [_array removeObjectAtIndex:i];
        //        }
        //    }
        self.removeObjectsUsingBlock({(airport: IADBLocation) -> Bool in
            let distance = center.distanceFromLocation(airport.location)
            return distance > m
        })
    }
    
    public func excludeSoftSurface() {
        self.removeObjectsUsingBlock({(model: IADBLocation) -> Bool in
            if let airport = model as? IADBAirport {
                return !airport.hasHardRunway()
            }
            return false
        })
    }
    
    public func excludeRunwayShorterThan(feet: Int16) {
        self.removeObjectsUsingBlock({(model: IADBLocation) -> Bool in
            if let airport = model as? IADBAirport {
                return airport.longestRunwayFeet() < feet
            }
            return false
        })
    }
    
    override public var description: String {
        return "Center: \(center), Airports: \(array.description)"
    }
}