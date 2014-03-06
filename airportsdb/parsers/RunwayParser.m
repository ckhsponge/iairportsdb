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
#define INDEX_HE_IDENTIFIER 14

@implementation RunwayParser

-(NSString *) fileName {
    return @"runways";
}

-(NSString *) entityName {
    return @"Runway";
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)index {
    //NSLog(@"%@ %ld",field,(long) index);
    Runway *runway = (Runway *) self.managedObject;
    if( !runway) {return;}
    field = [Parser unquote:field];
    BOOL fieldEmpty = !field || field.length == 0;
    if( fieldEmpty ) { return; }
    Airport *airport;
    switch (index) {
        case INDEX_AIRPORT_ID:
            runway.airportId = [field integerValue];
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
            break;
        case INDEX_LENGTH:
            runway.lengthFeet = [field integerValue];
            break;
        case INDEX_WIDTH:
            runway.widthFeet = [field integerValue];
            break;
            
        default:
            break;
    }
}
@end
