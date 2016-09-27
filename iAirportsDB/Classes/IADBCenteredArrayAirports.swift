//
//  IADBArrayAirports.swift
//  Pods
//
//  Created by Christopher Hobbs on 9/1/16.
//
//

import Foundation

//typed array - unfortunately for objective c compatibility generics aren't used
@objc open class IADBCenteredArrayAirports: IADBCenteredArray {
    
    open override subscript(i: Int) -> IADBAirport {
        return self.array[i] as! IADBAirport
    }
    
    open override func removeObjectsUsingBlock(_ block: (_ airport: IADBAirport) -> Bool) {
        super.removeObjectsUsingBlock { (model:IADBLocation) -> Bool in
            if let airport = model as? IADBAirport {
                return block(airport)
            }
            return false
        }
    }
    
    open func excludeSoftSurface() {
        self.removeObjectsUsingBlock({(airport: IADBAirport) -> Bool in
            return !airport.hasHardRunway()
        })
    }
    
    open func excludeRunwayShorterThan(feet: Int) {
        self.removeObjectsUsingBlock({(airport: IADBAirport) -> Bool in
            return Int(airport.longestRunwayFeet()) < feet
        })
    }
}
