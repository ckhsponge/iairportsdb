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

//"id","airport_ref","airport_ident","type","description","frequency_mhz"

//#define HEADER_ID @"id"
#define HEADER_AIRPORT_ID @"airport_ref"
//#define HEADER_IDENTIFIER @"airport_ident"
#define HEADER_TYPE @"type"
#define HEADER_NAME @"description"
#define HEADER_MHZ @"frequency_mhz"

@implementation FrequencyParser

-(NSString *) fileName {
    return @"airport-frequencies";
}

-(NSString *) entityName {
    return @"Frequency";
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field forColumn:(NSString *) column {
    if (!field || field.length == 0) {
        return;
    }
    Frequency *frequency = (Frequency *) self.managedObject;
    if( !frequency) {return;}

    Airport *airport;
    if ( [HEADER_AIRPORT_ID isEqualToString:column] ) {
            frequency.airportId = (int32_t) [field integerValue];
            airport = [Airport findByAirportId:frequency.airportId];
            if( !airport ) { NSLog(@"WARNING: No airport %d", frequency.airportId); }
        //frequency.airport = airport;
    } else if ( [HEADER_TYPE isEqualToString:column] ) {
            frequency.type = field;
    } else if ( [HEADER_NAME isEqualToString:column] ) {
            frequency.name = field;
    } else if ( [HEADER_MHZ isEqualToString:column] ) {
            frequency.mhz = [field doubleValue];
    }
}
@end
