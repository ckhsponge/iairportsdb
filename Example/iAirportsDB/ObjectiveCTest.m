//
//  ObjectiveCTest.m
//  iAirportsDB
//
//  Created by Christopher Hobbs on 9/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

//@import iAirportsDB;
//#import <iAirportsDB/iAirportsDB-Swift.h>
//#import <iAirportsDB/IADBCenteredArray-Swift.h>
#import "iAirportsDB-Swift.h"
#import "iAirportsDB_Example-Bridging-Header.h"
//#import "IADBCenteredArray-Swift.h"
#import "ObjectiveCTest.h"

@implementation ObjectiveCTest

    -(void) test {
        //IADBCenteredArray *array = IADBAirport.findAllByIdentifier(@"KSFO")
        IADBCenteredArray *array = [IADBAirport findAllWithIdentifier:@"KSFO"];
        NSLog(@"ObjectiveCTest %@",array);
        array = [IADBAirport findAllWithIdentifierOrCodeOrMunicipality:@"Santa Barbara" types:nil];
        NSLog(@"ObjectiveCTest Santa Barbara %@",array);
    }
@end
