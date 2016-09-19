//
//  IADBCenteredArrayNavigationAids.swift
//  Pods
//
//  Created by Christopher Hobbs on 9/1/16.
//
//

import Foundation

//typed array - unfortunately for objective c compatibility generics aren't used
@objc open class IADBCenteredArrayNavigationAids: IADBCenteredArray {
    open override subscript(i: Int) -> IADBNavigationAid {
        return self.array[i] as! IADBNavigationAid
    }
}
