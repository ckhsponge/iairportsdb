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
#import "AirportArray.h"

@class Frequency;

@interface Airport : IADBModel

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

+(AirportArray *) findNear:(CLLocation *) location withinNM:(CLLocationDistance) distance;
+(AirportArray *) findAllByIdentifier:(NSString *) identifier;
-(NSString *) title;
@end

@interface Airport (CoreDataGeneratedAccessors)

- (void)addFrequenciesObject:(Frequency *)value;
- (void)removeFrequenciesObject:(Frequency *)value;
- (void)addFrequencies:(NSSet *)values;
- (void)removeFrequencies:(NSSet *)values;

@end