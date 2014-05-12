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

#define INDEX_ID 0
#define INDEX_AIRPORT_ID 1
#define INDEX_IDENTIFIER 2
#define INDEX_LENGTH 3
#define INDEX_WIDTH 4
#define INDEX_SURFACE 5
#define INDEX_LIGHTED 6
#define INDEX_CLOSED 7
#define INDEX_LE_IDENTIFIER 8
#define INDEX_HEADING 12
#define INDEX_HE_IDENTIFIER 14

@implementation RunwayParser

-(NSString *) fileName {
    return @"runways";
}

-(NSString *) entityName {
    return @"Runway";
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)index {
    if( !self.surfaces) {self.surfaces = [[NSMutableSet alloc] init];}
    //NSLog(@"%@ %ld",field,(long) index);
    Runway *runway = (Runway *) self.managedObject;
    if( !runway) {return;}
    field = [Parser unquote:field];
    BOOL fieldEmpty = !field || field.length == 0;
    if( fieldEmpty ) { return; }
    Airport *airport;
    switch (index) {
        case INDEX_AIRPORT_ID:
            runway.airportId = (int32_t) [field integerValue];
            airport = [Airport findByAirportId:runway.airportId];
            if( !airport ) { NSLog(@"WARNING: No airport %d", runway.airportId); }
            //runway.airport = airport;
            break;
        case INDEX_LE_IDENTIFIER:
            runway.identifierA = field;
            break;
        case INDEX_HE_IDENTIFIER:
            runway.identifierB = field;
            break;
        case INDEX_SURFACE:
            runway.surface = field;
            [self.surfaces addObject:field];
            break;
        case INDEX_LENGTH:
            runway.lengthFeet = [field integerValue];
            break;
        case INDEX_WIDTH:
            runway.widthFeet = [field integerValue];
            break;
        case INDEX_HEADING:
            runway.headingTrue = [field floatValue];
            if( runway.headingTrue < 0.0 ) { NSLog(@"WARNING: runway heading: %f %d", runway.headingTrue, runway.airportId); }
            break;
            
        default:
            break;
    }
}
@end
