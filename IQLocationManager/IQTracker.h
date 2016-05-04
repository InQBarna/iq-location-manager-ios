//
//  IQTracker.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 19/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQTrack, IQTrackPoint, Track, TrackPoint;

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
 The tracker starts first the IQPermanentLocation :: startPermanentMonitoringLocation and when there's a result, starts IQMotionActivityManager :: startActivityMonitoring. When there's an activity match, if no currentTrack created, create one and then create a TrackPoint related to that Track. If currentTrack already created, just create a new TrackPoint and relates it to the currentTrack.
 
 @fact: The tracker's result depends on location.
 
 @param activityType is an IQMotionActivityType.
 If activityType != kIQMotionActivityTypeAll, autotracking mode starts: the IQTracker will track this activityType starting and stopping by itself, creating Tracks when that kind of activity starts or stops.
 If activityType == kIQMotionActivityTypeAll, manual mode starts: the tracker will track every valuable activity (running && walking && automotive && cycling), considering all in the same Track and the Track will stop when stopTracker method is called.
 @param progressBlock will be called with the current trackPoint of the current track.
 @param completionBlock will be called with the finished track.
 */
- (void)startTrackerForActivity:(IQMotionActivityType)activityType
                       userInfo:(nullable NSDictionary *)userInfo;

- (void)startLIVETrackerForActivity:(IQMotionActivityType)activityType
                           userInfo:(nullable NSDictionary *)userInfo
                           progress:(void (^)(TrackPoint * _Nullable p, IQTrackerResult result))progressBlock
                         completion:(void (^)(Track * _Nullable t, IQTrackerResult result))completionBlock;

/**
 The tracker calls IQPermanentLocation :: stopPermanentMonitoring and IQMotionActivityManager :: stopActivityMonitoring. If there's an active currentTrack, it closes it as well.
 */
- (void)stopTracker;

- (nullable Track *)getLastCompletedTrack;
- (NSArray <Track *> *)getCompletedTracks;
- (NSInteger)getCountCompletedTracks;
- (NSArray <Track *> *)getTracksBetweenDate:(NSDate *)start_date
                                    andDate:(NSDate *)end_date;

/**
 This method stops the current track and delete all tracks in the model including their trackPoints.
 */
- (void)deleteTracks;

/**
 This method delete the track that match with the @param objectId.
 */
- (void)deleteTrackWithObjectId:(NSString *)objectId;

@end

NS_ASSUME_NONNULL_END
