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

- (NSString *)activityTypeString
{
    NSString *string = @"";
    if (self.stationary.boolValue) {
        string = [string stringByAppendingString:@"stationary,"];
    }
    if (self.walking.boolValue) {
        string = [string stringByAppendingString:@"walking,"];
    }
    if (self.running.boolValue) {
        string = [string stringByAppendingString:@"running,"];
    }
    if (self.automotive.boolValue) {
        string = [string stringByAppendingString:@"automotive,"];
    }
    if (self.cycling.boolValue) {
        string = [string stringByAppendingString:@"cycling,"];
    }
    if (self.unknown.boolValue) {
        string = [string stringByAppendingString:@"unknown"];
    }
    if ([string isEqualToString:@""]) {
        string = @"*not determined*";
    } else {
        if ([[string substringFromIndex:[string length]-1] isEqualToString:@","]) {
            string = [string substringToIndex:[string length]-1];
        }
    }
    return string;
}

- (NSString *)confidenceString
{
    NSString *string = @"";
    if (self.confidence.integerValue == CMMotionActivityConfidenceLow) {
        string = @"ConfidenceLow";
    } else if (self.confidence.integerValue == CMMotionActivityConfidenceMedium) {
        string = @"ConfidenceMedium";
    } else if (self.confidence.integerValue == CMMotionActivityConfidenceHigh) {
        string = @"ConfidenceHigh";
    }
    return string;
}

#pragma mark - MKAnnotation protocol
- (NSString *)title
{
    return [NSString stringWithFormat:@"%li - %@", self.order.integerValue, [self confidenceString]];
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
