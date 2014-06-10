//
//  AirportParser.m
//  descent
//
//  Created by Christopher Hobbs on 1/26/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "AirportParser.h"
#import "AppDelegate.h"
#import "IADBAirport.h"
#import <CoreData/CoreData.h>

//"id","ident","type","name","latitude_deg","longitude_deg","elevation_ft","continent","iso_country","iso_region","municipality","scheduled_service","gps_code","iata_code","local_code","home_link","wikipedia_link","keywords"

#define HEADER_ID @"id"
#define HEADER_IDENTIFIER @"ident"
#define HEADER_GPS_CODE @"gps_code"
#define HEADER_TYPE @"type"
#define HEADER_NAME @"name"
#define HEADER_LATITUDE @"latitude_deg"
#define HEADER_LONGITUDE @"longitude_deg"
#define HEADER_ELEVATION_FEET @"elevation_ft"


@implementation AirportParser

-(NSString *) fileName {
    return @"airports";
}

-(NSString *) entityName {
    return @"IADBAirport";
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field forColumn:(NSString *) column {
    if (!field || field.length == 0) {
        return;
    }
    if( !self.types) {self.types = [[NSMutableSet alloc] init];}
    IADBAirport *airport = (IADBAirport *) self.managedObject;
    if( !airport) {return;}

    if ( [HEADER_ID isEqualToString:column] ) {
        airport.airportId = (int32_t) [field integerValue];
    } else if ( [HEADER_IDENTIFIER isEqualToString:column] ) {
        airport.identifier = field;
    } else if ( [HEADER_GPS_CODE isEqualToString:column] ) {
        airport.identifier = field; //use gps code if it exists
    } else if ( [HEADER_TYPE isEqualToString:column] ) {
        airport.type = field;
        [self.types addObject:field];
    } else if ( [HEADER_NAME isEqualToString:column] ) {
        airport.name = field;
    } else if ( [HEADER_LATITUDE isEqualToString:column] ) {
        airport.latitude = [field doubleValue];
    } else if ( [HEADER_LONGITUDE isEqualToString:column] ) {
        airport.longitude = [field doubleValue];
    } else if ( [HEADER_ELEVATION_FEET isEqualToString:column] ) {
        airport.elevationFeet = [[NSNumber alloc] initWithInteger:[field integerValue]];
    }
}

@end
