//
//  IQTrackManaged.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 22/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import <CoreMotion/CoreMotion.h>

@class IQTrackPointManaged;

NS_ASSUME_NONNULL_BEGIN

@interface IQTrackManaged : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (instancetype)createWithStartDate:(NSDate *)start_date
                       activityType:(NSInteger)activityType
                        andUserInfo:(NSDictionary *)userInfo
                          inContext:(NSManagedObjectContext *)ctxt;

- (BOOL)closeTrackInContext:(NSManagedObjectContext *)ctxt;

- (NSArray <IQTrackPointManaged *> *)sortedPoints;

@end

NS_ASSUME_NONNULL_END

#import "IQTrackManaged+CoreDataProperties.h"
