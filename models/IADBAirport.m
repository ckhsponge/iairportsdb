//
//  Airport.m
//  descent
//
//  Created by Christopher Hobbs on 1/26/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "IADBAirport.h"
#import "IADBPersistence.h"
#import "IADBModel.h"
#import "IADBFrequency.h"
#import "IADBRunway.h"
#import "IADBConstants.h"

@implementation IADBAirport

@dynamic airportId;
//@dynamic frequencies;


@synthesize frequencies = _frequencies;
@synthesize runways = _runways;

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

+(IADBAirport *) findByAirportId:(int32_t) airportId {
    
    NSManagedObjectContext *context = [IADBModel managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IADBAirport" inManagedObjectContext:context];
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

-(NSArray *) frequencies {
    if( !_frequencies ) {
        _frequencies = [IADBFrequency findAllByAirportId:self.airportId];
    }
    return _frequencies;
}

-(NSArray *) runways {
    if( !_runways ) {
        _runways = [IADBRunway findAllByAirportId:self.airportId];
        for (IADBRunway *runway in _runways) {
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
    for( IADBRunway *runway in self.runways ) {
        if (runway.closed) {
            continue;
        }
        length = MAX(length, runway.lengthFeet);
    }
    return length;
}

-(IADBRunway *) longestRunway {
    IADBRunway *max = nil;
    for( IADBRunway *runway in self.runways ) {
        if (!max || (max.lengthFeet < runway.lengthFeet) || (max.lengthFeet == runway.lengthFeet && max.widthFeet < runway.widthFeet)) {
            if (!runway.closed) {
                max = runway;
            }
        }
    }
    return max;
}

-(BOOL) hasHardRunway {
    for( IADBRunway *runway in self.runways ) {
        if ([runway isHard] && !runway.closed) {
            return YES;
        }
    }
    return NO;
}

-(IADBFrequency *) frequencyForName:(NSString *) name {
    for (IADBFrequency *f in [self frequencies]) {
        NSString *n = f.name;
        if ([name isEqual:n]) {
            return f;
        }
    }
    return nil;
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
