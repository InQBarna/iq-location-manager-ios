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

@property (nullable, nonatomic, retain, readonly) NSNumber *automotive;
@property (nullable, nonatomic, retain, readonly) NSNumber *confidence;
@property (nullable, nonatomic, retain, readonly) NSNumber *cycling;
@property (nullable, nonatomic, retain, readonly) NSDate *date;
@property (nullable, nonatomic, retain, readonly) NSNumber *latitude;
@property (nullable, nonatomic, retain, readonly) NSNumber *longitude;
@property (nullable, nonatomic, retain, readonly) NSString *objectId;
@property (nullable, nonatomic, retain, readonly) NSNumber *running;
@property (nullable, nonatomic, retain, readonly) NSNumber *stationary;
@property (nullable, nonatomic, retain, readonly) NSNumber *unknown;
@property (nullable, nonatomic, retain, readonly) NSNumber *walking;
@property (nullable, nonatomic, retain, readonly) NSNumber *order;

- (nullable instancetype) init __unavailable;

@end
