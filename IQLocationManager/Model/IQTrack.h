//
//  IQTrack.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 22/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import <CoreMotion/CoreMotion.h>

@class IQTrackPoint;

NS_ASSUME_NONNULL_BEGIN

@interface IQTrack : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (instancetype)createWithStartDate:(NSDate *)start_date
                    andActivityType:(NSInteger)activityType
                          inContext:(NSManagedObjectContext *)ctxt;

- (BOOL)closeTrackInContext:(NSManagedObjectContext *)ctxt;

- (NSArray <IQTrackPoint *> *)sortedPoints;

@end

NS_ASSUME_NONNULL_END

#import "IQTrack+CoreDataProperties.h"
