//
//  IQTrack.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 22/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTrack.h"
#import "IQTrackPoint.h"

@implementation IQTrack

// Insert code here to add functionality to your managed object subclass

+ (instancetype)createWithStartDate:(NSDate *)start_date
                       activityType:(NSInteger)activityType
                        andUserInfo:(NSDictionary *)userInfo
                          inContext:(NSManagedObjectContext *)ctxt
{
    IQTrack *t = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                               inManagedObjectContext:ctxt];
        
    t.objectId = [[NSProcessInfo processInfo] globallyUniqueString];
    t.activityType = [NSNumber numberWithInteger:activityType];
    t.start_date = start_date;
    t.userInfo = userInfo;
    
    NSError *error;
    [ctxt save:&error];
    
    return t;
}

- (BOOL)closeTrackInContext:(NSManagedObjectContext *)ctxt
{
    if ([self sortedPoints] > 0) {
        
        float distance = 0.0;
        
        IQTrackPoint *previous;
        IQTrackPoint *current;
        CLLocation *l1;
        CLLocation *l2;
        
        for (int i = 0; i < [self sortedPoints].count; i++) {
            current = [self sortedPoints][i];
            if (i > 0) {
                l1 = [[CLLocation alloc] initWithLatitude:previous.latitude.doubleValue longitude:previous.longitude.doubleValue];
                l2 = [[CLLocation alloc] initWithLatitude:current.latitude.doubleValue longitude:current.longitude.doubleValue];
                distance = distance+[l1 distanceFromLocation:l2];
            }
            previous = current;
            if ([current isEqual:[self sortedPoints].lastObject]) {
                self.end_date = current.date;
            }
        }
        self.distance = [NSNumber numberWithFloat:distance];
        NSError *error;
        return [ctxt save:&error];        
    }
    return NO;
}

- (NSArray <IQTrackPoint *> *)sortedPoints
{
    if ([self.points allObjects] > 0) {
        NSArray<IQTrackPoint *> *pointsArray = [self.points allObjects];
        return [pointsArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
    }
    return nil;
}

@end
