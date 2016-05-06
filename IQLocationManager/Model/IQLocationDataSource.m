//
//  IQLocationDataSource.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 22/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQLocationDataSource.h"

#import <CoreData/CoreData.h>

@interface IQLocationDataSource ()

@property (strong, nonatomic) NSManagedObjectContext          *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel            *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

@end

@implementation IQLocationDataSource

static IQLocationDataSource *__iqLocationDataSource;

#pragma mark Initialization and destroy calls

+ (IQLocationDataSource *)sharedDataSource
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __iqLocationDataSource = [[self alloc] init];
    });
    return __iqLocationDataSource;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"IQLocationModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationCacheDirectory] URLByAppendingPathComponent:@"IQLocationModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        if(![[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error]) {
            NSLog(@"Could not remove persistent store: %@", error);
        } else {
            // create a new one
            if([_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                         configuration:nil
                                                                   URL:storeURL
                                                               options:nil
                                                                 error:&error] == nil) {
                
                NSLog(@"Could not create a brand new persistent store: %@", error);
            }
        }
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationCacheDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
