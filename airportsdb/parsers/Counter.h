//
//  Counter.h
//  airportsdb
//
//  Created by Christopher Hobbs on 2/23/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

@interface Counter : NSObject <CHCSVParserDelegate>

-(void) count;

@end
