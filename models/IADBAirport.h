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
#import "IADBLocation.h"
#import "IADBLocationElevation.h"
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

@interface IADBAirport : IADBLocationElevation

@property (nonatomic) int32_t airportId;
@property (nonatomic, retain, readonly) NSArray * frequencies;
@property (nonatomic, retain, readonly) NSArray * runways;

+(IADBAirport *) findByAirportId:(int32_t) airportId;
-(NSString *) title;
-(NSString *) klessIdentifier;
-(BOOL) hasRunways;
-(NSInteger) longestRunwayFeet;
-(BOOL) hasHardRunway;
-(IADBRunway *) longestRunway;
-(IADBFrequency *) frequencyForName:(NSString *) name;
-(NSDictionary *) asDictionary;
@end