//
//  AirportPersistence.m
//  descent
//
//  Created by Christopher Hobbs on 2/16/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "IADBPersistence.h"

@implementation IADBPersistence

-(id) initWithPath:(NSString *) path {
    if( self = [super init] ) {
        _persistentStorePath = path;
    }
    return self;
}

#pragma mark - Core Data stack setup

//
// These methods are very slightly modified from what is provided by the Xcode template
// An overview of what these methods do can be found in the section "The Core Data Stack"
// in the following article:
// http://developer.apple.com/iphone/library/documentation/DataManagement/Conceptual/iPhoneCoreData01/Articles/01_StartingOut.html
//

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator == nil) {
        NSURL *storeUrl = [NSURL fileURLWithPath:self.persistentStorePath];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSError *error = nil;
        
        NSDictionary *options = @{ NSSQLitePragmasOption : @{ @"journal_mode" : @"DELETE" },
                                   NSIgnorePersistentStoreVersioningOption : [NSNumber numberWithBool:YES]};
        
        NSPersistentStore *persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error];
        //NSPersistentStore *persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
        if( !persistentStore ) { NSLog( @"Unhandled error adding persistent store in %s at line %d: %@ url: %@", __FUNCTION__, __LINE__, [error localizedDescription],storeUrl); }
    }
    return _persistentStoreCoordinator;
}

//- (NSManagedObjectContext *)managedObjectContext {
//    
//    if (_managedObjectContext == nil) {
//        NSLog(@"init context");
//        
//        _managedObjectContext = [[NSManagedObjectContext alloc] init];
//        [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
//        [[self.managedObjectContext undoManager] disableUndoRegistration];
//    }
//    return _managedObjectContext;
//}

- (NSString *)persistentStorePath {
    
//    if (_persistentStorePath == nil) {
////        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
////        NSString *documentsDirectory = [paths lastObject];
////        _persistentStorePath = [documentsDirectory stringByAppendingPathComponent:@"Airports.sqlite"];
//        
//        //_persistentStorePath = @"/Users/ckh/dev/airportsdb/data/airportsdb.sqlite";
//        _persistentStorePath = [[NSBundle mainBundle] pathForResource:@"airportsdb" ofType:@"sqlite"];
//    }
    return _persistentStorePath;
}

-(void) persistentStoreClear {
    NSError *error = nil;
    if( _persistentStoreCoordinator ) {
        NSPersistentStoreCoordinator *storeCoordinator = [self persistentStoreCoordinator];
        NSPersistentStore *store = [storeCoordinator persistentStores][0];
        [storeCoordinator removePersistentStore:store error:&error];
        NSAssert3(!error, @"Unhandled error removing store in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
    }
    [[NSFileManager defaultManager] removeItemAtPath:[self persistentStorePath] error:&error];
    if(error) { NSLog( @"Warning: could not remove file in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]); }
    
    _persistentStoreCoordinator = nil;
    _managedObjectContext = nil;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Persistence path: %@",_persistentStorePath];
}



//- (void)saveContext
//{
//    NSError *error = nil;
//    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
//    if (managedObjectContext != nil) {
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
//            // Replace this implementation with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
//}
//
//#pragma mark - Core Data stack
//
//// Returns the managed object context for the application.
//// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}
//
//// Returns the managed object model for the application.
//// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"airportsdb" withExtension:@"mom"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
//
//// Returns the persistent store coordinator for the application.
//// If the coordinator doesn't already exist, it is created and the application's store added to it.
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
//{
//    if (_persistentStoreCoordinator != nil) {
//        return _persistentStoreCoordinator;
//    }
//    
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"airportsdb.sqlite"];
//    
//    NSError *error = nil;
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//        /*
//         Replace this implementation with code to handle the error appropriately.
//         
//         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//         
//         Typical reasons for an error here include:
//         * The persistent store is not accessible;
//         * The schema for the persistent store is incompatible with current managed object model.
//         Check the error message to determine what the actual problem was.
//         
//         
//         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
//         
//         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
//         * Simply deleting the existing store:
//         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
//         
//         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
//         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
//         
//         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
//         
//         */
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    
//    return _persistentStoreCoordinator;
//}
//
//#pragma mark - Application's Documents directory
//
//// Returns the URL to the application's Documents directory.
//- (NSURL *)applicationDocumentsDirectory
//{
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//}


@end
