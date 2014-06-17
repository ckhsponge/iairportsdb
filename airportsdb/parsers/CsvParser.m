//
//  Parser.m
//  airportsdb
//
//  Created by Christopher Hobbs on 2/16/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "CsvParser.h"
#import "CHCSVParser.h"
#import "IADBModel.h"
#import "IADBPersistence.h"

@interface CsvParser() {
    NSMutableArray *_columns;
}

@property (atomic, strong) CHCSVParser *parser;

@end

@implementation CsvParser


-(NSString *) fileName {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)index {
    field = [CsvParser unquote:field];
    if (_recordNumber == 1) {
        [_columns addObject:field];
    } else {
        NSString *column = (index >=0 && index<_columns.count) ? [_columns objectAtIndex:index] : nil;
        [self parser:parser didReadField:field forColumn:column];
    }
}


- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field forColumn:(NSString *) column {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

//-(id) initWithPersistence:(AirportPersistence *) persistence {
//    if (self = [super init]) {
//        _persistence = persistence;
//    }
//    return self;
//}

-(void) parse {
    NSString *path = [[NSBundle mainBundle] pathForResource:[self fileName] ofType:@"csv"];
    self.parser = [[CHCSVParser alloc] initWithContentsOfCSVFile:path];
    self.parser.stripsLeadingAndTrailingWhitespace = YES;
    self.parser.delegate = self;
    
    NSLog(@"Starting parse: %@, lines: %lu", [self fileName], (unsigned long)[self countEntities]);
    [self.parser parse];
    NSLog(@"Finished parse: %@, lines: %lu", [self fileName], (unsigned long)[self countEntities]);
}

-(void) save {
    NSLog(@"saving to %@", [IADBModel persistence].persistentStorePath);
    NSError *error;
    [[IADBModel managedObjectContext] save:&error];
    NSAssert3(!error, @"Unhandled error saving in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
    if( error ) {
        NSLog( @"WARNING: Could not save %@ %@", self.managedObject, [error localizedDescription]);
//        NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
//		if(detailedErrors != nil && [detailedErrors count] > 0) {
//			for(NSError* detailedError in detailedErrors) {
//				NSLog(@"  DetailedError: %@", [detailedError userInfo]);
//			}
//		}
//		else {
//			NSLog(@"  %@", [error userInfo]);
//		}
    }
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    _recordNumber = recordNumber;
    if( recordNumber % 1000 == 0 ) { NSLog(@"line %ld",(long) recordNumber); }
    if( recordNumber > 1 ) {
        NSManagedObjectContext *context = [[self persistence] managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
        self.managedObject = [[NSClassFromString([self entityName]) alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
        
    } else {
        _columns = [[NSMutableArray alloc] init];
        self.managedObject = nil;
    }
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    if( !self.managedObject ) {return;}
    NSError *error;
    IADBModel *model = (IADBModel *) self.managedObject;
    if( [model validateForInsert:&error]) {
        [[[self persistence] managedObjectContext] insertObject:model];
    } else if( model.isBlank ) { //![self.managedObject valueForKey:@"airportId"] ) {
        NSLog(@"Skipping blank object");
    } else {
        //NSLog(@"Skipping object: %@", self.managedObject);
        NSLog(@"Skipping object (%@): %@", error, self.managedObject);
     }
    //[self save];
}

- (void)parserDidEndDocument:(CHCSVParser *)parser {
    [self save];
}

+(NSString *) unquote:(NSString *) s {
    if(!s || s.length < 2) {return s;}
    NSArray *quotes = @[@"\"", @"'"];
    if( [quotes containsObject:[s substringToIndex:1] ] && [quotes containsObject:[s substringFromIndex:s.length -1]]) {
        return [s substringWithRange:NSMakeRange(1, s.length-2)];
    } else {
        return s;
    }
}

@end
