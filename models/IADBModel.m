//
//  NrstModel.m
//  airportsdb
//
//  Created by Christopher Hobbs on 2/18/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "IADBModel.h"
#import "Airport.h"
#import "IADBPersistence.h"

static IADBPersistence *_persistence = nil;

@implementation IADBModel

+(IADBPersistence *) persistence {
    if( !_persistence ) {
        _persistence = [[IADBPersistence alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"airportsdb" ofType:@"sqlite"]];
    }
    return _persistence;
}

+(void) setPersistencePath:(NSString *) path {
    _persistence = [[IADBPersistence alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"airportsdb" ofType:@"sqlite"]];
}

+(NSManagedObjectContext *) managedObjectContext {
    return [[self persistence] managedObjectContext];
}

+(NSInteger) countAll {
    NSError *error;
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:[self description]];
    NSUInteger count = [[IADBModel managedObjectContext] countForFetchRequest:fetch error:&error];
    NSAssert3(!error, @"Unhandled error counting in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
    return count;
}

+(Airport *) findByAirportId:(int32_t) airportId {
    
    NSManagedObjectContext *context = [IADBModel managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self description] inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(airportId = %d)",airportId];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *airports = [context executeFetchRequest:request error:&error];
    
    NSAssert3(airports, @"Unhandled error removing file in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
    
    if (!airports || airports.count == 0) { return nil; }
    if (airports.count > 1 ) { NSLog(@"WARNING: more than 1 %@ found with id %d",[self description],airportId); }
    
    return airports[0];
}

+(NSArray *) findAllByAirportId:(int32_t) airportId {
    
    NSManagedObjectContext *context = [IADBModel managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self description] inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(airportId = %d)",airportId];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    NSAssert3(objects, @"Unhandled error removing file in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
    
    return objects;
}

@end
