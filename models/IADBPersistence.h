//
//  AirportPersistence.h
//  descent
//
//  Created by Christopher Hobbs on 2/16/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface IADBPersistence : NSObject

// Properties for the Core Data stack.
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSString *persistentStorePath;

-(id) initWithPath:(NSString *) path;
- (NSManagedObjectContext *)managedObjectContext;
-(void) persistentStoreClear;
@end
