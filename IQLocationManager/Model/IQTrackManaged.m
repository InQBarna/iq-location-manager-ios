//
//  IQTrackManaged.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 22/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTrackManaged.h"
#import "IQTrackPointManaged.h"

@implementation IQTrackManaged

// Insert code here to add functionality to your managed object subclass

+ (instancetype)createWithStartDate:(NSDate *)start_date
                       activityType:(NSInteger)activityType
                        andUserInfo:(NSDictionary *)userInfo
                          inContext:(NSManagedObjectContext *)ctxt
{
    IQTrackManaged *t = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
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
    NSArray<IQTrackPointManaged *> *sortedPointsArray = [self sortedPoints].copy;
    if ( sortedPointsArray ) {
        
        float distance = 0.0;
        
        IQTrackPointManaged *previous;
        IQTrackPointManaged *current;
        CLLocation *l1;
        CLLocation *l2;
        
        for (int i = 0; i < sortedPointsArray.count; i++) {
            current = sortedPointsArray[i];
            if (i > 0) {
                l1 = [[CLLocation alloc] initWithLatitude:previous.latitude.doubleValue longitude:previous.longitude.doubleValue];
                l2 = [[CLLocation alloc] initWithLatitude:current.latitude.doubleValue longitude:current.longitude.doubleValue];
                distance = distance+[l1 distanceFromLocation:l2];
            }
            previous = current;
            if ([current isEqual:sortedPointsArray.lastObject]) {
                self.end_date = current.date;
            }
        }
        self.distance = [NSNumber numberWithFloat:distance];
        NSError *error;
        return [ctxt save:&error];        
    }
    return NO;
}

- (NSArray <IQTrackPointManaged *> *)sortedPoints
{
    if ([self.points allObjects] > 0) {
        NSArray<IQTrackPointManaged *> *pointsArray = [self.points allObjects];
        return [pointsArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
    }
    return nil;
}

@end
