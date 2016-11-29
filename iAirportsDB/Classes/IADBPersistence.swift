//
//  IADBPersistence.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/17/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreData

open class IADBPersistence: NSObject {
    
    open var persistentStorePath: String
    let readOnly:Bool
    
    init(path: String, readOnly:Bool = true) {
        self.persistentStorePath = path
        self.readOnly = readOnly
        super.init()
        
    }
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "net.toonsy.iAirportsDB" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    open lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = IADBModel.bundle.url(forResource: "iAirportsDB", withExtension: "mom")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        //let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        let url = URL(fileURLWithPath: self.persistentStorePath)
        
        self.setPersistence(url: url, coordinator:coordinator)
        
        return coordinator
    }()
    
    open lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    open func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    open func setPersistence(url:URL) {
        self.setPersistence(url: url, coordinator:self.persistentStoreCoordinator)
    }
    
    open func setPersistence(url:URL, coordinator:NSPersistentStoreCoordinator) {
        removeStore(coordinator: coordinator)
        let options: [AnyHashable: Any] = [NSSQLitePragmasOption: ["journal_mode": "DELETE"], NSIgnorePersistentStoreVersioningOption: Int(true), NSReadOnlyPersistentStoreOption: self.readOnly ? Int(true) : Int(false)]
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
            self.persistentStorePath = url.path
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
    }
    
    open func removeStore(coordinator:NSPersistentStoreCoordinator) {
        if coordinator.persistentStores.count > 0, let store: NSPersistentStore = coordinator.persistentStores[0] {
            do {
                try coordinator.remove(store)
            }
            catch {
                let nserror = error as NSError
                NSLog("Unhandled error removing store in %s at line %d: %@", #function, #line, nserror.localizedDescription)
            }
        }
    }
    
    open func persistentStoreClear() {
        removeStore(coordinator: self.persistentStoreCoordinator)
        
        do {
            try FileManager.default.removeItem(atPath: self.persistentStorePath)
        }
        catch {
            let nserror = error as NSError
            NSLog("Warning: could not remove file in \(#function) at line \(#line): \(nserror.localizedDescription)")
        }
        //self.persistentStoreCoordinator = nil
        //self.managedObjectContext = nil
        // this object is no longer valid!
    }
}
