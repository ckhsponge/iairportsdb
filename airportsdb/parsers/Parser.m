//
//  Parser.m
//  airportsdb
//
//  Created by Christopher Hobbs on 6/14/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "Parser.h"
#import "IADBModel.h"

@implementation Parser

-(NSString *) entityName {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSUInteger) countEntities {
    NSError *error;
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    NSUInteger count = [[IADBModel managedObjectContext] countForFetchRequest:fetch error:&error];
    NSAssert3(!error, @"Unhandled error counting in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
    return count;
}

-(IADBPersistence *) persistence {
    return [IADBModel persistence];
}

@end
