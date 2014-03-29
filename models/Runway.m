//
//  Runway.m
//  airportsdb
//
//  Created by Christopher Hobbs on 2/18/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "Runway.h"

@implementation Runway

@dynamic airportId;
@dynamic lengthFeet;
@dynamic widthFeet;
@dynamic identifierA;
@dynamic identifierB;
@dynamic surface;
@dynamic headingDegrees; //TRUE

@synthesize airport;

static inline double withinZeroTo360(double degrees) {
    return (degrees - (360.0 * floor(degrees/360.0)));
}

//if headingDegrees is valid add the deviation, otherwise return -1
//CoreLocation doesn't provide deviation :(
-(CLLocationDegrees) headingMagneticWithDeviation:(CLLocationDegrees) deviation {
    return self.headingDegrees >= 0.0 ? withinZeroTo360(self.headingDegrees - deviation) : -1.0;
}

//if the runway headingDegrees is positive return that, otherwise use the identifier to guess degrees
-(CLLocationDegrees) headingMagneticOrGuessWithDeviation:(CLLocationDegrees) deviation {
    return self.headingDegrees >= 0.0 ? [self headingMagneticWithDeviation:deviation] : [self identifierDegrees];
}

//guess the runway heading from the identifier e.g. 01R heads ~10°
//returns -1 if guessing fails
-(CLLocationDegrees) identifierDegrees {
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    if (self.identifierA && [digits characterIsMember:[self.identifierA characterAtIndex:0]] && [digits characterIsMember:[self.identifierA characterAtIndex:1]]) {
        return [[self.identifierA substringToIndex:2] doubleValue]*10.0;
    }
    return -1.0;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"%@/%@ %dx%d %@ %f",self.identifierA,self.identifierB,self.lengthFeet,self.widthFeet,self.surface,self.headingDegrees];
}
@end
