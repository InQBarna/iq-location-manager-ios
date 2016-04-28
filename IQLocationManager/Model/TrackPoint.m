//
//  TrackPoint.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 28/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "TrackPoint.h"
#import "TrackPoint.i.h"

#import "IQTrackPoint.h"

@interface TrackPoint ()

@property (nonatomic, retain, readwrite) NSNumber *automotive;
@property (nonatomic, retain, readwrite) NSNumber *confidence;
@property (nonatomic, retain, readwrite) NSNumber *cycling;
@property (nonatomic, retain, readwrite) NSDate *date;
@property (nonatomic, retain, readwrite) NSNumber *latitude;
@property (nonatomic, retain, readwrite) NSNumber *longitude;
@property (nonatomic, retain, readwrite) NSString *objectId;
@property (nonatomic, retain, readwrite) NSNumber *running;
@property (nonatomic, retain, readwrite) NSNumber *stationary;
@property (nonatomic, retain, readwrite) NSNumber *unknown;
@property (nonatomic, retain, readwrite) NSNumber *walking;
@property (nonatomic, retain, readwrite) NSNumber *order;

@end

@implementation TrackPoint

- (instancetype)initWithIQTrackPoint:(IQTrackPoint *)iqTrackPoint
{
    self = [super init];
    
    self.automotive   = iqTrackPoint.automotive;
    self.confidence   = iqTrackPoint.confidence;
    self.cycling      = iqTrackPoint.cycling;
    self.date         = iqTrackPoint.date;
    self.latitude     = iqTrackPoint.latitude;
    self.longitude    = iqTrackPoint.longitude;
    self.objectId     = iqTrackPoint.objectId;
    self.running      = iqTrackPoint.running;
    self.stationary   = iqTrackPoint.stationary;
    self.unknown      = iqTrackPoint.unknown;
    self.walking      = iqTrackPoint.walking;
    self.order        = iqTrackPoint.order;
    
    return self;
}

#pragma mark - MKAnnotation protocol
- (NSString *)title
{
    return [NSString stringWithFormat:@"point: %li", self.order.integerValue];
}

- (NSString *)subtitle
{
    return [NSDateFormatter localizedStringFromDate:self.date
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterMediumStyle];
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

@end
