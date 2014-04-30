//
//  AirportArray.m
//  descent
//
//  Created by Christopher Hobbs on 1/28/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "AirportArray.h"
#import "Airport.h"

#define METERS_PER_NM (1852.0)

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


-(void) setAirports:(NSArray *) a {
    [self.array setArray:a];
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

-(void) excludeAirportsOutsideNM:(CLLocationDistance) nm fromCenter:(CLLocation *) center {
    if( !center || !_array) {return;}
    CLLocationDistance m = nm * METERS_PER_NM;
    for( NSInteger i = _array.count - 1; i >= 0; i--) {
        CLLocationDistance distance = [center distanceFromLocation:((Airport *) _array[i]).location];
        if ( distance > m) {
            [_array removeObjectAtIndex:i];
        }
    }
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Center: %@, Airports: %@",_center, [_array description]];
}

@end
