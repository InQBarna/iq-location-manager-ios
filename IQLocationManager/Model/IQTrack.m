//
//  IQTrack.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 22/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTrack.h"
#import "IQTrackPoint.h"

#import "CMMotionActivity+IQ.h"

@implementation IQTrack

// Insert code here to add functionality to your managed object subclass

+ (instancetype)createWithActivity:(CMMotionActivity *)activity
                         inContext:(NSManagedObjectContext *)ctxt
{
    IQTrack *t = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                               inManagedObjectContext:ctxt];
    
    t.objectId = [[NSProcessInfo processInfo] globallyUniqueString];
    t.activityType = [activity motionTypeStrings];
    t.start_date = activity.startDate;
    
    NSError *error;
    [ctxt save:&error];
    if (error) {
        return nil;
    }
    return t;
}

- (BOOL)closeTrackInContext:(NSManagedObjectContext *)ctxt
{
    if ([self.points allObjects] > 0) {
        
        float distance = 0.0;
        
        IQTrackPoint *previous;
        IQTrackPoint *current;
        CLLocation *l1;
        CLLocation *l2;
        
        for (int i = 0; i < [self.points allObjects].count; i++) {
            current = [self.points allObjects][i];
            if (i > 0) {
                l1 = [[CLLocation alloc] initWithLatitude:previous.latitude.doubleValue longitude:previous.longitude.doubleValue];
                l2 = [[CLLocation alloc] initWithLatitude:previous.latitude.doubleValue longitude:previous.longitude.doubleValue];
                distance = distance+[l1 distanceFromLocation:l2];
            }
            previous = current;
            if ([current isEqual:[self.points allObjects].lastObject]) {
                self.end_date = current.date;
            }
        }
        self.distance = [NSNumber numberWithFloat:distance];
        NSError *error;
        return [ctxt save:&error];        
    }
    return NO;
}

@end
