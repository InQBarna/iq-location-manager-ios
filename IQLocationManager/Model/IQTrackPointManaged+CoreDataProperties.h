//
//  IQTrackPointManaged+CoreDataProperties.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 05/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "IQTrackPointManaged.h"

NS_ASSUME_NONNULL_BEGIN

@interface IQTrackPointManaged (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *automotive;
@property (nullable, nonatomic, retain) NSNumber *confidence;
@property (nullable, nonatomic, retain) NSNumber *cycling;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSNumber *running;
@property (nullable, nonatomic, retain) NSNumber *stationary;
@property (nullable, nonatomic, retain) NSNumber *unknown;
@property (nullable, nonatomic, retain) NSNumber *walking;
@property (nullable, nonatomic, retain) IQTrackManaged *track;

@end

NS_ASSUME_NONNULL_END
