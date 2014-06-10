//
//  AirportArray.m
//  descent
//
//  Created by Christopher Hobbs on 1/28/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "IADBCenteredArray.h"
#import "IADBAirport.h"

#define METERS_PER_NM (1852.0)

@implementation IADBCenteredArray {
    NSMutableArray *_array;
}

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


-(void) setArray:(NSArray *) a {
    [_array setArray:a];
}

-(void) sortByCenter:(CLLocation *) center {
    [_array sortUsingComparator: ^(IADBAirport *a, IADBAirport *b) {
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

- (void)removeObjectsUsingBlock:(BOOL (^)(IADBAirport *airport))block {
    for( NSInteger i = _array.count - 1; i >= 0; i--) {
        if (block(_array[i])) {
            [_array removeObjectAtIndex:i];
        }
    }
}

-(void) excludeOutsideNM:(CLLocationDistance) nm fromCenter:(CLLocation *) center {
    if( !center || !_array) {return;}
    CLLocationDistance m = nm * METERS_PER_NM;
//    for( NSInteger i = _array.count - 1; i >= 0; i--) {
//        CLLocationDistance distance = [center distanceFromLocation:((Airport *) _array[i]).location];
//        if ( distance > m) {
//            [_array removeObjectAtIndex:i];
//        }
//    }
    [self removeObjectsUsingBlock:^BOOL(IADBAirport *airport) {
        CLLocationDistance distance = [center distanceFromLocation:airport.location];
        return distance > m;
    }];
}

-(void) excludeSoftSurface {
    [self removeObjectsUsingBlock:^BOOL(IADBAirport *airport) {
        return ![airport hasHardRunway];
    }];
}

-(void) excludeRunwayShorterThan:(NSInteger) feet {
    [self removeObjectsUsingBlock:^BOOL(IADBAirport *airport) {
        //NSLog(@"%@ %ld",airport,(long) [airport longestRunwayFeet]);
        return [airport longestRunwayFeet] < feet;
    }];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Center: %@, Airports: %@",_center, [_array description]];
}

@end
