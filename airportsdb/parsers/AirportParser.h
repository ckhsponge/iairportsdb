//
//  AirportParser.h
//  descent
//
//  Created by Christopher Hobbs on 1/26/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"
#import "CsvParser.h"

@class IADBAirport;

@interface AirportParser : CsvParser
@property (atomic, strong) NSMutableSet *types;

@end
