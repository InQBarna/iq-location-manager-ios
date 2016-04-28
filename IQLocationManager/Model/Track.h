//
//  Track.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 28/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TrackPoint;

@interface Track : NSObject

@property (nullable, nonatomic, retain, readonly) NSDate *start_date;
@property (nullable, nonatomic, retain, readonly) NSDate *end_date;
@property (nullable, nonatomic, retain, readonly) NSNumber *distance;
@property (nullable, nonatomic, retain, readonly) NSString *objectId;
@property (nullable, nonatomic, retain, readonly) NSString *activityType;
@property (nullable, nonatomic, retain, readonly) NSArray<TrackPoint *> *points;

- (nullable instancetype) init __unavailable;

@end
