//
//  RunwayParser.h
//  airportsdb
//
//  Created by Christopher Hobbs on 2/18/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "CsvParser.h"

@interface RunwayParser : CsvParser
@property (atomic, strong) NSMutableSet *surfaces;

@end
