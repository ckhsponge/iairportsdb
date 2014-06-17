//
//  IADBNavigationAid.h
//  airportsdb
//
//  Created by Christopher Hobbs on 6/11/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IADBLocation.h"
#import "IADBLocationElevation.h"

#define NAVIGATION_AID_TYPE_VORTAC @"VORTAC"
#define NAVIGATION_AID_TYPE_NDB_DME @"NDB-DME"
#define NAVIGATION_AID_TYPE_NDB @"NDB"
#define NAVIGATION_AID_TYPE_VOR_DME @"VOR-DME"
#define NAVIGATION_AID_TYPE_DME @"DME"
#define NAVIGATION_AID_TYPE_VOR @"VOR"
#define NAVIGATION_AID_TYPE_TACAN @"TACAN"


@interface IADBNavigationAid : IADBLocationElevation

@property (nonatomic) int32_t khz;
@property (nonatomic,readonly) float mhz;
@property (nonatomic) int32_t dmeKhz;

@end
