//
//  Parser.h
//  airportsdb
//
//  Created by Christopher Hobbs on 2/16/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CHCSVParser.h"
#import "Parser.h"

@interface CsvParser : Parser <CHCSVParserDelegate>

@property (atomic, strong) NSManagedObject *managedObject;

//-(id) initWithPersistence:(AirportPersistence *) persistence;
+(NSString *) unquote:(NSString *) s;
-(void) parse;

//override these:
-(NSString *) fileName;
- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)index;
- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field forColumn:(NSString *) column;

@end
