//
//  NavigationAidParser.h
//  airportsdb
//
//  Created by Christopher Hobbs on 6/11/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "CsvParser.h"

@interface NavigationAidParser : CsvParser

@property (atomic, strong) NSMutableSet *types;

@end
