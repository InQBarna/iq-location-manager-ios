//
//  IQTrack.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 28/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTrack.h"
#import "IQTrack.i.h"

#import "IQTrackPoint.i.h"

#import "IQTrackManaged.h"
#import "IQTrackPointManaged.h"

@interface IQTrack ()

@property (nonatomic, retain, readwrite) NSDate *start_date;
@property (nonatomic, retain, readwrite) NSDate *end_date;
@property (nonatomic, retain, readwrite) NSNumber *distance;
@property (nonatomic, retain, readwrite) NSString *objectId;
@property (nonatomic, retain, readwrite) NSNumber *activityType;
@property (nonatomic, retain, readwrite) NSArray<IQTrackPoint *> *points;
@property (nonatomic, retain, readwrite) NSDictionary *userInfo;

@end

@implementation IQTrack

- (instancetype)initWithIQTrack:(IQTrackManaged *)iqTrackManaged
{
    self = [super init];
    
    self.start_date    = iqTrackManaged.start_date;
    self.end_date      = iqTrackManaged.end_date;
    self.distance      = iqTrackManaged.distance;
    self.objectId      = iqTrackManaged.objectId;
    self.activityType  = iqTrackManaged.activityType;
    self.userInfo      = iqTrackManaged.userInfo;
    
    NSMutableArray *temp = [NSMutableArray array];
    for (IQTrackPointManaged *iqTrackPointManaged in [iqTrackManaged sortedPoints]) {
        IQTrackPoint *tp = [[IQTrackPoint alloc] initWithIQTrackPoint:iqTrackPointManaged];
        if (tp) {
            [temp addObject:tp];
        }
    }
    self.points = temp.copy;
    
    return self;
}

- (nonnull IQTrackPoint *)firstPoint
{
    return self.points.firstObject;
}

- (nonnull IQTrackPoint *)lastPoint
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

#pragma mark - NSCopying protocol
- (id)copyWithZone:(NSZone *)zone
{
    IQTrack *copy = [[[self class] allocWithZone: zone] init];
    if (copy) {
        copy.start_date = self.start_date;
        copy.end_date = self.end_date;
        copy.distance = self.distance;
        copy.objectId = self.objectId;
        copy.activityType = self.activityType;
        copy.points = self.points;
    }
    return copy;
}

@end
