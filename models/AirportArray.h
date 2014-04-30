//
//  AirportArray.h
//  descent
//
//  Created by Christopher Hobbs on 1/28/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AirportArray : NSObject

@property (nonatomic, retain) CLLocation * center;
@property (nonatomic, retain, readonly) NSMutableArray * array;

-(id) initWithArray:(NSArray *) a;

-(void) sortByCenter:(CLLocation *) center;
-(void) excludeAirportsOutsideNM:(CLLocationDistance) nm fromCenter:(CLLocation *) center;
-(void) setAirports:(NSArray *) a;

@end
