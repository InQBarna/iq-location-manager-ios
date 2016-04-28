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
@property (nonatomic, retain, readwrite) NSString *activityType;
@property (nonatomic, retain, readwrite) NSArray<TrackPoint *> *points;

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

@end
