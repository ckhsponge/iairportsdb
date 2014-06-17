//
//  Parser.h
//  airportsdb
//
//  Created by Christopher Hobbs on 6/14/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IADBPersistence.h"

@interface Parser : NSObject {
    NSUInteger _recordNumber;
}

-(NSString *) entityName;
-(NSUInteger) countEntities;
-(IADBPersistence *) persistence;

@end
