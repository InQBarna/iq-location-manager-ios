//
//  TrackPoint.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 28/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TrackPoint : NSObject <MKAnnotation>

@property (nonnull, nonatomic, retain, readonly) NSNumber *automotive;
@property (nonnull, nonatomic, retain, readonly) NSNumber *confidence;
@property (nonnull, nonatomic, retain, readonly) NSNumber *cycling;
@property (nonnull, nonatomic, retain, readonly) NSDate *date;
@property (nonnull, nonatomic, retain, readonly) NSNumber *latitude;
@property (nonnull, nonatomic, retain, readonly) NSNumber *longitude;
@property (nonnull, nonatomic, retain, readonly) NSString *objectId;
@property (nonnull, nonatomic, retain, readonly) NSNumber *running;
@property (nonnull, nonatomic, retain, readonly) NSNumber *stationary;
@property (nonnull, nonatomic, retain, readonly) NSNumber *unknown;
@property (nonnull, nonatomic, retain, readonly) NSNumber *walking;
@property (nonnull, nonatomic, retain, readonly) NSNumber *order;

- (nullable instancetype) init __unavailable;

- (NSString * _Nonnull)activityTypeString;
- (NSString * _Nonnull)confidenceString;

@end
