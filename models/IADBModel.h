//
//  NrstModel.h
//  airportsdb
//
//  Created by Christopher Hobbs on 2/18/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <CoreData/CoreData.h>

@class IADBAirport;
@class IADBPersistence;

@interface IADBModel : NSManagedObject

@property (nonatomic,readonly) BOOL isBlank;

+(void) setPersistencePath:(NSString *) path;
+(IADBPersistence *) persistence;
+(NSManagedObjectContext *) managedObjectContext;
+(NSInteger) countAll;
+(NSArray *) findAllByAirportId:(int32_t) airportId;
@end
