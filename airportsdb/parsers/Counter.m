//
//  Counter.m
//  airportsdb
//
//  Created by Christopher Hobbs on 2/23/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "Counter.h"
#import "CsvParser.h"

@interface Counter()
@property (atomic, strong) CHCSVParser *parser;
@property (atomic, strong) NSMutableDictionary *singles;
@property (atomic, strong) NSMutableDictionary *doubles;
@property (atomic, strong) NSMutableSet *airportTypes;
@end

@implementation Counter

-(NSString *) fileName {
    return @"airports";
}

-(void) count {
    NSString *path = [[NSBundle mainBundle] pathForResource:[self fileName] ofType:@"csv"];
    self.parser = [[CHCSVParser alloc] initWithContentsOfCSVFile:path];
    self.parser.stripsLeadingAndTrailingWhitespace = YES;
    self.parser.delegate = self;
    
    self.singles = [[NSMutableDictionary alloc] init];
    self.doubles = [[NSMutableDictionary alloc] init];
    self.airportTypes = [[NSMutableSet alloc] init];
    
    [self.parser parse];
}

- (void)parserDidEndDocument:(CHCSVParser *)parser {
    NSLog(@"------");
    NSLog(@"Singles");
    NSLog(@"------");
    [self printHistogram:self.singles];
    NSLog(@"------");
    NSLog(@"Doubles");
    NSLog(@"------");
    [self printHistogram:self.doubles];
    NSLog(@"------");
    NSLog(@"Types");
    NSLog(@"------");
    NSLog(@"%@",[self.airportTypes description]);
}

-(void) printHistogram:(NSDictionary *) dict {
    // Assuming myDictionary was previously populated with NSNumber values.
    NSArray *orderedKeys = [dict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj2 compare:obj1];
    }];
    for( NSString *key in orderedKeys) {
        NSLog(@"%@ -- %@",key, dict[key]);
    }
}

-(void) increment:(NSMutableDictionary *) d key:(NSString *) key {
    if( !key) { return; }
    NSNumber *n = d[key];
    if( !n) {
        n = [NSNumber numberWithInt:0];
    }
    n = [NSNumber numberWithInt:[n intValue] + 1];
    d[key] = n;
}


- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    if( recordNumber % 1000 == 0 ) { NSLog(@"line %ld",(long) recordNumber); }
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)index {
    field = [CsvParser unquote:field];
    BOOL fieldEmpty = !field || field.length == 0;
    if( fieldEmpty ) { return; }
    NSString *ss = [[field substringToIndex:1] uppercaseString];
    NSString *dd = [field length] > 1 ? [[field substringToIndex:2] uppercaseString] : nil;
    switch (index) {
        case 1:
            [self increment:self.singles key:ss];
            [self increment:self.doubles key:dd];
            break;
        case 2:
            [self.airportTypes addObject:field];
            break;
            
        default:
            break;
    }
}

@end
