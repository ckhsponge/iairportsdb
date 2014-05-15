//
//  Airport.m
//  descent
//
//  Created by Christopher Hobbs on 1/26/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "Airport.h"
#import "IADBPersistence.h"
#import "IADBModel.h"
#import "Frequency.h"
#import "Runway.h"

@implementation Airport

@dynamic latitude;
@dynamic longitude;
@dynamic name;
@dynamic elevationFeet;
@dynamic identifier;
@dynamic airportId;
@dynamic type;
//@dynamic frequencies;

#define METERS_PER_NM (1852.0)
#define METERS_PER_KTS (METERS_PER_NM/3600.0)
#define NM(x) (round(x/(METERS_PER_NM)))
#define NM_PER_LATITUDE 60.0

#define LATITUDE_DEGREES_FROM_NM(nm) ((nm)/NM_PER_LATITUDE)
#define LONGITUDE_DEGREES_FROM_NM(nm,latitude) ((nm)/(NM_PER_LATITUDE*cos((latitude)*M_PI/180.0)))

#define FEET_PER_METER (3.28084)

#define BOUND_360(x) ((x < 0.0 ? x + 360.0 : x) > 360.0 ? x - 360.0 : x)

@synthesize location = _location;
@synthesize frequencies = _frequencies;
@synthesize runways = _runways;

//returns airports near a location sorted by distance
+(AirportArray *) findNear:(CLLocation *) location withinNM:(CLLocationDistance) distance {
    return [Airport findNear:location withinNM:distance withTypes:@[AIRPORT_TYPE_LARGE,
                                                                    AIRPORT_TYPE_MEDIUM,
                                                                    AIRPORT_TYPE_SMALL]];
}

+(AirportArray *) findNear:(CLLocation *) location withinNM:(CLLocationDistance) distance withTypes:(NSArray *) types {
    if( !types || types.count == 0) {
        AirportArray *airports = [[AirportArray alloc] init];
        airports.center = location;
        return airports;
    }
    
    // Set example predicate and sort orderings...
    CLLocationDegrees latitude = location.coordinate.latitude;
    CLLocationDegrees longitude = location.coordinate.longitude;
    
    latitude = MAX(MIN(latitude, 89.0), -89.0); //don't allow calculations at the poles or there will be divide-by-zero errors
    
    CLLocationDistance degreesLatitude = LATITUDE_DEGREES_FROM_NM(distance); //approximate because earth is an ellipse
    CLLocationDistance degreesLongitude = LONGITUDE_DEGREES_FROM_NM(distance,latitude); //longitude degrees are smaller further from equator
    
    NSString *predicateString = @"(latitude < %lf) AND (latitude > %lf) AND (longitude < %lf) AND (longitude > %lf)";
    
    NSMutableArray *predicateTypes = [[NSMutableArray alloc] initWithCapacity:types.count];
    [types enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [predicateTypes addObject:[NSString stringWithFormat:@"(type = '%@')",obj]];
    }];
    predicateString = [NSString stringWithFormat:@"%@ AND (%@)",predicateString,[predicateTypes componentsJoinedByString:@" OR "]];
    
    //finds all airports within a box to take advantage of database indexes
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              predicateString,
                              latitude+degreesLatitude, latitude-degreesLatitude, longitude+degreesLongitude, longitude-degreesLongitude];
    AirportArray *airports = [Airport findAllByPredicate:predicate];
    airports.center = location;
    [airports excludeAirportsOutsideNM:distance fromCenter:airports.center]; //trims airports to be within circle i.e. distance
    [airports sortByCenter:airports.center];
    
    return airports;
}

+(AirportArray *) findAllByIdentifier:(NSString *) identifier {
    if(!identifier || identifier.length == 0) { return [[AirportArray alloc] init]; }
    if( identifier.length > 1 && [[identifier uppercaseString] hasPrefix:@"K"]) {
        //if identifier starts with K remove it because we will check with it later
        //this allows "KCVH" to find CVH
        identifier = [identifier substringFromIndex:1];
    }
    NSString *kidentifier = [NSString stringWithFormat:@"K%@",identifier];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"((identifier BEGINSWITH[c] %@) OR (identifier BEGINSWITH[c] %@)) AND (type contains 'airport')",identifier,kidentifier];
    return [Airport findAllByPredicate:predicate];
}

+(AirportArray *) findAllByPredicate:(NSPredicate *) predicate {
    NSManagedObjectContext *context = [IADBModel managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Airport" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    [request setPredicate:predicate];
    
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
    //                                        initWithKey:@"name" ascending:YES];
    //    [request setSortDescriptors:@[sortDescriptor]];
    
    NSLog(@"fetch: %@", request);
    
    NSError *error;
    AirportArray *airports = [[AirportArray alloc] initWithArray:[context executeFetchRequest:request error:&error]];
    
    NSAssert3(airports, @"Unhandled error removing file in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
    
    return airports;
}

+(NSArray *) types {
    return @[
             AIRPORT_TYPE_LARGE,
             AIRPORT_TYPE_MEDIUM,
             AIRPORT_TYPE_SMALL,
             AIRPORT_TYPE_SEAPLANE,
             AIRPORT_TYPE_HELIPORT,
             AIRPORT_TYPE_BALLOONPORT,
             AIRPORT_TYPE_CLOSED
             ];
}

-(NSArray *) frequencies {
    if( !_frequencies ) {
        _frequencies = [Frequency findAllByAirportId:self.airportId];
    }
    return _frequencies;
}

-(NSArray *) runways {
    if( !_runways ) {
        _runways = [Runway findAllByAirportId:self.airportId];
        for (Runway *runway in _runways) {
            runway.airport = self;
        }
    }
    return _runways;
}

-(BOOL) hasRunways {
    return self.runways && self.runways.count > 0;
}

-(NSInteger) longestRunwayFeet {
    NSInteger length = -1;
    for( Runway *runway in self.runways ) {
        length = MAX(length, runway.lengthFeet);
    }
    return length;
}

-(BOOL) hasHardRunway {
    for( Runway *runway in self.runways ) {
        if ([runway isHard]) {
            return YES;
        }
    }
    return NO;
}

//don't trust the altitude
-(CLLocation *) location {
    if( !_location ) {
        CLLocationDistance altitude = self.elevationFeet ? [self.elevationFeet doubleValue] : 0.0;
        _location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.latitude, self.longitude) altitude:altitude horizontalAccuracy:0.0 verticalAccuracy:0.0 timestamp:[NSDate date]];
    }
    return _location;
}

-(NSString *) klessIdentifier {
    if( !self.identifier ) { return @""; }
    if( [[[self.identifier substringToIndex:1] uppercaseString] isEqualToString:@"K"] ) {
        return [self.identifier substringFromIndex:1];
    }
    return self.identifier;
}

-(NSString *) title {
    return [NSString stringWithFormat:@"%@: %@",self.identifier,self.name];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"%@ %@ %lf %lf %@ <%@>", self.identifier, self.name, self.latitude, self.longitude, self.elevationFeet, self.type];
}
@end
