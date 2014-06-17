//
//  IADBFix.m
//  airportsdb
//
//  Created by Christopher Hobbs on 6/15/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "IADBFix.h"


@implementation IADBFix

-(NSString *) description {
    return [NSString stringWithFormat:@"%@ %3.6lf,%3.6lf",self.identifier,self.latitude,self.longitude];
}
@end
