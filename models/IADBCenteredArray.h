//
//  AirportArray.h
//  descent
//
//  Created by Christopher Hobbs on 1/28/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface IADBCenteredArray : NSObject

@property (nonatomic, retain) CLLocation * center;
@property (nonatomic, retain, readonly) NSArray * array;
@property (nonatomic, readonly) NSUInteger count;

-(id) initWithArray:(NSArray *) a;

-(void) sort;
-(void) sortByCenter:(CLLocation *) center;
-(void) excludeOutsideNM:(CLLocationDistance) nm fromCenter:(CLLocation *) center;
-(void) excludeSoftSurface;
-(void) excludeRunwayShorterThan:(NSInteger) feet;
-(void) setArray:(NSArray *) a;
-(void) addCenteredArray:(IADBCenteredArray *) array;
@end
