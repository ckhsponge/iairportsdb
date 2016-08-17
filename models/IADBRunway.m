//
//  Runway.m
//  airportsdb
//
//  Created by Christopher Hobbs on 2/18/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "IADBRunway.h"

@implementation IADBRunway

@dynamic airportId;
@dynamic lengthFeet;
@dynamic widthFeet;
@dynamic identifierA;
@dynamic identifierB;
@dynamic surface;
@dynamic headingTrue; //TRUE
@dynamic closed;

@synthesize airport;

#define HARD_SURFACES @[@"ASP",@"CON",@"PEM"]

static inline double withinZeroTo360(double degrees) {
    return (degrees - (360.0 * floor(degrees/360.0)));
}

//if headingDegrees is valid add the deviation, otherwise return -1
//CoreLocation doesn't provide deviation :(
-(CLLocationDirection) headingMagneticWithDeviation:(CLLocationDirection) deviation {
    return self.headingTrue >= 0.0 ? withinZeroTo360(self.headingTrue - deviation) : -1.0;
}

//if the runway headingDegrees is positive return that, otherwise use the identifier to guess degrees
-(CLLocationDirection) headingMagneticOrGuessWithDeviation:(CLLocationDirection) deviation {
    return self.headingTrue >= 0.0 ? [self headingMagneticWithDeviation:deviation] : [self identifierDegrees];
}

//guess the runway heading from the identifier e.g. 01R heads 10° and 04 or 4 heads 40°
//returns -1 if guessing fails
-(CLLocationDirection) identifierDegrees {
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    if (self.identifierA && self.identifierA.length >= 1 && [digits characterIsMember:[self.identifierA characterAtIndex:0]] ) {
        if (self.identifierA.length >= 2 && [digits characterIsMember:[self.identifierA characterAtIndex:1]]) {
            return [[self.identifierA substringToIndex:2] doubleValue]*10.0;
        } else {
            return [[self.identifierA substringToIndex:1] doubleValue]*10.0;
        }
    }
    return -1.0;
}

-(BOOL) isHard {
    NSString *surface = [self.surface uppercaseString];
    for(NSString *match in HARD_SURFACES) {
        if ([surface rangeOfString:match].location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"%@/%@ %dx%d %@ %f",self.identifierA,self.identifierB,self.lengthFeet,self.widthFeet,self.surface,self.headingTrue];
}
@end
