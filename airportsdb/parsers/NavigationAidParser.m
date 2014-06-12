//
//  NavigationAidParser.m
//  airportsdb
//
//  Created by Christopher Hobbs on 6/11/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "NavigationAidParser.h"
#import "IADBNavigationAid.h"

@implementation NavigationAidParser

//"id","filename","ident","name","type","frequency_khz","latitude_deg","longitude_deg","elevation_ft","iso_country","dme_frequency_khz","dme_channel","dme_latitude_deg","dme_longitude_deg","dme_elevation_ft","slaved_variation_deg","magnetic_variation_deg","usageType","power","associated_airport",

#define HEADER_ID @"id"
#define HEADER_IDENTIFIER @"ident"
#define HEADER_NAME @"name"
#define HEADER_TYPE @"type"
#define HEADER_LATITUDE @"latitude_deg"
#define HEADER_LONGITUDE @"longitude_deg"
#define HEADER_ELEVATION_FEET @"elevation_ft"
#define HEADER_KHZ @"frequency_khz"
#define HEADER_DME_KHZ @"dme_frequency_khz"

-(NSString *) fileName {
    return @"navaids";
}

-(NSString *) entityName {
    return @"IADBNavigationAid";
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field forColumn:(NSString *) column {
    if (!field || field.length == 0) {
        return;
    }
    if( !self.types) {self.types = [[NSMutableSet alloc] init];}
    IADBNavigationAid *nav = (IADBNavigationAid *) self.managedObject;
    if( !nav) {return;}
    
    if ( [HEADER_IDENTIFIER isEqualToString:column] ) {
        nav.identifier = field;
    } else if ( [HEADER_TYPE isEqualToString:column] ) {
        nav.type = field;
        [self.types addObject:field];
    } else if ( [HEADER_NAME isEqualToString:column] ) {
        nav.name = field;
    } else if ( [HEADER_LATITUDE isEqualToString:column] ) {
        nav.latitude = [field doubleValue];
    } else if ( [HEADER_LONGITUDE isEqualToString:column] ) {
        nav.longitude = [field doubleValue];
    } else if ( [HEADER_ELEVATION_FEET isEqualToString:column] ) {
        nav.elevationFeet = [[NSNumber alloc] initWithInteger:[field integerValue]];
    } else if ( [HEADER_KHZ isEqualToString:column] ) {
        nav.khz = [field intValue];
    } else if ( [HEADER_DME_KHZ isEqualToString:column] ) {
        nav.dmeKhz = [field intValue];
    }
}

@end
