//
//  Track.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 28/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "Track.h"
#import "Track.i.h"

#import "TrackPoint.i.h"

#import "IQTrack.h"
#import "IQTrackPoint.h"

@interface Track ()

@property (nonatomic, retain, readwrite) NSDate *start_date;
@property (nonatomic, retain, readwrite) NSDate *end_date;
@property (nonatomic, retain, readwrite) NSNumber *distance;
@property (nonatomic, retain, readwrite) NSString *objectId;
@property (nonatomic, retain, readwrite) NSNumber *activityType;
@property (nonatomic, retain, readwrite) NSArray<TrackPoint *> *points;
@property (nonatomic, retain, readwrite) NSDictionary *userInfo;

@end

@implementation Track

- (instancetype)initWithIQTrack:(IQTrack *)iqTrack
{
    self = [super init];
    
    self.start_date    = iqTrack.start_date;
    self.end_date      = iqTrack.end_date;
    self.distance      = iqTrack.distance;
    self.objectId      = iqTrack.objectId;
    self.activityType  = iqTrack.activityType;
    self.userInfo      = iqTrack.userInfo;
    
    NSMutableArray *temp = [NSMutableArray array];
    for (IQTrackPoint *iqTrackPoint in [iqTrack sortedPoints]) {
        TrackPoint *tp = [[TrackPoint alloc] initWithIQTrackPoint:iqTrackPoint];
        if (tp) {
            [temp addObject:tp];
        }
    }
    self.points = temp.copy;
    
    return self;
}

- (nonnull TrackPoint *)firstPoint
{
    return self.points.firstObject;
}

- (nonnull TrackPoint *)lastPoint
{
    return self.points.lastObject;
}

#pragma mark - NSCoding protocol
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.start_date = [decoder decodeObjectForKey:@"start_date"];
        self.end_date = [decoder decodeObjectForKey:@"end_date"];
        self.distance = [decoder decodeObjectForKey:@"distance"];
        self.objectId = [decoder decodeObjectForKey:@"objectId"];
        self.activityType = [decoder decodeObjectForKey:@"activityType"];
        self.points = [decoder decodeObjectForKey:@"points"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.start_date forKey:@"start_date"];
    [encoder encodeObject:self.end_date forKey:@"end_date"];
    [encoder encodeObject:self.distance forKey:@"distance"];
    [encoder encodeObject:self.objectId forKey:@"objectId"];
    [encoder encodeObject:self.activityType forKey:@"activityType"];
    [encoder encodeObject:self.points forKey:@"points"];
}

@end
