//
//  IQTrackPoint.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 28/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTrackPoint.h"
#import "IQTrackPoint.i.h"

#import "IQTrackPointManaged.h"

@interface IQTrackPoint ()

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

@implementation IQTrackPoint

- (instancetype)initWithIQTrackPoint:(IQTrackPointManaged *)iqTrackPointManaged
{
    self = [super init];
    
    self.automotive   = iqTrackPointManaged.automotive;
    self.confidence   = iqTrackPointManaged.confidence;
    self.cycling      = iqTrackPointManaged.cycling;
    self.date         = iqTrackPointManaged.date;
    self.latitude     = iqTrackPointManaged.latitude;
    self.longitude    = iqTrackPointManaged.longitude;
    self.objectId     = iqTrackPointManaged.objectId;
    self.running      = iqTrackPointManaged.running;
    self.stationary   = iqTrackPointManaged.stationary;
    self.unknown      = iqTrackPointManaged.unknown;
    self.walking      = iqTrackPointManaged.walking;
    self.order        = iqTrackPointManaged.order;
    
    return self;
}

// FIXME: using array
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
        self.titleAnnotation = [decoder decodeObjectForKey:@"titleAnnotation"];
        self.subtitleAnnotation = [decoder decodeObjectForKey:@"subtitleAnnotation"];
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
    [encoder encodeObject:self.titleAnnotation forKey:@"titleAnnotation"];
    [encoder encodeObject:self.subtitleAnnotation forKey:@"subtitleAnnotation"];
}

#pragma mark - NSCopying protocol
- (id)copyWithZone:(NSZone *)zone
{
    IQTrackPoint *copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.automotive = self.automotive;
        copy.confidence = self.confidence;
        copy.cycling = self.cycling;
        copy.date = self.date;
        copy.latitude = self.latitude;
        copy.longitude = self.longitude;
        copy.objectId = self.objectId;
        copy.running = self.running;
        copy.stationary = self.stationary;
        copy.unknown = self.unknown;
        copy.walking = self.walking;
        copy.order = self.order;
    }
    return copy;
}

#pragma mark - MKAnnotation protocol
- (NSString *)title
{
    return self.titleAnnotation;
}

- (NSString *)subtitle
{
    return self.subtitleAnnotation;
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

@end
