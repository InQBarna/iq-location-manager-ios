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

#import "CMMotionActivity+IQ.h"
#import <CoreMotion/CoreMotion.h>

const struct IQMotionActivityTypes IQMotionActivityType = {
    .stationary     = @"stationary",
    .walking        = @"walking",
    .running        = @"running",
    .automotive     = @"automotive",
    .cycling        = @"cycling",
    .unknown        = @"unknown",
};

@interface IQTracker()

@property (nonatomic, assign) BOOL                  locationMonitoringStarted;
@property (nonatomic, strong) IQTrack               *currentTrack;
@property (nonatomic, copy) void (^completionBlock)(IQTrack *t, IQTrackerResult result);

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
    
}

- (void)startTrackerForActivity:(NSString *)activityString
                       progress:(void (^)(IQTrackPoint *t, IQTrackerResult result))progressBlock
                     completion:(void (^)(IQTrack *t, IQTrackerResult result))completionBlock
{
    __block CMMotionActivity *currentActivity;
    static int deflectionCounter = 0;
    
    CLLocationAccuracy desiredAccuracy;
    CLLocationDistance distanceFilter;
    CLActivityType activityType;
    BOOL pausesLocationUpdatesAutomatically;
    
    // configure location settings for activity
    if ([activityString isEqualToString:IQMotionActivityType.automotive]) {
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 100.f;
        activityType = CLActivityTypeAutomotiveNavigation;
        pausesLocationUpdatesAutomatically = YES;
    
    } else if ([activityString isEqualToString:IQMotionActivityType.walking] || [activityString isEqualToString:IQMotionActivityType.running]) {
        desiredAccuracy = kCLLocationAccuracyBest;
        distanceFilter = 5.f;
        activityType = CLActivityTypeFitness;
        pausesLocationUpdatesAutomatically = YES;
        
    } else if ([activityString isEqualToString:IQMotionActivityType.cycling]) {
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 30.f;
        activityType = CLActivityTypeOtherNavigation;
        pausesLocationUpdatesAutomatically = YES;
        
    } else {
        // Default == Automotive
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 100.f;
        activityType = CLActivityTypeAutomotiveNavigation;
        pausesLocationUpdatesAutomatically = YES;
        
    }
    
    self.completionBlock = completionBlock;
    __block __typeof(self) belf = self;
    [[IQMotionActivityManager sharedManager] startActivityMonitoringWithUpdateBlock:^(CMMotionActivity *activity, IQMotionActivityResult result) {
        if (result == kIQMotionActivityResultFound && activity) {
            if (activityString) {
                if ([activity containsActivityType:activityString]) {
                    if (!belf.currentTrack) {
                        belf.currentTrack = [IQTrack createWithStartDate:activity.startDate
                                                         andActivityType:activityString
                                                               inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                    }
                    deflectionCounter = 0;
                    currentActivity = activity;
                    if (!belf.locationMonitoringStarted) {
                        belf.locationMonitoringStarted = YES;
                        [[IQPermanentLocation sharedManager] startPermanentMonitoringLocationWithSoftAccessRequest:YES
                                                                                                          accuracy:desiredAccuracy
                                                                                                    distanceFilter:distanceFilter
                                                                                                      activityType:activityType
                                                                                   allowsBackgroundLocationUpdates:YES
                                                                                pausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically
                                                                                                            update:^(CLLocation *locationOrNil, IQLocationResult result) {
                                                                                                                if (locationOrNil && result == kIQLocationResultFound) {
                                                                                                                    
                                                                                                                    IQTrackPoint *tp = [IQTrackPoint createWithActivity:currentActivity location:locationOrNil andTrackID:belf.currentTrack.objectID inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                                                                                                    progressBlock(tp, kIQTrackerResultFound);
                                                                                                                    
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
                    
                } else if (currentActivity) {
                    if ((activity.running || activity.walking || activity.automotive || activity.cycling) && activity.confidence > CMMotionActivityConfidenceLow) {
                        deflectionCounter++;
                        if (deflectionCounter == 3) {
                            // 3 times with another valuable activity with at least ConfidenceMedium -> close current track
                            [[IQPermanentLocation sharedManager] stopPermanentMonitoring];
                            belf.locationMonitoringStarted = NO;
                            currentActivity = nil;
                            [belf closeCurrentTrack];
                            
                        }
                    } else {
                        NSTimeInterval seconds = [activity.startDate timeIntervalSinceDate:currentActivity.startDate];
                        if (seconds > 120) {
                            // 2 minuts since last correct activity -> close current track
                            [[IQPermanentLocation sharedManager] stopPermanentMonitoring];
                            belf.locationMonitoringStarted = NO;
                            currentActivity = nil;
                            [belf closeCurrentTrack];
                            
                        }
                    }
                }
                
            } else {
                if (!belf.currentTrack) {
                    belf.currentTrack = [IQTrack createWithStartDate:activity.startDate
                                                     andActivityType:@"all"
                                                           inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                }
                if (activity.running || activity.walking || activity.automotive || activity.cycling) {
                    currentActivity = activity;
                    if (!belf.locationMonitoringStarted) {
                        belf.locationMonitoringStarted = YES;
                        [[IQPermanentLocation sharedManager] startPermanentMonitoringLocationWithSoftAccessRequest:YES
                                                                                                          accuracy:desiredAccuracy
                                                                                                    distanceFilter:distanceFilter
                                                                                                      activityType:activityType
                                                                                   allowsBackgroundLocationUpdates:YES
                                                                                pausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically
                                                                                                            update:^(CLLocation *locationOrNil, IQLocationResult result) {
                                                                                                                if (locationOrNil && result == kIQLocationResultFound) {
                                                                                                                    
                                                                                                                    IQTrackPoint *tp = [IQTrackPoint createWithActivity:currentActivity location:locationOrNil andTrackID:belf.currentTrack.objectID inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                                                                                                    progressBlock(tp, kIQTrackerResultFound);
                                                                                                                    
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
                }
            }
        } else {
            progressBlock(nil, kIQTrackerResultMotionError);
            
        }
    }];
}

- (void)reverseStartTrackerForActivity:(NSString *)activityString
                              progress:(void (^)(IQTrackPoint *t, IQTrackerResult result))progressBlock
                            completion:(void (^)(IQTrack *t, IQTrackerResult result))completionBlock
{
    __block CMMotionActivity *currentActivity;
    static int deflectionCounter = 0;
    
    CLLocationAccuracy desiredAccuracy;
    CLLocationDistance distanceFilter;
    CLActivityType activityType;
    BOOL pausesLocationUpdatesAutomatically;
    
    // configure location settings for activity
    if ([activityString isEqualToString:IQMotionActivityType.automotive]) {
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 100.f;
        activityType = CLActivityTypeAutomotiveNavigation;
        pausesLocationUpdatesAutomatically = YES;
        
    } else if ([activityString isEqualToString:IQMotionActivityType.walking] || [activityString isEqualToString:IQMotionActivityType.running]) {
        desiredAccuracy = kCLLocationAccuracyBest;
        distanceFilter = 5.f;
        activityType = CLActivityTypeFitness;
        pausesLocationUpdatesAutomatically = YES;
        
    } else if ([activityString isEqualToString:IQMotionActivityType.cycling]) {
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 30.f;
        activityType = CLActivityTypeOtherNavigation;
        pausesLocationUpdatesAutomatically = YES;
        
    } else {
        // Default == Automotive
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 100.f;
        activityType = CLActivityTypeAutomotiveNavigation;
        pausesLocationUpdatesAutomatically = YES;
        
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
                        if ([activity containsActivityType:activityString]) {
                            deflectionCounter = 0;
                            currentActivity = activity;
                            if (!belf.currentTrack) {
                                belf.currentTrack = [IQTrack createWithStartDate:activity.startDate
                                                                 andActivityType:activityString
                                                                       inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                            }
                            IQTrackPoint *tp = [IQTrackPoint createWithActivity:currentActivity
                                                                       location:locationOrNil
                                                                     andTrackID:belf.currentTrack.objectID
                                                                      inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                            progressBlock(tp, kIQTrackerResultFound);
                            
                        } else if (currentActivity) {
                            // filters
                            if ((activity.running || activity.walking || activity.automotive || activity.cycling) && activity.confidence > CMMotionActivityConfidenceLow) {
                                deflectionCounter++;
                                if (deflectionCounter == 3) {
                                    // 3 times with another valuable activity with at least ConfidenceMedium -> close current track
                                    deflectionCounter = 0;
                                    belf.locationMonitoringStarted = NO;
                                    currentActivity = nil;
                                    [belf closeCurrentTrack];
                                    
                                }
                            } else {
                                NSTimeInterval seconds = [activity.startDate timeIntervalSinceDate:currentActivity.startDate];
                                if (seconds > 120) {
                                    // 2 minuts since last correct activity -> close current track
                                    deflectionCounter = 0;
                                    belf.locationMonitoringStarted = NO;
                                    currentActivity = nil;
                                    [belf closeCurrentTrack];
                                    
                                }
                            }

                        }
                    } else { // CASE: MANUAL
                        if (!belf.currentTrack) {
                            belf.currentTrack = [IQTrack createWithStartDate:activity.startDate
                                                             andActivityType:@"all"
                                                                   inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                        }
                        if (activity.running || activity.walking || activity.automotive || activity.cycling) {
                            currentActivity = activity;
                            IQTrackPoint *tp = [IQTrackPoint createWithActivity:currentActivity
                                                                       location:locationOrNil
                                                                     andTrackID:belf.currentTrack.objectID
                                                                      inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                            progressBlock(tp, kIQTrackerResultFound);
                        }
                    }
                }
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

- (void)stopTracker
{
    [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
    [[IQPermanentLocation sharedManager] stopPermanentMonitoring];
    self.locationMonitoringStarted = NO;
    [self closeCurrentTrack];
}

- (void)closeCurrentTrack
{
    if (self.currentTrack) {
        BOOL result = [self.currentTrack closeTrackInContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
        NSAssert(result, @"error closing track");
    }
    self.completionBlock(self.currentTrack, kIQTrackerResultTrackEnd);
    self.currentTrack = nil;
}

#pragma mark - GET IQTracks methods
- (NSArray *)getCompletedTracks
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IQTrack"];
    request.predicate = [NSPredicate predicateWithFormat:@"end_date != nil"];
    NSError *error = nil;
    return [[IQLocationDataSource sharedDataSource].managedObjectContext executeFetchRequest:request error:&error].copy;
}

- (NSArray *)getTracksBetweenDate:(NSDate *)start_date
                          andDate:(NSDate *)end_date
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IQTrack"];
    request.predicate = [NSPredicate predicateWithFormat:@"end_date != nil AND start_date <= %@ AND end_date >= %@", start_date, end_date];
    NSError *error = nil;
    return [[IQLocationDataSource sharedDataSource].managedObjectContext executeFetchRequest:request error:&error].copy;
}

@end
