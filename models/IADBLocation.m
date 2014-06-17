//
//  IADBLocation.m
//  airportsdb
//
//  Created by Christopher Hobbs on 6/11/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "IADBLocation.h"
#import "IADBConstants.h"
#import "IADBCenteredArray.h"
#import "IADBAirport.h"
#import "IADBNavigationAid.h"

@implementation IADBLocation {
    CLLocation *_location;
}

@dynamic identifier;
@dynamic latitude;
@dynamic longitude;


//@synthesize location = _location;

//don't trust the altitude, self.elevationFeet may be null
-(CLLocation *) location {
    if( !_location ) {
        _location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.latitude, self.longitude) altitude:[self elevationForLocation] horizontalAccuracy:0.0 verticalAccuracy:0.0 timestamp:[NSDate date]];
    }
    return _location;
}

//This scalar is used when constructing a CLLocation. Meters.
-(CLLocationDistance) elevationForLocation {
    return 0.0;
}

+(NSArray *) types {
    return @[];
}


+(NSString *) entityName {
    return [self description];
}

+(NSArray *) subclassNames {
    return @[@"IADBAirport", @"IADBNavigationAid",@"IADBFix"];
}

+(BOOL) isLocationSuperclass {
    return [[self entityName] isEqualToString:@"IADBLocation"];
}

+(IADBCenteredArray *) eachSubclass:(IADBCenteredArray *(^)(id klass))block {
    IADBCenteredArray *result;
    for( NSString *className in [self subclassNames]) {
        IADBCenteredArray *array = block(NSClassFromString(className));
        if (result) {
            [result addCenteredArray:array];
        } else {
            result = array;
        }
    }
    [result sort];
    return result;
}

//returns airports near a location sorted by distance
+(IADBCenteredArray *) findNear:(CLLocation *) location withinNM:(CLLocationDistance) distance {
    if ([self isLocationSuperclass]) {
        return [self eachSubclass:^IADBCenteredArray *(id klass) {
            return [klass findNear:location withinNM:distance];
        }];
    } else {
        return [self findNear:location withinNM:distance withTypes:nil];
    }
}

+(IADBCenteredArray *) findNear:(CLLocation *) location withinNM:(CLLocationDistance) distance withTypes:(NSArray *) types {
    if( types && types.count == 0) {
        IADBCenteredArray *airports = [[IADBCenteredArray alloc] init];
        airports.center = location;
        return airports;
    }
    
    // Set example predicate and sort orderings...
    CLLocationDegrees latitude = location.coordinate.latitude;
    CLLocationDegrees longitude = location.coordinate.longitude;
    
    latitude = MAX(MIN(latitude, 89.0), -89.0); //don't allow calculations at the poles or there will be divide-by-zero errors
    
    CLLocationDistance degreesLatitude = LATITUDE_DEGREES_FROM_NM(distance); //approximate because earth is an ellipse
    CLLocationDistance degreesLongitude = LONGITUDE_DEGREES_FROM_NM(distance,latitude); //longitude degrees are smaller further from equator
    
    NSString *predicateString;
    if (longitude-degreesLongitude < -180.0 || longitude+degreesLongitude > 180.0) {
        //if the search spans the date line then use 'or' instead of 'and' because one parameter will have wrapped
        predicateString = @"(%lf < latitude) AND (latitude < %lf) AND ((%lf < longitude) OR (longitude < %lf))";
    } else {
        predicateString = @"(%lf < latitude) AND (latitude < %lf) AND ((%lf < longitude) AND (longitude < %lf))";
    }
    
    if (types) {
        predicateString = [NSString stringWithFormat:@"%@ AND (%@)",predicateString,[self predicateTypes:types]];
    }
    
    //finds all airports within a box to take advantage of database indexes
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              predicateString,
                              latitude-degreesLatitude, latitude+degreesLatitude,
                              within180To180(longitude-degreesLongitude), within180To180(longitude+degreesLongitude)];
    IADBCenteredArray *airports = [self findAllByPredicate:predicate];
    airports.center = location;
    [airports excludeOutsideNM:distance fromCenter:airports.center]; //trims airports to be within circle i.e. distance
    [airports sortByCenter:airports.center];
    
    return airports;
}

//creates predicate ORing types
+(NSString *) predicateTypes:(NSArray *) types {
    NSMutableArray *predicateTypes = [[NSMutableArray alloc] initWithCapacity:types.count];
    [types enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [predicateTypes addObject:[NSString stringWithFormat:@"(type = '%@')",obj]];
    }];
    return [predicateTypes componentsJoinedByString:@" OR "];
}

+(IADBLocation *) findByIdentifier:(NSString *) identifier {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@" ,identifier];
    IADBCenteredArray *array = [self findAllByPredicate:predicate];
    if (array.array.count != 1) {
        NSLog(@"WARNING! findByIdentifier %@ returned %ld results",identifier,(unsigned long) array.array.count);
    }
    return array.array.count > 0 ? array.array[0] : nil;
}

//[IADBLocation findAllByIdentifier:] unions finds across all subclasses
//IADBAirport uses findAllByIdentifierK: to include K airports
+(IADBCenteredArray *) findAllByIdentifier:(NSString *) identifier {
    if ([self isLocationSuperclass]) {
        return [self eachSubclass:^IADBCenteredArray *(id klass) {
            return [[klass entityName] isEqualToString:@"IADBAirport"] ? [klass findAllByIdentifierK:identifier withTypes:nil] : [klass findAllByIdentifier:identifier];
        }];
    } else {
        return [self findAllByIdentifier:identifier withTypes:nil];
    }
}

//returns locations that begin with identifier
+(IADBCenteredArray *) findAllByIdentifier:(NSString *) identifier withTypes:(NSArray *) types {
    if(!identifier || identifier.length == 0) { return [[IADBCenteredArray alloc] init]; }
    
    NSString *predicateString = @"(identifier BEGINSWITH[c] %@)";
    if (types) {
        predicateString = [NSString stringWithFormat:@"%@ AND (%@)",predicateString,[self predicateTypes:types]];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString ,identifier];
    return [self findAllByPredicate:predicate];
}

//returns locations that begin with identifier with K prepended or the leading K removed
+(IADBCenteredArray *) findAllByIdentifierK:(NSString *) identifier withTypes:(NSArray *) types {
    if(!identifier || identifier.length == 0) { return [[IADBCenteredArray alloc] init]; }
    if( identifier.length > 1 && [[identifier uppercaseString] hasPrefix:@"K"]) {
        //if identifier starts with K remove it because we will check with it later
        //this allows "KCVH" to find CVH
        identifier = [identifier substringFromIndex:1];
    }
    NSString *kidentifier = [NSString stringWithFormat:@"K%@",identifier];
    
    NSString *predicateString = @"((identifier BEGINSWITH[c] %@) OR (identifier BEGINSWITH[c] %@))";
    if (types) {
        predicateString = [NSString stringWithFormat:@"%@ AND (%@)",predicateString,[self predicateTypes:types]];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString ,identifier,kidentifier];
    return [self findAllByPredicate:predicate];
}

+(IADBCenteredArray *) findAllByPredicate:(NSPredicate *) predicate {
    NSManagedObjectContext *context = [IADBModel managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    [request setPredicate:predicate];
    
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
    //                                        initWithKey:@"name" ascending:YES];
    //    [request setSortDescriptors:@[sortDescriptor]];
    
    NSLog(@"fetch %@: %@", [self entityName],request);
    
    NSError *error;
    IADBCenteredArray *airports = [[IADBCenteredArray alloc] initWithArray:[context executeFetchRequest:request error:&error]];
    
    NSAssert3(airports, @"Unhandled error removing file in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
    
    return airports;
}

@end
