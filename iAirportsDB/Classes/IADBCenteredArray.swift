//
//  IADBCenteredArray.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/21/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import CoreLocation

@objc public class IADBCenteredArray: NSObject, CollectionType {
    public var array: [IADBLocation]
    public var center: CLLocation?
    
    
    public init(array: [IADBLocation], center:CLLocation?) {
        self.array = array
        self.center = center
        super.init()
        
        self.removeObjectsUsingBlock { (model:IADBLocation) -> Bool in
            if model.isKindOfClass(self.dynamicType) {
                print("WARNING!!! constructing IADBCenteredArray with wrong type")
                return true
            } else {
                return false
            }
        }
    }
    
    override public convenience init() {
        self.init(array:[IADBLocation](), center:nil)
    }
    
    public convenience init(array: [IADBLocation]) {
        self.init(array:array, center:nil)
    }
    
    public convenience init(centeredArray: IADBCenteredArray) {
        self.init(array:centeredArray.array, center:centeredArray.center)
    }
    
    public var startIndex: Int {
        return 0
//        return array.count - 1;
    }
    
    public var endIndex: Int {
        return array.count
    }
    
    public subscript(i: Int) -> IADBLocation {
        return array[i]
    }
    
    //TODO implement type checking so you can't add nav aids to an airport array
    //nav aids can be added to locations, however
    public func addCenteredArray(array: IADBCenteredArray) {
        self.array.appendContentsOf(array.array)
        if self.center == nil {
            self.center = array.center
        }
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
    
    public func removeObjectsUsingBlock(block: (model: IADBLocation) -> Bool) {
        var i = array.count - 1
        while i >= 0 {
            if block(model: self[i]) {
                array.removeAtIndex(i)
            }
            i -= 1
        }
    }
    
    public func excludeOutsideNM(nm: CLLocationDistance, fromCenter center: CLLocation) {
        let m = nm * IADBConstants.metersPerNM
        self.removeObjectsUsingBlock({(model: IADBLocation) -> Bool in
            let distance = center.distanceFromLocation(model.location)
            return distance > m
        })
    }
    
    override public var description: String {
        return "Center: \(center), Airports: \(array.description)"
    }
}