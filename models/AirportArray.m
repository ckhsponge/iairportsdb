//
//  AirportArray.m
//  descent
//
//  Created by Christopher Hobbs on 1/28/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "AirportArray.h"
#import "Airport.h"

@implementation AirportArray

-(id) init {
    if (self = [self initWithArray:[NSArray arrayWithObjects:nil]])
    {
    }
    return self;
}

-(id) initWithArray:(NSArray *) a {
    {
        if (self = [super init])
        {
            _array = [[NSMutableArray alloc] initWithArray:a];
            _center = nil;
        }
        return self;
    }
}

-(void) sortByCenter:(CLLocation *) center {
    [self.array sortUsingComparator: ^(Airport *a, Airport *b) {
        CLLocationDistance dist_a= [a.location distanceFromLocation: center];
        CLLocationDistance dist_b= [b.location distanceFromLocation: center];
        if ( dist_a < dist_b ) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ( dist_a > dist_b) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
}

@end
