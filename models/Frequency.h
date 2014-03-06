//
//  Frequency.h
//  airportsdb
//
//  Created by Christopher Hobbs on 2/17/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IADBModel.h"

@class Airport;

@interface Frequency : IADBModel

@property (nonatomic) int32_t airportId;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) float mhz;
//@property (nonatomic, retain) Airport *airport;

@end
