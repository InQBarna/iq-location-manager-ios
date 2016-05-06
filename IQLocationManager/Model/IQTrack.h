//
//  IQTrack.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 28/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQTrackPoint;

@interface IQTrack : NSObject <NSCoding, NSCopying>

@property (nonnull, nonatomic, retain, readonly) NSDate *start_date;
@property (nonnull, nonatomic, retain, readonly) NSDate *end_date;
@property (nonnull, nonatomic, retain, readonly) NSNumber *distance;
@property (nonnull, nonatomic, retain, readonly) NSString *objectId;
@property (nonnull, nonatomic, retain, readonly) NSNumber *activityType;
@property (nonnull, nonatomic, retain, readonly) NSArray<IQTrackPoint *> *points;
@property (nonnull, nonatomic, retain, readonly) NSDictionary *userInfo;

- (nullable instancetype) init __unavailable;

- (nonnull IQTrackPoint *)firstPoint;
- (nonnull IQTrackPoint *)lastPoint;

@end
