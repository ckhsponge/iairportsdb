//
//  AirportParser.h
//  descent
//
//  Created by Christopher Hobbs on 1/26/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"
#import "Parser.h"

@class IADBAirport;

@interface AirportParser : Parser
@property (atomic, strong) NSMutableSet *types;

@end
