//
//  IADBNavigationAid.m
//  airportsdb
//
//  Created by Christopher Hobbs on 6/11/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "IADBNavigationAid.h"


@implementation IADBNavigationAid

@dynamic khz;
@dynamic dmeKhz;

-(BOOL) isBlank {
    return ![self valueForKey:@"identifier"];
}

-(float) mhz {
    return self.khz/1000.0;
}

+(NSArray *) types {
    return @[
            NAVIGATION_AID_TYPE_VORTAC,
            NAVIGATION_AID_TYPE_NDB_DME,
            NAVIGATION_AID_TYPE_NDB,
            NAVIGATION_AID_TYPE_VOR_DME,
            NAVIGATION_AID_TYPE_DME,
            NAVIGATION_AID_TYPE_VOR,
            NAVIGATION_AID_TYPE_TACAN
             ];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"%@ %@ %lf %lf %@ <%@>", self.identifier, self.name, self.latitude, self.longitude, self.elevationFeet, self.type];
}
@end
