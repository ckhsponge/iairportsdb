//
//  NrstModel.h
//  airportsdb
//
//  Created by Christopher Hobbs on 2/18/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Airport;
@class IADBPersistence;

@interface IADBModel : NSManagedObject

+(void) setPersistencePath:(NSString *) path;
+(IADBPersistence *) persistence;
+(NSManagedObjectContext *) managedObjectContext;
+(NSInteger) countAll;
+(Airport *) findByAirportId:(int32_t) airportId;
+(NSArray *) findAllByAirportId:(int32_t) airportId;
@end
