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

@end
