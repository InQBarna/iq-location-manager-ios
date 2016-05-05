//
//  IQTrackManaged+CoreDataProperties.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 05/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "IQTrackManaged.h"

NS_ASSUME_NONNULL_BEGIN

@interface IQTrackManaged (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *activityType;
@property (nullable, nonatomic, retain) NSNumber *distance;
@property (nullable, nonatomic, retain) NSDate *end_date;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSDate *start_date;
@property (nullable, nonatomic, retain) id userInfo;
@property (nullable, nonatomic, retain) NSSet<IQTrackPointManaged *> *points;

@end

@interface IQTrackManaged (CoreDataGeneratedAccessors)

- (void)addPointsObject:(IQTrackPointManaged *)value;
- (void)removePointsObject:(IQTrackPointManaged *)value;
- (void)addPoints:(NSSet<IQTrackPointManaged *> *)values;
- (void)removePoints:(NSSet<IQTrackPointManaged *> *)values;

@end

NS_ASSUME_NONNULL_END
