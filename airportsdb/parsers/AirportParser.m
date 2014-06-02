//
//  AirportParser.m
//  descent
//
//  Created by Christopher Hobbs on 1/26/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "AirportParser.h"
#import "AppDelegate.h"
#import "Airport.h"
#import <CoreData/CoreData.h>

#define INDEX_ID 0
#define INDEX_IDENTIFIER 12
#define INDEX_TYPE 2
#define INDEX_NAME 3
#define INDEX_LATITUDE 4
#define INDEX_LONGITUDE 5
#define INDEX_ELEVATION_FEET 6

@implementation AirportParser

-(NSString *) fileName {
    return @"airports";
}

-(NSString *) entityName {
    return @"Airport";
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)index {
    if( !self.types) {self.types = [[NSMutableSet alloc] init];}
    //NSLog(@"%@ %ld",field,(long) index);
    Airport *airport = (Airport *) self.managedObject;
    if( !airport) {return;}
    field = [Parser unquote:field];
    BOOL fieldEmpty = !field || field.length == 0;
    if( fieldEmpty ) { return; }
    switch (index) {
        case INDEX_ID:
            airport.airportId = (int32_t) [field integerValue];
            break;
        case INDEX_IDENTIFIER:
            airport.identifier = field;
            break;
        case INDEX_TYPE:
            airport.type = field;
            [self.types addObject:field];
            break;
        case INDEX_NAME:
            airport.name = field;
            break;
        case INDEX_LATITUDE:
            airport.latitude = [field doubleValue];
            break;
        case INDEX_LONGITUDE:
            airport.longitude = [field doubleValue];
            break;
        case INDEX_ELEVATION_FEET:
            airport.elevationFeet = [[NSNumber alloc] initWithInteger:[field integerValue]];
            break;
            
        default:
            break;
    }
}

@end
