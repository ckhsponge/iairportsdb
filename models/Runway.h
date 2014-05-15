//
//  Runway.h
//  airportsdb
//
//  Created by Christopher Hobbs on 2/18/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Airport.h"
#import "IADBModel.h"

@interface Runway : IADBModel

@property (nonatomic) int32_t airportId;
@property (nonatomic) int16_t lengthFeet;
@property (nonatomic) int16_t widthFeet;
@property (nonatomic, retain) NSString * identifierA;
@property (nonatomic, retain) NSString * identifierB;
@property (nonatomic, retain) NSString * surface;
@property (nonatomic) float_t headingTrue; //a negative value means invalid
@property (nonatomic, retain) Airport *airport;

-(CLLocationDirection) headingMagneticWithDeviation:(CLLocationDirection) deviation;
-(CLLocationDirection) headingMagneticOrGuessWithDeviation:(CLLocationDirection) deviation;
-(CLLocationDirection) identifierDegrees;
-(BOOL) isHard;

@end
