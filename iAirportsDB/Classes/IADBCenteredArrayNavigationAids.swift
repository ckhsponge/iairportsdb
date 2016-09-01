//
//  IADBCenteredArrayNavigationAids.swift
//  Pods
//
//  Created by Christopher Hobbs on 9/1/16.
//
//

import Foundation

//typed array - unfortunately for objective c compatibility generics aren't used
@objc public class IADBCenteredArrayNavigationAids: IADBCenteredArray {
    public override subscript(i: Int) -> IADBNavigationAid {
        return self.array[i] as! IADBNavigationAid
    }
}
