//
//  IQTracker.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 19/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IQLocationPermissions.h"
#import "IQMotionActivityManager.h"

@class IQTrackManaged, IQTrackPointManaged, IQTrack, IQTrackPoint;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, IQTrackerStatus) {
    kIQTrackerStatusStopped,
    kIQTrackerStatusWorkingAutotracking,
    kIQTrackerStatusWorkingManual,
};

typedef NS_ENUM(NSInteger, IQTrackerResult) {
    kIQTrackerResultError,
    kIQTrackerResultMotionError,
    kIQTrackerResultLocationError,
    kIQTrackerResultNoResult,
    kIQTrackerResultFound,
    kIQTrackerResultTrackEnd,
};

typedef NS_ENUM(NSInteger, IQMotionActivityType) {
    kIQMotionActivityTypeNone,
    kIQMotionActivityTypeAll,    
    kIQMotionActivityTypeWalking,
    kIQMotionActivityTypeRunning,
    kIQMotionActivityTypeAutomotive,
    kIQMotionActivityTypeCycling,
};

@interface IQTracker : NSObject

+ (IQTracker *)sharedManager;

/**
 Returns IQTrackerStatus: kIQTrackerStatusStopped || kIQTrackerStatusWorkingAutotracking || kIQTrackerStatusWorkingManual 
 */
- (IQTrackerStatus)trackerStatus;

/**
 Returns YES if there is a IQTrack working just now, otherwise returns NO.
 */
- (BOOL)isTrackInProgress;

/**
 The tracker starts first the IQPermanentLocation :: startPermanentMonitoringLocation and when there's a result, starts IQMotionActivityManager :: startActivityMonitoring. When there's an activity match, if no currentTrack created, create one and then create a IQTrackPoint related to that IQTrack. If currentTrack already created, just create a new IQTrackPoint and relates it to the currentTrack.
 
 @fact: The tracker's result depends on location.
 
 @param activityType is an IQMotionActivityType.
 If activityType != kIQMotionActivityTypeAll && activityType != kIQMotionActivityTypeNone, autotracking mode starts: the IQTracker will IQTrack this activityType starting and stopping by itself, creating Tracks when that kind of activity starts or stops.
 
 If activityType == kIQMotionActivityTypeAll, manual mode starts with activity: the tracker will track every valuable activity (running && walking && automotive && cycling), considering all in the same IQTrack and the IQTrack will stop when stopTracker method is called.
 
 If activityType == kIQMotionActivityTypeNone, manual mode starts without activity: the tracker will track only location, considering all in the same IQTrack and the IQTrack will stop when stopTracker method is called.
 @param userInfo is a dictionary for passing custom information to the starting IQTrack.
 @param progressBlock will be called with the current IQTrackPoint of the current IQTrack.
 @param completionBlock will be called with the finished IQTrack.
 */
- (void)startTrackerForActivity:(IQMotionActivityType)activityType
                       userInfo:(nullable NSDictionary *)userInfo;

- (void)startLIVETrackerForActivity:(IQMotionActivityType)activityType
                           userInfo:(nullable NSDictionary *)userInfo
                           progress:(void (^)(IQTrackPoint * _Nullable p, IQLocationResult locationResult, IQMotionActivityResult motionResult))progressBlock
                         completion:(void (^)(IQTrack * _Nullable t, IQLocationResult locationResult, IQMotionActivityResult motionResult))completionBlock;

/**
 The tracker calls IQPermanentLocation :: stopPermanentMonitoring and IQMotionActivityManager :: stopActivityMonitoring. If there's an active currentTrack, it closes it as well.
 */
- (void)stopTracker;

- (nullable IQTrack *)getTracksWithObjectId:(NSString *)objectId;
- (nullable IQTrack *)getLastCompletedTrack;

- (NSInteger)getCountCompletedTracks;

/**
 IQTrack NSArray sorted by "start_date", ascending = YES.
 */
- (NSArray <IQTrack *> *)getCompletedTracks;
- (NSArray <IQTrack *> *)getTracksBetweenDate:(NSDate *)start_date
                                      andDate:(NSDate *)end_date;

/**
 This method stops the current IQTrack and delete all tracks in the model including their trackPoints.
 */
- (void)deleteTracks;

/**
 This method delete the IQTrack that match with the @param objectId.
 */
- (void)deleteTrackWithObjectId:(NSString *)objectId;

@end

NS_ASSUME_NONNULL_END
