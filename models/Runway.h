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
@property (nonatomic) float_t headingDegrees; //degrees TRUE
//@property (nonatomic, retain) Airport *airport;

-(CLLocationDegrees) headingDegreesMagneticWithDeviation:(CLLocationDegrees) deviation;
-(CLLocationDegrees) headingDegreesMagneticOrGuessWithDeviation:(CLLocationDegrees) deviation;
-(CLLocationDegrees) identifierDegrees;

@end
