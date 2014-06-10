//
//  Airport.h
//  descent
//
//  Created by Christopher Hobbs on 1/26/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

#import "IADBModel.h"
#import "IADBCenteredArray.h"

#define AIRPORT_TYPE_LARGE @"large_airport"
#define AIRPORT_TYPE_MEDIUM @"medium_airport"
#define AIRPORT_TYPE_SMALL @"small_airport"
#define AIRPORT_TYPE_SEAPLANE @"seaplane_base"
#define AIRPORT_TYPE_HELIPORT @"heliport"
#define AIRPORT_TYPE_BALLOONPORT @"balloonport"
#define AIRPORT_TYPE_CLOSED @"closed"

@class IADBFrequency;
@class IADBRunway;

@interface IADBAirport : IADBModel

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * elevationFeet;
@property (nonatomic) int32_t airportId;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) CLLocation * location;
@property (nonatomic, retain, readonly) NSArray * frequencies;
@property (nonatomic, retain, readonly) NSArray * runways;

+(IADBCenteredArray *) findNear:(CLLocation *) location withinNM:(CLLocationDistance) distance;
+(IADBCenteredArray *) findNear:(CLLocation *) location withinNM:(CLLocationDistance) distance withTypes:(NSArray *) types;
+(IADBAirport *) findByIdentifier:(NSString *) identifier;
+(IADBCenteredArray *) findAllByIdentifier:(NSString *) identifier;
+(IADBCenteredArray *) findAllByIdentifier:(NSString *) identifier withTypes:(NSArray *) types;
+(NSArray *) types;
-(NSString *) title;
-(NSString *) klessIdentifier;
-(BOOL) hasRunways;
-(NSInteger) longestRunwayFeet;
-(BOOL) hasHardRunway;
-(IADBRunway *) longestRunway;
-(IADBFrequency *) frequencyForName:(NSString *) name;
@end

@interface IADBAirport (CoreDataGeneratedAccessors)

- (void)addFrequenciesObject:(IADBFrequency *)value;
- (void)removeFrequenciesObject:(IADBFrequency *)value;
- (void)addFrequencies:(NSSet *)values;
- (void)removeFrequencies:(NSSet *)values;

@end