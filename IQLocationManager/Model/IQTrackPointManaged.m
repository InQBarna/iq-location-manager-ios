//
//  IQTrackPointManaged.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 22/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTrackPointManaged.h"
#import "IQTrackManaged.h"

@implementation IQTrackPointManaged

// Insert code here to add functionality to your managed object subclass
+ (instancetype)createWithActivity:(CMMotionActivity *)activity
                          location:(CLLocation *)location
                        andTrackID:(NSManagedObjectID *)trackID
                         inContext:(NSManagedObjectContext *)ctxt
{
    IQTrackPointManaged *p = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
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
    
    p.confidence = [NSNumber numberWithInteger:activity.confidence];
    
    NSError *error;
    IQTrackManaged *t = [ctxt existingObjectWithID:trackID error:&error];
    p.order = [NSNumber numberWithInteger:t.points.allObjects.count];
    p.track = t;
    [ctxt save:&error];
    
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

@end