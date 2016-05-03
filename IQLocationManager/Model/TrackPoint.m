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

#pragma mark - NSCoding protocol
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.automotive = [decoder decodeObjectForKey:@"automotive"];
        self.confidence = [decoder decodeObjectForKey:@"confidence"];
        self.cycling = [decoder decodeObjectForKey:@"cycling"];
        self.date = [decoder decodeObjectForKey:@"date"];
        self.latitude = [decoder decodeObjectForKey:@"latitude"];
        self.longitude = [decoder decodeObjectForKey:@"longitude"];
        self.objectId = [decoder decodeObjectForKey:@"objectId"];
        self.running = [decoder decodeObjectForKey:@"running"];
        self.stationary = [decoder decodeObjectForKey:@"stationary"];
        self.unknown = [decoder decodeObjectForKey:@"unknown"];
        self.walking = [decoder decodeObjectForKey:@"walking"];
        self.order = [decoder decodeObjectForKey:@"order"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.automotive forKey:@"automotive"];
    [encoder encodeObject:self.confidence forKey:@"confidence"];
    [encoder encodeObject:self.cycling forKey:@"cycling"];
    [encoder encodeObject:self.date forKey:@"date"];
    [encoder encodeObject:self.latitude forKey:@"latitude"];
    [encoder encodeObject:self.longitude forKey:@"longitude"];
    [encoder encodeObject:self.objectId forKey:@"objectId"];
    [encoder encodeObject:self.running forKey:@"running"];
    [encoder encodeObject:self.stationary forKey:@"stationary"];
    [encoder encodeObject:self.unknown forKey:@"unknown"];
    [encoder encodeObject:self.walking forKey:@"walking"];
    [encoder encodeObject:self.order forKey:@"order"];
}

#pragma mark - MKAnnotation protocol
- (NSString *)title
{
    return [NSString stringWithFormat:@"%li. %@", self.order.integerValue, [self activityTypeString]];
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"%@ - %@",
            [self confidenceString],
            [NSDateFormatter localizedStringFromDate:self.date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle]];
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

@end
