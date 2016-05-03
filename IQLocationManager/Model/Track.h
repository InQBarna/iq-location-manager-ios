//
//  Track.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 28/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TrackPoint;

@interface Track : NSObject <NSCoding>

@property (nonnull, nonatomic, retain, readonly) NSDate *start_date;
@property (nonnull, nonatomic, retain, readonly) NSDate *end_date;
@property (nonnull, nonatomic, retain, readonly) NSNumber *distance;
@property (nonnull, nonatomic, retain, readonly) NSString *objectId;
@property (nonnull, nonatomic, retain, readonly) NSNumber *activityType;
@property (nonnull, nonatomic, retain, readonly) NSArray<TrackPoint *> *points;

- (nullable instancetype) init __unavailable;

@end
