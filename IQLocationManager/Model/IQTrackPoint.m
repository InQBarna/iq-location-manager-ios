//
//  IQTrackPoint.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 22/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTrackPoint.h"
#import "IQTrack.h"

@implementation IQTrackPoint

// Insert code here to add functionality to your managed object subclass
+ (instancetype)createWithActivity:(CMMotionActivity *)activity
                          location:(CLLocation *)location
                        andTrackID:(NSManagedObjectID *)trackID
                         inContext:(NSManagedObjectContext *)ctxt
{
    __block IQTrackPoint *p;
    [ctxt performBlockAndWait:^{
        p = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                          inManagedObjectContext:ctxt];
        
        p.objectId = [[NSProcessInfo processInfo] globallyUniqueString];
        p.date = [NSDate date];
        
        p.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        p.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        
        p.unknown = [NSNumber numberWithBool:activity.unknown];
        p.stationary = [NSNumber numberWithBool:activity.stationary];
        p.walking = [NSNumber numberWithBool:activity.walking];
        p.running = [NSNumber numberWithBool:activity.running];
        p.automotive = [NSNumber numberWithBool:activity.automotive];
        p.cycling = [NSNumber numberWithBool:activity.cycling];
        
        NSError *error;
        IQTrack *t = [ctxt existingObjectWithID:trackID error:&error];
        p.order = [NSNumber numberWithInteger:t.points.allObjects.count];
        p.track = t;
        [ctxt save:&error];
    }];
    
    return p;
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
