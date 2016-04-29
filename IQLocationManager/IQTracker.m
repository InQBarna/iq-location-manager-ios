//
//  IQTracker.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 19/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTracker.h"

#import "IQMotionActivityManager.h"
#import "IQPermanentLocation.h"
#import "IQSignificantLocationChanges.h"

#import "IQTrack.h"
#import "IQTrackPoint.h"
#import "IQLocationDataSource.h"

#import "Track.i.h"
#import "TrackPoint.i.h"

#import "CMMotionActivity+IQ.h"
#import <CoreMotion/CoreMotion.h>

const struct IQMotionActivityTypes IQMotionActivityType = {
    .walking        = @"walking",
    .running        = @"running",
    .automotive     = @"automotive",
    .cycling        = @"cycling",
};

@interface IQTracker()

@property (nonatomic, strong) IQTrack               *currentTrack;
@property (nonatomic, copy) void (^completionBlock)(Track *t, IQTrackerResult result);
@property (nonatomic, assign) IQTrackerStatus       status;

@end

@implementation IQTracker

static IQTracker *_iqTracker;

#pragma mark Initialization and destroy calls

+ (IQTracker *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _iqTracker = [[self alloc] init];
    });
    return _iqTracker;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.currentTrack = nil;
    self.completionBlock = nil;
}

- (IQTrackerStatus)trackerStatus
{
    return self.status;
}

//- (void)startTrackerForActivity:(NSString *)activityString
//                       progress:(void (^)(IQTrackPoint *t, IQTrackerResult result))progressBlock
//                     completion:(void (^)(IQTrack *t, IQTrackerResult result))completionBlock
//{
//    __block CMMotionActivity *currentActivity;
//    static int deflectionCounter = 0;
//    
//    CLLocationAccuracy desiredAccuracy;
//    CLLocationDistance distanceFilter;
//    CLActivityType activityType;
//    BOOL pausesLocationUpdatesAutomatically;
//    
//    // configure location settings for activity
//    if ([activityString isEqualToString:IQMotionActivityType.automotive]) {
//        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        distanceFilter = 100.f;
//        activityType = CLActivityTypeAutomotiveNavigation;
//        pausesLocationUpdatesAutomatically = NO;
//    
//    } else if ([activityString isEqualToString:IQMotionActivityType.walking] || [activityString isEqualToString:IQMotionActivityType.running]) {
//        desiredAccuracy = kCLLocationAccuracyBest;
//        distanceFilter = 5.f;
//        activityType = CLActivityTypeFitness;
//        pausesLocationUpdatesAutomatically = NO;
//        
//    } else if ([activityString isEqualToString:IQMotionActivityType.cycling]) {
//        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        distanceFilter = 30.f;
//        activityType = CLActivityTypeOtherNavigation;
//        pausesLocationUpdatesAutomatically = NO;
//        
//    } else {
//        // Default == Automotive
//        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        distanceFilter = 100.f;
//        activityType = CLActivityTypeAutomotiveNavigation;
//        pausesLocationUpdatesAutomatically = NO;
//        
//    }
//    
//    self.completionBlock = completionBlock;
//    __block __typeof(self) belf = self;
//    [[IQMotionActivityManager sharedManager] startActivityMonitoringWithUpdateBlock:^(CMMotionActivity *activity, IQMotionActivityResult result) {
//        if (result == kIQMotionActivityResultFound && activity) {
//            if (activityString) {
//                if ([activity containsActivityType:activityString]) {
//                    if (!belf.currentTrack) {
//                        belf.currentTrack = [IQTrack createWithStartDate:activity.startDate
//                                                         andActivityType:activityString
//                                                               inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
//                    }
//                    deflectionCounter = 0;
//                    currentActivity = activity;
//                    if (!belf.locationMonitoringStarted) {
//                        belf.locationMonitoringStarted = YES;
//                        [[IQPermanentLocation sharedManager] startPermanentMonitoringLocationWithSoftAccessRequest:YES
//                                                                                                          accuracy:desiredAccuracy
//                                                                                                    distanceFilter:distanceFilter
//                                                                                                      activityType:activityType
//                                                                                   allowsBackgroundLocationUpdates:YES
//                                                                                pausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically
//                                                                                                            update:^(CLLocation *locationOrNil, IQLocationResult result) {
//                                                                                                                if (locationOrNil && result == kIQLocationResultFound) {
//                                                                                                                    
//                                                                                                                    IQTrackPoint *tp = [IQTrackPoint createWithActivity:currentActivity location:locationOrNil andTrackID:belf.currentTrack.objectID inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
//                                                                                                                    progressBlock(tp, kIQTrackerResultFound);
//                                                                                                                    
//                                                                                                                } else {
//                                                                                                                    if (result == kIQLocationResultSoftDenied || result == kIQLocationResultSystemDenied) {
//                                                                                                                        belf.currentTrack = nil;
//                                                                                                                        [belf stopTracker];
//                                                                                                                        
//                                                                                                                    } else {
//                                                                                                                        progressBlock(nil, kIQTrackerResultLocationError);
//                                                                                                                        
//                                                                                                                    }
//                                                                                                                }
//                                                                                                            }];
//                    }
//                    
//                } else if (currentActivity) {
//                    if ((activity.running || activity.walking || activity.automotive || activity.cycling) && activity.confidence > CMMotionActivityConfidenceLow) {
//                        deflectionCounter++;
//                        if (deflectionCounter == 3) {
//                            // 3 times with another valuable activity with at least ConfidenceMedium -> close current track
//                            [[IQPermanentLocation sharedManager] stopPermanentMonitoring];
//                            belf.locationMonitoringStarted = NO;
//                            currentActivity = nil;
//                            [belf closeCurrentTrack];
//                            
//                        }
//                    } else {
//                        NSTimeInterval seconds = [activity.startDate timeIntervalSinceDate:currentActivity.startDate];
//                        if (seconds > 120) {
//                            // 2 minuts since last correct activity -> close current track
//                            [[IQPermanentLocation sharedManager] stopPermanentMonitoring];
//                            belf.locationMonitoringStarted = NO;
//                            currentActivity = nil;
//                            [belf closeCurrentTrack];
//                            
//                        }
//                    }
//                }
//                
//            } else {
//                if (!belf.currentTrack) {
//                    belf.currentTrack = [IQTrack createWithStartDate:activity.startDate
//                                                     andActivityType:@"all"
//                                                           inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
//                }
//                if (activity.running || activity.walking || activity.automotive || activity.cycling) {
//                    currentActivity = activity;
//                    if (!belf.locationMonitoringStarted) {
//                        belf.locationMonitoringStarted = YES;
//                        [[IQPermanentLocation sharedManager] startPermanentMonitoringLocationWithSoftAccessRequest:YES
//                                                                                                          accuracy:desiredAccuracy
//                                                                                                    distanceFilter:distanceFilter
//                                                                                                      activityType:activityType
//                                                                                   allowsBackgroundLocationUpdates:YES
//                                                                                pausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically
//                                                                                                            update:^(CLLocation *locationOrNil, IQLocationResult result) {
//                                                                                                                if (locationOrNil && result == kIQLocationResultFound) {
//                                                                                                                    
//                                                                                                                    IQTrackPoint *tp = [IQTrackPoint createWithActivity:currentActivity location:locationOrNil andTrackID:belf.currentTrack.objectID inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
//                                                                                                                    progressBlock(tp, kIQTrackerResultFound);
//                                                                                                                    
//                                                                                                                } else {
//                                                                                                                    if (result == kIQLocationResultSoftDenied || result == kIQLocationResultSystemDenied) {
//                                                                                                                        belf.currentTrack = nil;
//                                                                                                                        [belf stopTracker];
//                                                                                                                        
//                                                                                                                    } else {
//                                                                                                                        progressBlock(nil, kIQTrackerResultLocationError);
//                                                                                                                        
//                                                                                                                    }
//                                                                                                                }
//                                                                                                            }];
//                    }
//                }
//            }
//        } else {
//            progressBlock(nil, kIQTrackerResultMotionError);
//            
//        }
//    }];
//}

- (void)startLIVETrackerForActivity:(NSString *)activityString
                           progress:(void (^)(TrackPoint *p, IQTrackerResult result))progressBlock
                         completion:(void (^)(Track *t, IQTrackerResult result))completionBlock
{
    __block CMMotionActivity *lastActivity;
    static int deflectionCounter = 0;
    
    CLLocationAccuracy desiredAccuracy;
    CLLocationDistance distanceFilter;
    CLActivityType activityType;
    BOOL pausesLocationUpdatesAutomatically;
    
    self.status = kIQTrackerStatusWorkingAutotracking;
    
    // configure location settings for activity
    if ([activityString isEqualToString:IQMotionActivityType.automotive]) {
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 100.f;
        activityType = CLActivityTypeAutomotiveNavigation;
        pausesLocationUpdatesAutomatically = NO;
        
    } else if ([activityString isEqualToString:IQMotionActivityType.walking] || [activityString isEqualToString:IQMotionActivityType.running]) {
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 5.f;
        activityType = CLActivityTypeFitness;
        pausesLocationUpdatesAutomatically = NO;
        
        // TEST
//        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        distanceFilter = 5.f;
//        activityType = CLActivityTypeAutomotiveNavigation;
//        pausesLocationUpdatesAutomatically = NO;
        
    } else if ([activityString isEqualToString:IQMotionActivityType.cycling]) {
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 30.f;
        activityType = CLActivityTypeOtherNavigation;
        pausesLocationUpdatesAutomatically = NO;
        
    } else {
        // Default == Automotive
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 100.f;
        activityType = CLActivityTypeAutomotiveNavigation;
        pausesLocationUpdatesAutomatically = NO;
        
        self.status = kIQTrackerStatusWorkingManual;
        
    }
    
    self.completionBlock = completionBlock;
    __block __typeof(self) belf = self;
    [[IQPermanentLocation sharedManager] startPermanentMonitoringLocationWithSoftAccessRequest:YES
                                                                                      accuracy:desiredAccuracy
                                                                                distanceFilter:distanceFilter
                                                                                  activityType:activityType
                                                               allowsBackgroundLocationUpdates:YES
                                                            pausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically
                                                                                        update:^(CLLocation *locationOrNil, IQLocationResult result) {
                                                                                            
        if (locationOrNil && result == kIQLocationResultFound) {
            [[IQMotionActivityManager sharedManager] startActivityMonitoringWithUpdateBlock:^(CMMotionActivity *activity, IQMotionActivityResult result)
            {
                if (result == kIQMotionActivityResultFound && activity) {
                    if (activityString) { // CASE: AUTOMATIC
                        
                        // CASE: track finished, but it wasn't possible to determine because no location received after motion stop
                        if (lastActivity) {
                            NSTimeInterval seconds = [activity.startDate timeIntervalSinceDate:lastActivity.startDate];
                            if (seconds > 300) {
                                // 5 minuts since last correct activity -> close current track
                                deflectionCounter = 0;
                                lastActivity = nil;
                                [belf closeCurrentTrack];
                                
                            }
                        }
                        
                        if ([activity containsActivityType:activityString]) {
                            deflectionCounter = 0;
                            lastActivity = activity;
                            
                            __block TrackPoint *tp_temp;
                            [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
                                if (!belf.currentTrack) {
                                    belf.currentTrack = [IQTrack createWithStartDate:activity.startDate
                                                                     andActivityType:activityString
                                                                           inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                }
                                IQTrackPoint *tp = [IQTrackPoint createWithActivity:lastActivity
                                                                           location:locationOrNil
                                                                         andTrackID:belf.currentTrack.objectID
                                                                          inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                
                                tp_temp = [[TrackPoint alloc] initWithIQTrackPoint:tp];
                            }];
                            
                            progressBlock(tp_temp, kIQTrackerResultFound);
                            
                        } else if (lastActivity) {
                            // filters
                            if ((activity.running || activity.walking || activity.automotive || activity.cycling) && activity.confidence > CMMotionActivityConfidenceLow) {
                                deflectionCounter++;
                                if (deflectionCounter == 3) {
                                    // 3 times with another valuable activity with at least ConfidenceMedium -> close current track
                                    deflectionCounter = 0;
                                    lastActivity = nil;
                                    [belf closeCurrentTrack];
                                    
                                }
                            } else {
                                NSTimeInterval seconds = [activity.startDate timeIntervalSinceDate:lastActivity.startDate];
                                if (seconds > 120) {
                                    // 2 minuts since last correct activity -> close current track
                                    deflectionCounter = 0;
                                    lastActivity = nil;
                                    [belf closeCurrentTrack];
                                    
                                }
                            }

                        }
                    } else { // CASE: MANUAL
                        if (activity.running || activity.walking || activity.automotive || activity.cycling) {
                            lastActivity = activity;
                            
                            __block TrackPoint *tp_temp;
                            [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
                                if (!belf.currentTrack) {
                                    belf.currentTrack = [IQTrack createWithStartDate:activity.startDate
                                                                     andActivityType:@"all"
                                                                           inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                }                                
                                IQTrackPoint *tp = [IQTrackPoint createWithActivity:lastActivity
                                                                           location:locationOrNil
                                                                         andTrackID:belf.currentTrack.objectID
                                                                          inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                
                                tp_temp = [[TrackPoint alloc] initWithIQTrackPoint:tp];
                            }];
                            progressBlock(tp_temp, kIQTrackerResultFound);
                        }
                    }
                } else {
                    progressBlock(nil, kIQTrackerResultMotionError);
                    
                }
                [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
            }];
                                                                                                
        } else {
            if (result == kIQLocationResultSoftDenied || result == kIQLocationResultSystemDenied) {
                belf.currentTrack = nil;
                [belf stopTracker];
                
            } else {
                progressBlock(nil, kIQTrackerResultLocationError);
            }
        }
    }];
}

- (void)startTrackerForActivity:(NSString *)activityString
{
    [self startLIVETrackerForActivity:activityString
                             progress:^(TrackPoint *t, IQTrackerResult result) {
                                 if (t) {
                                     NSLog(@"%@", [NSString stringWithFormat:@"Point: %li. %@ %@",
                                                   t.order.integerValue,
                                                   [t activityTypeString],
                                                   [NSDateFormatter localizedStringFromDate:t.date
                                                                                  dateStyle:NSDateFormatterShortStyle
                                                                                  timeStyle:NSDateFormatterShortStyle]]);
                                 } else {
                                     NSLog(@"NO POINT: %li", (long)result);
                                 }
                                 
                             } completion:^(Track *t, IQTrackerResult result) {
                                 if (t) {
                                     NSLog(@"\n%@\n%@",
                                           [NSString stringWithFormat:@"Track Ended: %@", t.activityType],
                                           [NSString stringWithFormat:@"from: %@\nto: %@",
                                            [NSDateFormatter localizedStringFromDate:t.start_date
                                                                           dateStyle:NSDateFormatterShortStyle
                                                                           timeStyle:NSDateFormatterShortStyle],
                                            [NSDateFormatter localizedStringFromDate:t.end_date
                                                                           dateStyle:NSDateFormatterShortStyle
                                                                           timeStyle:NSDateFormatterShortStyle]]);
                                 } else {
                                     NSLog(@"NO TRACK: %li", (long)result);
                                 }
                                 
                             }];
}

- (void)stopTracker
{
    [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
    [[IQPermanentLocation sharedManager] stopPermanentMonitoring];
    self.status = kIQTrackerStatusStopped;
    [self closeCurrentTrack];
}

- (void)closeCurrentTrack
{
    if (self.currentTrack) {
        BOOL result = [self.currentTrack closeTrackInContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
        NSAssert(result, @"error closing track");
    }
    
    Track *t_temp = [[Track alloc] initWithIQTrack:self.currentTrack];
    
    self.completionBlock(t_temp, kIQTrackerResultTrackEnd);
    self.currentTrack = nil;
}

- (void)checkCurrentTrack
{
    if (self.currentTrack && ![self.currentTrack.activityType isEqualToString:@"all"]) {
        NSArray *points = [self.currentTrack sortedPoints];
        IQTrackPoint *lastP = [points lastObject];
        NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:lastP.date];
        if (seconds > 300) {
            // 5 minuts since last correct activity -> close current track
            [self closeCurrentTrack];
        }
    }
}

#pragma mark - GET Tracks methods
- (NSArray *)getCompletedTracks
{
    [self checkCurrentTrack];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IQTrack"];
    request.predicate = [NSPredicate predicateWithFormat:@"end_date != nil"];
    
    NSMutableArray *temp = [NSMutableArray array];
    [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        NSArray *tracks = [[IQLocationDataSource sharedDataSource].managedObjectContext executeFetchRequest:request error:&error].copy;
        
        for (IQTrack *iqTrack in tracks) {
            Track *t = [[Track alloc] initWithIQTrack:iqTrack];
            [temp addObject:t];
        }
    }];
    
    return temp.copy;
}

- (NSArray *)getTracksBetweenDate:(NSDate *)start_date
                          andDate:(NSDate *)end_date
{
    [self checkCurrentTrack];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IQTrack"];
    request.predicate = [NSPredicate predicateWithFormat:@"end_date != nil AND start_date <= %@ AND end_date >= %@", start_date, end_date];
    
    NSMutableArray *temp = [NSMutableArray array];
    [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        NSArray *tracks = [[IQLocationDataSource sharedDataSource].managedObjectContext executeFetchRequest:request error:&error].copy;
        
        for (IQTrack *iqTrack in tracks) {
            Track *t = [[Track alloc] initWithIQTrack:iqTrack];
            [temp addObject:t];
        }
    }];
    
    return temp.copy;
}

- (Track *)getLastTrack
{
    NSArray *array = [self getCompletedTracks].copy;
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"end_date" ascending:YES];
    NSArray *temp = [array sortedArrayUsingDescriptors:@[sort]].copy;    
    if (temp.count > 0) {
        return temp.lastObject;
    }
    return nil;
}

#pragma mark - DELETE IQTracks method
- (void)deleteTracks
{
    if (self.currentTrack) {
        [self closeCurrentTrack];
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IQTrack"];
    [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        NSArray *tracks = [[IQLocationDataSource sharedDataSource].managedObjectContext executeFetchRequest:request error:&error].copy;
        
        for (IQTrack *iqTrack in tracks) {
            [[IQLocationDataSource sharedDataSource].managedObjectContext deleteObject:iqTrack];
        }
        
        [[IQLocationDataSource sharedDataSource].managedObjectContext save:&error];        
    }];
}

@end
