//
//  IQTrackPoint+CoreDataProperties.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 22/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "IQTrackPoint.h"

NS_ASSUME_NONNULL_BEGIN

@interface IQTrackPoint (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber *running;
@property (nullable, nonatomic, retain) NSNumber *cycling;
@property (nullable, nonatomic, retain) NSNumber *automotive;
@property (nullable, nonatomic, retain) NSNumber *walking;
@property (nullable, nonatomic, retain) NSNumber *unknown;
@property (nullable, nonatomic, retain) NSNumber *stationary;
@property (nullable, nonatomic, retain) NSNumber *confidence;
@property (nullable, nonatomic, retain) IQTrack *track;

@end

NS_ASSUME_NONNULL_END
