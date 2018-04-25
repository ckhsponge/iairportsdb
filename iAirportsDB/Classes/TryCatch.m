//
//  TryCatch.m
//  iAirportsDB_Example
//
//  Created by Christopher Hobbs on 4/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TryCatch.h"

@implementation TryCatch

+ (BOOL)tryBlock:(void(^)(void))tryBlock error:(NSError **)error
{
    @try {
        tryBlock ? tryBlock() : nil;
    }
    @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:@"net.toonces.iairportsdb"
                                         code:42
                                     userInfo:@{NSLocalizedDescriptionKey: exception.name}];
        }
        return NO;
    }
    return YES;
}

@end

