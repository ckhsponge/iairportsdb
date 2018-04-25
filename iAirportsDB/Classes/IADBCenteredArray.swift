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
    open var error: Error?
    
    public init(array: [IADBLocation], center:CLLocation?, error:Error?) {
        self.array = array
        self.center = center
        self.error = error
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
        self.init(array:[IADBLocation](), center:nil, error:nil)
    }
    
    public convenience init(array: [IADBLocation]) {
        self.init(array:array, center:nil)
    }
    
    public convenience init(centeredArray: IADBCenteredArray) {
        self.init(array:centeredArray.array, center:centeredArray.center, error: centeredArray.error)
    }
    
    public convenience init(array: [IADBLocation], center:CLLocation?) {
        self.init(array: array, center:center, error:nil)
    }
    
    public convenience init(error:Error?) {
        self.init(array:[IADBLocation](), center:nil, error:error)
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
        //print("sortInPlace")
        //let start = Date()
        for airport in array {
            airport.distance = center.distance(from: airport.location) //about as fast as squaring x and y distances
        }
        //let start1 = Date()
        if !self.isSorted() {
            array.sort() //This is slow! ~0.25s for 5000 elements on iPad mini
        }
        //print("sorted \(array.count) \(-1.0*start.timeIntervalSinceNow) \(-1.0*start1.timeIntervalSinceNow)")
    }
    
    //make sure distance is set on each array element before calling this
    private func isSorted() -> Bool {
        if array.count <= 1 { return true }
        var sorted = true
        for i in 0...(array.count - 2) {
            if array[i].distance > array[i+1].distance {
                sorted = false
            }
        }
        return sorted
    }
    
    open func removeObjectsUsingBlock(_ block: (_ model: IADBLocation) -> Bool) {
        array = array.filter { !block($0) }
    }
    
    open func excludeOutsideNM(_ nm: CLLocationDistance, fromCenter center: CLLocation) {
        let m = nm * IADBConstants.metersPerNM
        self.removeObjectsUsingBlock({(model: IADBLocation) -> Bool in
            let distance = center.distance(from: model.location)
            return distance > m
        })
    }
    
    override open var description: String {
        return "Center: \(String(describing: center)), Airports: \(array.description)"
    }
}
