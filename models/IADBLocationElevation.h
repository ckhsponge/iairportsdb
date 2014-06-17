//
//  IADBLocationElevation.h
//  airportsdb
//
//  Created by Christopher Hobbs on 6/17/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "IADBLocation.h"

@interface IADBLocationElevation : IADBLocation

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * elevationFeet;

@end
