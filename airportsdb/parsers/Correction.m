//
//  Correction.m
//  airportsdb
//
//  Created by Christopher Hobbs on 5/23/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "Correction.h"
#import "Airport.h"
#import "Frequency.h"
#import "IADBModel.h"
#import "IADBPersistence.h"
#import "AppConstants.h"

@implementation Correction

-(void) correct {
    [IADBModel setPersistencePath:[NSString stringWithFormat:LOCAL_DB_PATH,PROJECT_PATH]]; //writes to a local project file instead of the compiled documents path
    
    [self airportType];
    [self modifyFrequency];
    [self deleteFrequency];
    
    NSError *error;
    [[IADBModel managedObjectContext] save:&error];
    NSAssert3(!error, @"Unhandled error saving in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
    if( error ) {
        NSLog( @"WARNING: Could not save %@", [error localizedDescription]);
    }
}

-(void) airportType {
    NSDictionary *dict = @{@"8XS3":AIRPORT_TYPE_CLOSED, @"77T":AIRPORT_TYPE_CLOSED};
    [dict enumerateKeysAndObjectsUsingBlock:^(id identifier, id type, BOOL *stop) {
        Airport *airport = [Airport findByIdentifier:identifier];
        if (airport) {
            NSLog(@"%@ type %@ to %@",identifier,airport.type,type);
            airport.type = type;
        } else {
            NSLog(@"Airport not found: %@",identifier);
        }
    }];
}

-(void) modifyFrequency {
    NSArray *array = @[
                       @[@"KGRR",@"ATIS",@"type",@118.725],
                           @[@"KGRR",@"LANSING RDO",@"type",@122.25],
                           @[@"KGRR",@"GRAND RAPIDS APP/DEP N",@"type",@124.6],
                       @[@"KGRR",@"GRAND RAPIDS APP/DEP S",@"type",@128.4],
                       @[@"K08C",@"CTAF/UNICOM",@"type",@122.9]
                           ];
    for(NSArray *attributes in array) {
        NSString *identifier = attributes[0];
        Airport *airport = [Airport findByIdentifier:identifier];
        if (airport) {
            NSString *name = attributes[1];
            NSString *type = attributes[2];
            float mhz = [((NSNumber *) attributes[3]) floatValue];
            Frequency *f = [airport frequencyForName:name];
            if (f) {
                NSLog(@"Frequency modify: %@ %@,%@,%f to %f",identifier,name,f.type,f.mhz,mhz);
                //type is not updated but could be
                f.mhz = mhz;
            } else {
                NSManagedObjectContext *context = [[IADBModel persistence] managedObjectContext];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Frequency" inManagedObjectContext:context];
                f = [[NSClassFromString(@"Frequency") alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
                NSLog(@"Frequency create: %@ %@,%@,%f",identifier,name,type,mhz);
                f.airportId = airport.airportId;
                f.name = name;
                f.type = type;
                f.mhz = mhz;
                [[[IADBModel persistence] managedObjectContext] insertObject:f];
            }
        } else {
            NSLog(@"Airport not found: %@",identifier);
        }
    }
}

-(void) deleteFrequency {
    NSDictionary *dict = @{@"KGRR":@"GRAND RAPIDS APP/DEP"};
    [dict enumerateKeysAndObjectsUsingBlock:^(id identifier, id name, BOOL *stop) {
        Airport *airport = [Airport findByIdentifier:identifier];
        if (airport) {
            Frequency *f = [airport frequencyForName:name];
            if (f) {
                NSLog(@"Frequency delete: %@ %@",identifier,name);
                [[IADBModel managedObjectContext] deleteObject:f];
            } else {
                 NSLog(@"Frequency not found: %@ %@",identifier,name);
            }
        } else {
            NSLog(@"Airport not found: %@",identifier);
        }
    }];
}

@end
