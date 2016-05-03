//
//  IQTrack+CoreDataProperties.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 03/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "IQTrack.h"

NS_ASSUME_NONNULL_BEGIN

@interface IQTrack (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *activityType;
@property (nullable, nonatomic, retain) NSNumber *distance;
@property (nullable, nonatomic, retain) NSDate *end_date;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSDate *start_date;
@property (nullable, nonatomic, retain) NSSet<IQTrackPoint *> *points;

@end

@interface IQTrack (CoreDataGeneratedAccessors)

- (void)addPointsObject:(IQTrackPoint *)value;
- (void)removePointsObject:(IQTrackPoint *)value;
- (void)addPoints:(NSSet<IQTrackPoint *> *)values;
- (void)removePoints:(NSSet<IQTrackPoint *> *)values;

@end

NS_ASSUME_NONNULL_END
