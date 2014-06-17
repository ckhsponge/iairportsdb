//
//  FixParser.m
//  airportsdb
//
//  Created by Christopher Hobbs on 6/14/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "FixParser.h"
#import "IADBFix.h"

#define CHUNK_SIZE 100

@implementation FixParser

-(NSString *) fileName {
    return @"FIX";
}

-(NSString *) entityName {
    return @"IADBFix";
}

-(void) parse {
    NSString *path = [[NSBundle mainBundle] pathForResource:[self fileName] ofType:@"txt"];
    
    NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:path];
    [stream open];
    _recordNumber = 0;
    [self readLines:stream usingBlock:^void(NSString *line) {
        [self parseLine:line];
        if( _recordNumber % 1000 == 0 ) { NSLog(@"line %ld",(long) _recordNumber); }
    }];
    
//    uint8_t bytes[CHUNK_SIZE];
//    while (YES) {
//        NSInteger readLength = [stream read:bytes maxLength:CHUNK_SIZE];
//        [stringBuffer appendBytes:bytes length:readLength];
//        
//        NSString *readString = [[NSString alloc] initWithBytes:[stringBuffer bytes] length:readLength encoding:NSUTF8StringEncoding];
//        NSRange range = [readString rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
//        if (range) {
//            <#statements#>
//        }
//    }
    
    
    NSLog(@"Finished parse: %@, lines: %lu", [self fileName], (unsigned long)[self countEntities]);
}

-(void) readLines:(NSInputStream *)stream usingBlock:(void (^)(NSString *line))block {
    
    NSInteger read = 1;
    while ( [stream hasBytesAvailable] && read > 0) {
        NSMutableData *data = [[NSMutableData alloc] init];
        
        uint8_t c;
        do {
            read = [stream read:&c maxLength:1];
            if( read > 0) {
                [data appendBytes:&c length:1];
            }
        } while ( c != '\n' && read > 0);
        
        block( [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] );
    }
}

-(NSArray *) split:(NSString *) s {
    if (!s || s.length == 0) {
        return @[];
    }
    NSMutableArray *a = [[NSMutableArray alloc] initWithArray:[s componentsSeparatedByString:@" "]];
    NSMutableArray *b = [[NSMutableArray alloc] init];
    for ( NSString *s in a) {
        if ( s.length > 0 && ![s isEqualToString:@""]) {
            [b addObject:s];
        }
    }
    return b;
}
//0123456789012345678901234567890123456789012345678901234567890123456789
//FIX1GOZAX                         MISSISSIPPI                   K732-25-02.640N 088-44-13.940WFIX                                                                             RADAR RNAV                            YREP-PT         GOZAXZME ZME                               NNN


-(void) parseLine:(NSString *) line {
    if (!line || line.length < 94) {
        return;
    }
    NSString *fixType = [line substringWithRange:NSMakeRange(0, 4)];
    if ( ![fixType isEqualToString:@"FIX1"]) {
        return;
    }
    
    NSManagedObjectContext *context = [[self persistence] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
    IADBFix *fix = [[NSClassFromString([self entityName]) alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    fix.identifier = [[line substringWithRange:NSMakeRange(4, 10)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    fix.latitude = [self parseDegrees:[line substringWithRange:NSMakeRange(66, 13)]];
    fix.longitude = [self parseDegrees:[line substringWithRange:NSMakeRange(80, 14)]];
    
    
    NSError *error;
    if( [fix validateForInsert:&error]) {
        [[[self persistence] managedObjectContext] insertObject:fix];
    } else {
        //NSLog(@"Skipping object: %@", self.managedObject);
        NSLog(@"Skipping object (%@): %@", error, fix);
    }
    ++_recordNumber;
    
    //NSLog(@"%@",fix);
                    
//    NSArray *columns = [self split:line];
//    if (columns.count == 0) {
//        return;
//    }
//    //NSLog(@"%@",columns);
//    NSString *name = columns[0];
//    if ([name hasPrefix:@"FIX1"]) {
//        name = [name substringFromIndex:4];
//        NSLog(@"%@ %@ %@ %@",name,columns[1],columns[2],columns[3]);
//    }
}

-(double) parseDegrees:(NSString *)s {
    double direction = 1.0;
    if ([s hasSuffix:@"W"] || [s hasSuffix:@"S"]) {
        direction = -1.0;
    }
    s = [s substringWithRange:NSMakeRange(0, s.length-1)];
    NSArray *a = [s componentsSeparatedByString:@"-"];
    if (a.count != 3) {
        NSLog(@"ERROR degree components not 3: %@",s);
        return 0.0;
    }
    double result = [ (NSString *)a[0] doubleValue];
    result += [ (NSString *)a[1] doubleValue]/60.0;
    result += [ (NSString *)a[2] doubleValue]/3600.0;
    return result*direction;
}

@end
