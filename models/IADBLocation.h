//
//  IADBLocation.h
//  airportsdb
//
//  Created by Christopher Hobbs on 6/11/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "IADBModel.h"

@class IADBCenteredArray;

@interface IADBLocation : IADBModel

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, retain, readonly) CLLocation * location;

+(IADBCenteredArray *) findNear:(CLLocation *) location withinNM:(CLLocationDistance) distance;
+(IADBCenteredArray *) findNear:(CLLocation *) location withinNM:(CLLocationDistance) distance withTypes:(NSArray *) types;
+(IADBLocation *) findByIdentifier:(NSString *) identifier;
+(IADBCenteredArray *) findAllByIdentifier:(NSString *) identifier;
+(IADBCenteredArray *) findAllByIdentifier:(NSString *) identifier withTypes:(NSArray *) types;
+(IADBCenteredArray *) findAllByIdentifierK:(NSString *) identifier withTypes:(NSArray *) types;
+(NSString *) predicateTypes:(NSArray *) types;
+(IADBCenteredArray *) findAllByPredicate:(NSPredicate *) predicate;
+(NSArray *) types;

-(CLLocationDistance) elevationForLocation;

@end
