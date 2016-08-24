//
//  IADBModel.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/17/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreData

public class IADBModel: NSManagedObject {
    public static var bundle:NSBundle = {
        let mainBundle = NSBundle(forClass: IADBModel.self)
        let bundleURL = mainBundle.URLForResource("resourcebundle", withExtension: "bundle")
        return NSBundle(URL: bundleURL!)!
    }()
    
    public static var persistence: IADBPersistence = {
        return IADBPersistence(path: bundle.pathForResource("iAirportsDB", ofType: "sqlite")!)
    }()
    
    public class func setPersistantStorePath(path: String) {
        self.persistence = IADBPersistence(path: path)
        print("Persistant store path: \(path)")
    }
    
    public class func clearPersistence() {
        self.persistence.persistentStoreClear()
        self.persistence = IADBPersistence(path: self.persistence.persistentStorePath)
        print("Cleared local db")
    }
    
    public class func managedObjectContext() -> NSManagedObjectContext {
        return self.persistence.managedObjectContext
    }
    
    public class func countAll() -> Int {
        let fetch = NSFetchRequest(entityName: self.description())
        var error: NSError? = nil
        let count = IADBModel.managedObjectContext().countForFetchRequest(fetch, error: &error)
        assert(error == nil, "Unhandled error counting in \(#function) at line \(#line): \(error!.localizedDescription)")
        return count
    }
    
    public class func findAllByAirportId(airportId: Int32) -> [IADBModel] {
        let context: NSManagedObjectContext = IADBModel.managedObjectContext()
        let entityDescription: NSEntityDescription = NSEntityDescription.entityForName(self.description(), inManagedObjectContext: context)!
        let request: NSFetchRequest = NSFetchRequest()
        request.entity = entityDescription
        // Set example predicate and sort orderings...
        let predicate: NSPredicate = NSPredicate(format: "(airportId = %d)", airportId)
        request.predicate = predicate
        do {
            let objects = try context.executeFetchRequest(request)
            if let models = objects as? [IADBModel] {
                return models
            } else {
                print( "Invalid types in findAllByAirportId \(objects)")
            }
        }
        catch let error as NSError {
            NSLog( "Unhandled error removing file in \(#function) at line \(#line): \(error.localizedDescription)")
        }
        return []
    }
    
    required override public init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    public func setCsvValues( values: [String: String] ) {
        // override me please
    }
}