//
//  FrequencyParser.m
//  airportsdb
//
//  Created by Christopher Hobbs on 2/18/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "FrequencyParser.h"
#import "Frequency.h"
#import "Airport.h"

#define INDEX_ID 0
#define INDEX_AIRPORT_ID 1
#define INDEX_IDENTIFIER 2
#define INDEX_TYPE 3
#define INDEX_NAME 4
#define INDEX_MHZ 5

@implementation FrequencyParser

-(NSString *) fileName {
    return @"airport-frequencies";
}

-(NSString *) entityName {
    return @"Frequency";
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)index {
    //NSLog(@"%@ %ld",field,(long) index);
    Frequency *frequency = (Frequency *) self.managedObject;
    if( !frequency) {return;}
    field = [Parser unquote:field];
    BOOL fieldEmpty = !field || field.length == 0;
    if( fieldEmpty ) { return; }
    Airport *airport;
    switch (index) {
        case INDEX_AIRPORT_ID:
            frequency.airportId = (int32_t) [field integerValue];
            airport = [Airport findByAirportId:frequency.airportId];
            if( !airport ) { NSLog(@"WARNING: No airport %d", frequency.airportId); }
            //frequency.airport = airport;
            break;
        case INDEX_TYPE:
            frequency.type = field;
            break;
        case INDEX_NAME:
            frequency.name = field;
            break;
        case INDEX_MHZ:
            frequency.mhz = [field doubleValue];
            break;
            
        default:
            break;
    }
}
@end
