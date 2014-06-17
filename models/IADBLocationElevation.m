//
//  IADBLocationElevation.m
//  airportsdb
//
//  Created by Christopher Hobbs on 6/17/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "IADBLocationElevation.h"
#import "IADBConstants.h"

@implementation IADBLocationElevation

@dynamic name;
@dynamic type;
@dynamic elevationFeet;

//meters
-(CLLocationDistance) elevationForLocation {
    //[self respondsToSelector:@selector(elevationFeet)]
    return self.elevationFeet ? [self.elevationFeet doubleValue]/FEET_PER_METER : [super elevationForLocation];
}

@end
