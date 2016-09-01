//
//  IADBArrayAirports.swift
//  Pods
//
//  Created by Christopher Hobbs on 9/1/16.
//
//

import Foundation

//typed array - unfortunately for objective c compatibility generics aren't used
@objc public class IADBCenteredArrayAirports: IADBCenteredArray {
    
    public override subscript(i: Int) -> IADBAirport {
        return self.array[i] as! IADBAirport
    }
    
    public override func removeObjectsUsingBlock(block: (airport: IADBAirport) -> Bool) {
        super.removeObjectsUsingBlock { (model:IADBLocation) -> Bool in
            if let airport = model as? IADBAirport {
                return block(airport: airport)
            }
            return false
        }
    }
    
    public func excludeSoftSurface() {
        self.removeObjectsUsingBlock({(airport: IADBAirport) -> Bool in
            return !airport.hasHardRunway()
        })
    }
    
    public func excludeRunwayShorterThan(feet: Int16) {
        self.removeObjectsUsingBlock({(airport: IADBAirport) -> Bool in
            return airport.longestRunwayFeet() < feet
        })
    }
}
