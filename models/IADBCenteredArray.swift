//
//  IADBCenteredArray.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/21/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import CoreLocation

let METERS_PER_NM = (1852.0)
class IADBCenteredArray: NSObject {
    var array = [IADBLocation]()
    var center: CLLocation?
    
    override init() {
        
    }
    
    init(array a: [IADBLocation]) {
        do {
            super.init()
            
            self.array = a
            self.center = nil
        }
    }
    
    func count() -> Int {
        return array.count
    }
    
    func addCenteredArray(array: IADBCenteredArray) {
        self.array.appendContentsOf(array.array)
    }
    
    func sort() {
        if let center = self.center {
            self.sortByCenter(center)
        }
    }
    
    func sortByCenter(center: CLLocation) {
        array.sortInPlace { (a: IADBLocation, b: IADBLocation) -> Bool in
            let distanceA = a.location.distanceFromLocation(center)
            let distanceB = b.location.distanceFromLocation(center)
            return distanceA < distanceB
        }
    }
    
    func removeObjectsUsingBlock(block: (airport: IADBLocation) -> Bool) {
        var i = array.count - 1
        while i >= 0 {
            if block(airport: array[i]) {
                array.removeAtIndex(i)
            }
            i -= 1
        }
    }
    
    func excludeOutsideNM(nm: CLLocationDistance, fromCenter center: CLLocation) {
        let m = nm * METERS_PER_NM
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
    
    func excludeSoftSurface() {
        self.removeObjectsUsingBlock({(model: IADBLocation) -> Bool in
            if let airport = model as? IADBAirport {
                return !airport.hasHardRunway()
            }
            return false
        })
    }
    
    func excludeRunwayShorterThan(feet: Int16) {
        self.removeObjectsUsingBlock({(model: IADBLocation) -> Bool in
            if let airport = model as? IADBAirport {
                return airport.longestRunwayFeet() < feet
            }
            return false
        })
    }
    
    override var description: String {
        return "Center: \(center), Airports: \(array.description)"
    }
}