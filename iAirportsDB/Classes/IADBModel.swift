//
//  IADBModel.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/17/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreData

open class IADBModel: NSManagedObject {
    open static var bundle:Bundle = {
        let mainBundle = Bundle(for: IADBModel.self)
        let bundleURL = mainBundle.url(forResource: "resourcebundle", withExtension: "bundle")
        return Bundle(url: bundleURL!)!
    }()
    
    open static var persistence: IADBPersistence = {
        return IADBPersistence(path: bundle.path(forResource: "iAirportsDB", ofType: "sqlite")!)
    }()
    
    open class func setPersistantStorePath(_ path: String) {
        self.persistence = IADBPersistence(path: path)
        print("Persistant store path: \(path)")
    }
    
    open class func clearPersistence() {
        self.persistence.persistentStoreClear()
        self.persistence = IADBPersistence(path: self.persistence.persistentStorePath)
        print("Cleared local db")
    }
    
    open class func managedObjectContext() -> NSManagedObjectContext {
        return self.persistence.managedObjectContext
    }
    
    open class func countAll() -> Int {
        let fetch = NSFetchRequest<IADBModel>(entityName: self.description())
        var error: NSError? = nil
        do {
            let count = try IADBModel.managedObjectContext().count(for: fetch)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    open class func descriptionShort() -> String {
        return self.description().replacingOccurrences(of: "iAirportsDB.", with: "")
    }
    
    class func parseIntNumber(text:String?) -> NSNumber? {
        if let t = text, !t.isEmpty, let i:Int = Int(t) {
            return NSNumber( value: i )
        }
        return nil
    }
    
    open class func entityDescriptionContext() -> (NSEntityDescription, NSManagedObjectContext) {
        let context: NSManagedObjectContext = IADBModel.managedObjectContext()
        let name = self.descriptionShort()
        let entityDescription: NSEntityDescription? = NSEntityDescription.entity(forEntityName: name, in: context)
        if entityDescription == nil {
            print("ERROR !!!! entity not found for \(name)")
        }
        return (entityDescription!, context)
    }
    
    open class func fetchRequestContext() -> (NSFetchRequest<IADBModel>, NSManagedObjectContext) {
        let (entityDescription, context) = self.entityDescriptionContext()
        let request: NSFetchRequest = NSFetchRequest<IADBModel>()
        request.entity = entityDescription
        return (request, context)
    }
    
    open class func findAllByAirportId(_ airportId: Int32) -> [IADBModel] {
        // Set example predicate and sort orderings...
        let predicate: NSPredicate = NSPredicate(format: "(airportId = %d)", airportId)
        let (request, context) = fetchRequestContext()
        request.predicate = predicate
        do {
            let objects = try context.fetch(request)
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
    
    required override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    open func setCsvValues( _ values: [String: String] ) {
        // override me please
    }
}
