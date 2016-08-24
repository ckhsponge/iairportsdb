//
//  IADBModel.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/17/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreData

class IADBModel: NSManagedObject {
    static var persistence: IADBPersistence = {
        return IADBPersistence(path: NSBundle.mainBundle().pathForResource("iAirportsDB", ofType: "sqlite")!)
    }()
    
    class func setPersistantStorePath(path: String) {
        self.persistence = IADBPersistence(path: path)
        print("Persistant store path: \(path)")
    }
    
    class func clearPersistence() {
        self.persistence.persistentStoreClear()
        self.persistence = IADBPersistence(path: self.persistence.persistentStorePath)
        print("Cleared local db")
    }
    
    class func managedObjectContext() -> NSManagedObjectContext {
        return self.persistence.managedObjectContext
    }
    
    class func countAll() -> Int {
        let fetch = NSFetchRequest(entityName: self.description())
        var error: NSError? = nil
        let count = IADBModel.managedObjectContext().countForFetchRequest(fetch, error: &error)
        assert(error == nil, "Unhandled error counting in \(#function) at line \(#line): \(error!.localizedDescription)")
        return count
    }
    
    func isBlank() -> Bool {
        return self.valueForKey("airportId") == nil
    }
    
    class func findAllByAirportId(airportId: Int32) -> [IADBModel] {
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
    
    required override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    func setCsvValues( values: [String: String] ) {
        // override me please
    }
}