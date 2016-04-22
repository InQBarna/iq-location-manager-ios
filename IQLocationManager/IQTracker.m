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
#import "IQTrackPoint.h"

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
@property (nonatomic, strong) NSMutableArray        *currentTrackPoints;

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
                     completion:(void (^)(NSDictionary *track, IQTrackerResult result))completion
{
//    self.currentTrack = [NSMutableDictionary dictionary];
//    self.currentLocations = [NSMutableArray array];
//    __block CMMotionActivity *firstActivity;
//    __block CMMotionActivity *lastActivity;
//
//    __weak __typeof(self) welf = self;
//    [[IQMotionActivityManager sharedManager] startActivityMonitoringWithUpdateBlock:^(CMMotionActivity *activity, IQMotionActivityResult result) {
//        
//        if (activity) {
//            if (activityString) {
//                if ([activity containsActivityType:activityString]) {
//                    lastActivity = activity;
//                    if (!welf.locationMonitoringStarted) {
//                        welf.locationMonitoringStarted = YES;
//                        firstActivity = activity;
//                        [[IQPermanentLocation sharedManager] startPermanentMonitoringLocationWithSoftAccessRequest:YES
//                                                                                                          accuracy:kCLLocationAccuracyBestForNavigation
//                                                                                                    distanceFilter:100.0
//                                                                                                      activityType:CLActivityTypeAutomotiveNavigation
//                                                                                   allowsBackgroundLocationUpdates:YES
//                                                                                pausesLocationUpdatesAutomatically:YES
//                                                                                                            update:^(CLLocation *locationOrNil, IQLocationResult result) {
//                                                                                                                if (locationOrNil && result == kIQLocationResultFound) {
//                                                                                                                    [welf.currentLocations addObject:locationOrNil];
//                                                                                                                } else {
//                                                                                                                    // check errors
//                                                                                                                }
//                                                                                                            }];
//                    }
//                    
//                } else {
//                    NSTimeInterval seconds = [activity.startDate timeIntervalSinceDate:lastActivity.startDate];
//                    if (seconds > 120) { // 2 minuts since last correct activity -> close current track
//                        [welf.currentTrack setObject:firstActivity forKey:@"firstActivity"];
//                        [welf.currentTrack setObject:lastActivity forKey:@"lastActivity"];
//                        [welf.currentTrack setObject:welf.currentLocations forKey:@"locations"];
//                        NSLog(@"startTrackerForActivity :: final object %@", welf.currentTrack);
//                        // TODO: save to model
//                        // TODO: start new track
//                        
//                    }
//                }
//            } else {
//                
//            }
//        } else {
//            // check errors
//        }
//    }];
}

- (void)startLIVETrackerForActivity:(NSString *)activityString
                             update:(void (^)(IQTrackPoint *t, IQTrackerResult result))updateBlock
{
    __block CMMotionActivity *currentActivity;
    static int deflectionCounter = 0;
    
    CLLocationAccuracy desiredAccuracy;
    CLLocationDistance distanceFilter;
    CLActivityType activityType;
    BOOL pausesLocationUpdatesAutomatically;
    
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
    
    __weak __typeof(self) welf = self;
    [[IQMotionActivityManager sharedManager] startActivityMonitoringWithUpdateBlock:^(CMMotionActivity *activity, IQMotionActivityResult result) {
        if (result == kIQMotionActivityResultFound && activity) {
            if (activityString) {
                if ([activity containsActivityType:activityString]) {
                    deflectionCounter = 0;
                    currentActivity = activity;
                    if (!welf.locationMonitoringStarted) {
                        welf.locationMonitoringStarted = YES;
                        [[IQPermanentLocation sharedManager] startPermanentMonitoringLocationWithSoftAccessRequest:YES
                                                                                                          accuracy:desiredAccuracy
                                                                                                    distanceFilter:distanceFilter
                                                                                                      activityType:activityType
                                                                                   allowsBackgroundLocationUpdates:YES
                                                                                pausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically
                                                                                                            update:^(CLLocation *locationOrNil, IQLocationResult result) {
                                                                                                                if (locationOrNil && result == kIQLocationResultFound) {
                                                                                                                    
                                                                                                                    IQTrackPoint *t = [[IQTrackPoint alloc]
                                                                                                                                       initWithActivity:currentActivity
                                                                                                                                       location:locationOrNil];
                                                                                                                    
                                                                                                                    [welf.currentTrackPoints addObject:t];
                                                                                                                    updateBlock(t, kIQTrackerResultFound);
                                                                                                                    
                                                                                                                } else {
                                                                                                                    updateBlock(nil, kIQTrackerResultLocationError);
                                                                                                                }
                                                                                                            }];
                    }
                    
                } else {
                    if ((activity.running || activity.walking || activity.automotive || activity.cycling) && activity.confidence > CMMotionActivityConfidenceLow) {
                        deflectionCounter++;
                        if (deflectionCounter == 3) {
                            // 3 times with another valuable activity with at least ConfidenceMedium -> close current track
                            [welf saveCurrentTrack];
                            
                        }
                    } else {
                        NSTimeInterval seconds = [activity.startDate timeIntervalSinceDate:currentActivity.startDate];
                        if (seconds > 120) {
                            // 2 minuts since last correct activity -> close current track
                            [welf saveCurrentTrack];
                            
                        }
                    }
                }
                
            } else {
                if (activity.running || activity.walking || activity.automotive || activity.cycling) {
                    currentActivity = activity;
                    if (!welf.locationMonitoringStarted) {
                        welf.locationMonitoringStarted = YES;
                        [[IQPermanentLocation sharedManager] startPermanentMonitoringLocationWithSoftAccessRequest:YES
                                                                                                          accuracy:desiredAccuracy
                                                                                                    distanceFilter:distanceFilter
                                                                                                      activityType:activityType
                                                                                   allowsBackgroundLocationUpdates:YES
                                                                                pausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically
                                                                                                            update:^(CLLocation *locationOrNil, IQLocationResult result) {
                                                                                                                if (locationOrNil && result == kIQLocationResultFound) {
                                                                                                                    
                                                                                                                    IQTrackPoint *t = [[IQTrackPoint alloc]
                                                                                                                                       initWithActivity:currentActivity
                                                                                                                                       location:locationOrNil];
                                                                                                                    
                                                                                                                    updateBlock(t, kIQTrackerResultFound);
                                                                                                                    
                                                                                                                } else {
                                                                                                                    updateBlock(nil, kIQTrackerResultLocationError);
                                                                                                                    
                                                                                                                }
                                                                                                            }];
                    }
                }
            }
        } else {
            updateBlock(nil, kIQTrackerResultMotionError);
            
        }
    }];
}

- (void)stopTracker
{
    [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
    [[IQPermanentLocation sharedManager] stopPermanentMonitoring];
    self.locationMonitoringStarted = NO;
    [self saveCurrentTrack];
}

- (void)saveCurrentTrack
{
    // TODO: save
}

@end
