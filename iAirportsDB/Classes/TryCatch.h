//
//  TryCatch.h
//  iAirportsDB_Example
//
//  Created by Christopher Hobbs on 4/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

#ifndef TryCatch_h
#define TryCatch_h

@interface TryCatch : NSObject

+ (BOOL)tryBlock:(void(^)(void))tryBlock error:(NSError **)error;

@end

#endif /* TryCatch_h */
