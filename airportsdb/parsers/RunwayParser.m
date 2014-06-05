//
//  RunwayParser.m
//  airportsdb
//
//  Created by Christopher Hobbs on 2/18/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "RunwayParser.h"
#import "Runway.h"
#import "Airport.h"

//"id","airport_ref","airport_ident","length_ft","width_ft","surface","lighted","closed","le_ident","le_latitude_deg","le_longitude_deg","le_elevation_ft","le_heading_degT","le_displaced_threshold_ft","he_ident","he_latitude_deg","he_longitude_deg","he_elevation_ft","he_heading_degT","he_displaced_threshold_ft",

//#define HEADER_ID 0
#define HEADER_AIRPORT_ID @"airport_ref"
#define HEADER_IDENTIFIER @"airport_ident"
#define HEADER_LENGTH @"length_ft"
#define HEADER_WIDTH @"width_ft"
#define HEADER_SURFACE @"surface"
//#define HEADER_LIGHTED 6
//#define HEADER_CLOSED 7
#define HEADER_LE_IDENTIFIER @"le_ident"
#define HEADER_HEADING @"le_heading_degT"
#define HEADER_HE_IDENTIFIER @"he_ident"
#define HEADER_CLOSED @"closed"

@implementation RunwayParser

-(NSString *) fileName {
    return @"runways";
}

-(NSString *) entityName {
    return @"Runway";
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field forColumn:(NSString *) column {
    if (!field || field.length == 0) {
        return;
    }
    if( !self.surfaces) {self.surfaces = [[NSMutableSet alloc] init];}
    //NSLog(@"%@ %ld",field,(long) index);
    Runway *runway = (Runway *) self.managedObject;
    if( !runway) {return;}
    
    Airport *airport;
    if ( [HEADER_AIRPORT_ID isEqualToString:column] ) {
        runway.airportId = (int32_t) [field integerValue];
        airport = [Airport findByAirportId:runway.airportId];
        if( !airport ) { NSLog(@"WARNING: No airport %d", runway.airportId); }
        //runway.airport = airport;
    } else if ( [HEADER_LE_IDENTIFIER isEqualToString:column] ) {
        runway.identifierA = field;
    } else if ( [HEADER_HE_IDENTIFIER isEqualToString:column] ) {
        runway.identifierB = field;
    } else if ( [HEADER_SURFACE isEqualToString:column] ) {
        runway.surface = field;
        [self.surfaces addObject:field];
    } else if ( [HEADER_LENGTH isEqualToString:column] ) {
        runway.lengthFeet = [field integerValue];
    } else if ( [HEADER_WIDTH isEqualToString:column] ) {
        runway.widthFeet = [field integerValue];
    } else if ( [HEADER_HEADING isEqualToString:column] ) {
        runway.headingTrue = [field floatValue];
        if( runway.headingTrue < 0.0 ) { NSLog(@"WARNING: runway heading: %f %d", runway.headingTrue, runway.airportId); }
    } else if ( [HEADER_CLOSED isEqualToString:column] ) {
        runway.closed = [@"1" isEqualToString:field];
    }
}
@end
