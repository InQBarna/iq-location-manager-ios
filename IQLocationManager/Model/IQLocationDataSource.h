//
//  IQLocationDataSource.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 22/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IQLocationDataSource : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext          *managedObjectContext;

+ (IQLocationDataSource *)sharedDataSource;

@end
