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
@dynamic code;
@dynamic municipality;


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


// returns locations that begin with identifier with K prepended or the leading K removed
// or that begin with code
+(IADBCenteredArray *) findAllByIdentifierOrCode:(NSString *) identifier withTypes:(NSArray *) types {
    return [self findAllByIdentifierOrCode:identifier orMunicipality:nil withTypes:types];
}


+(IADBCenteredArray *) findAllByIdentifierOrCodeOrMunicipality:(NSString *) identifier withTypes:(NSArray *) types {
    return [self findAllByIdentifierOrCode:identifier orMunicipality:identifier withTypes:types];
}

+(IADBCenteredArray *) findAllByIdentifierOrCode:(NSString *) identifier orMunicipality:(NSString *) municipality withTypes:(NSArray *) types {
    if(!identifier || identifier.length == 0) { return [[IADBCenteredArray alloc] init]; }
    
    NSString *identifierB;
    if( identifier.length >= 2 && [[identifier uppercaseString] hasPrefix:@"K"] ) {
        //allow "KCVH" to find CVH
        identifierB = [identifier substringFromIndex:1]; // strip off K at beginning
    } else {
        identifierB = [NSString stringWithFormat:@"K%@",identifier]; // add K to beginning
    }
    
    return [self findAllByIdentifiers:@[identifier, identifierB] orCode:identifier orMunicipality:municipality withTypes:types];
}

+(IADBCenteredArray *) findAllByIdentifiers:(NSArray *) identifiers orCode:(NSString *) code orMunicipality:(NSString *) municipality withTypes:(NSArray *) types {
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:3];
    NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:3];
    
    if( !identifiers ) { identifiers = @[]; }
    for ( NSString *identifier in identifiers ) {
        if ( identifier.length > 0) {
            [predicates addObject: @"(identifier BEGINSWITH[c] %@)"];
            [arguments addObject: identifier];
        }
    }
    
    if ( code && code.length > 0) {
        [predicates addObject: @"(code BEGINSWITH[c] %@)"];
        [arguments addObject: code];
    }
    
    if ( municipality && municipality.length > 0) {
        [predicates addObject: @"(municipality BEGINSWITH[c] %@)"];
        [arguments addObject: municipality];
    }
    
    if( predicates.count == 0) {
        // no inputs results in no outputs
        return [[IADBCenteredArray alloc] init];
    }
    
    NSString *predicateString = [predicates componentsJoinedByString:@" or "];
    
    if (types) {
        predicateString = [NSString stringWithFormat:@"(%@) AND (%@)",predicateString,[self predicateTypes:types]];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString argumentArray:arguments];
    return [self findAllByPredicate:predicate];
    
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

-(NSDictionary *) asDictionary {
    return @{@"identifier": self.identifier,
             @"name": self.name,
             @"type": self.type,
             @"latitude": [NSNumber numberWithDouble:self.latitude],
             @"longitude": [NSNumber numberWithDouble:self.latitude],
             @"elevationFeet": self.elevationFeet
             };
}

@end
