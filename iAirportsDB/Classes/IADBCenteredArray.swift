//
//  IADBCenteredArray.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/21/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import CoreLocation

@objc open class IADBCenteredArray: NSObject, Collection {

    open var array: [IADBLocation]
    open var center: CLLocation?
    
    
    public init(array: [IADBLocation], center:CLLocation?) {
        self.array = array
        self.center = center
        super.init()
        
        self.removeObjectsUsingBlock { (model:IADBLocation) -> Bool in
            if model.isKind(of: type(of: self)) {
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
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return self.array.index(after: i)
    }
    
    open var startIndex: Int {
        return 0
//        return array.count - 1;
    }
    
    open var endIndex: Int {
        return array.count
    }
    
    open subscript(i: Int) -> IADBLocation {
        return array[i]
    }
    
    //TODO implement type checking so you can't add nav aids to an airport array
    //nav aids can be added to locations, however
    open func addCenteredArray(_ array: IADBCenteredArray) {
        self.array.append(contentsOf: array.array)
        if self.center == nil {
            self.center = array.center
        }
    }
    
    open func sortInPlace() {
        if let center = self.center {
            self.sortInPlace(center)
        }
    }
    
    open func sortInPlace(_ center: CLLocation) {
        array.sort { (a: IADBLocation, b: IADBLocation) -> Bool in
            let distanceA = a.location.distance(from: center)
            let distanceB = b.location.distance(from: center)
            return distanceA < distanceB
        }
    }
    
    open func removeObjectsUsingBlock(_ block: (_ model: IADBLocation) -> Bool) {
        var i = array.count - 1
        while i >= 0 {
            if block(self[i]) {
                array.remove(at: i)
            }
            i -= 1
        }
    }
    
    open func excludeOutsideNM(_ nm: CLLocationDistance, fromCenter center: CLLocation) {
        let m = nm * IADBConstants.metersPerNM
        self.removeObjectsUsingBlock({(model: IADBLocation) -> Bool in
            let distance = center.distance(from: model.location)
            return distance > m
        })
    }
    
    override open var description: String {
        return "Center: \(center), Airports: \(array.description)"
    }
}
