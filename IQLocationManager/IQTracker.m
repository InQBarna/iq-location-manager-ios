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
#import "CMMotionActivity+IQ.h"
#import <CoreMotion/CoreMotion.h>

@interface IQTracker()

@property (nonatomic, strong) NSMutableArray        *currentLocations;
@property (nonatomic, strong) NSMutableDictionary   *currentTrack;
@property (nonatomic, assign) BOOL                  locationMonitoringStarted;

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
    self.currentTrack = [NSMutableDictionary dictionary];
    self.currentLocations = [NSMutableArray array];
    __block CMMotionActivity *firstActivity;
    __block CMMotionActivity *lastActivity;

    __weak __typeof(self) welf = self;
    [[IQMotionActivityManager sharedManager] startActivityMonitoringWithUpdateBlock:^(CMMotionActivity *activity, IQMotionActivityResult result) {
        
        if (activity) {
            if ([activity containsActivityType:activityString]) {
                lastActivity = activity;
                if (!welf.locationMonitoringStarted) {
                    welf.locationMonitoringStarted = YES;
                    firstActivity = activity;
                    [[IQSignificantLocationChanges sharedManager] startMonitoringLocationWithSoftAccessRequest:YES
                                                                                                        update:^(CLLocation *locationOrNil, IQLocationResult result) {
                                                                                                            if (locationOrNil && result == kIQLocationResultFound) {
                                                                                                                [welf.currentLocations addObject:locationOrNil];
                                                                                                            } else {
                                                                                                                // check errors
                                                                                                            }
                                                                                                        }];
                }
                
            } else {
                NSTimeInterval seconds = [activity.startDate timeIntervalSinceDate:lastActivity.startDate];
                if (seconds > 180) { // 3 minuts since last correct activity -> stop
                    [welf.currentTrack setObject:firstActivity forKey:@"firstActivity"];
                    [welf.currentTrack setObject:lastActivity forKey:@"lastActivity"];
                    [welf.currentTrack setObject:welf.currentLocations forKey:@"locations"];
                    NSLog(@"startTrackerForActivity :: final object %@", welf.currentTrack);
                    // TODO: save to model                    
                    // TODO: start new tracking
                    
                }
            }
            
        } else {
            // check errors
        }
    }];
}

- (void)stopTracker
{
    [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
    [[IQSignificantLocationChanges sharedManager] stopMonitoringLocation];
}

@end
