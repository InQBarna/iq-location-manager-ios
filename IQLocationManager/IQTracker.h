//
//  IQTracker.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 19/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQTrackPoint, IQTrack, Track, TrackPoint;

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

extern const struct IQMotionActivityTypes {
    __unsafe_unretained NSString * walking;
    __unsafe_unretained NSString * running;
    __unsafe_unretained NSString * automotive;
    __unsafe_unretained NSString * cycling;
} IQMotionActivityType;

@interface IQTracker : NSObject

+ (IQTracker *)sharedManager;

/**
 Returns IQTrackerStatus: kIQTrackerStatusStopped || kIQTrackerStatusWorkingAutotracking || kIQTrackerStatusWorkingManual 
 */
- (IQTrackerStatus)trackerStatus;

/**
 The tracker starts first the IQPermanentLocation :: startPermanentMonitoringLocation and when there's a result, starts IQMotionActivityManager :: startActivityMonitoring. If there's an activity match, create IQTrackPoint.
 
 @fact: The tracker result depends on location
 
 @param activityString is an IQMotionActivityType. If it's nil the tracker will track every valuable activity: running && walking && automotive && cycling.
 @param progress block will be called with the current trackPoint of the current track
 @param completion block will be called with the finished track
 */
- (void)startTrackerForActivity:(nullable NSString *)activityString;

- (void)startLIVETrackerForActivity:(nullable NSString *)activityString
                           progress:(void (^)(TrackPoint * _Nullable p, IQTrackerResult result))progressBlock
                         completion:(void (^)(Track * _Nullable t, IQTrackerResult result))completionBlock;

/**
 The tracker calls IQPermanentLocation :: stopPermanentMonitoring and IQMotionActivityManager :: stopActivityMonitoring. If there's an active currentTrack, it closes it. 
 */
- (void)stopTracker;

- (nullable Track *)getLastCompletedTrack;
- (NSArray *)getCompletedTracks;
- (NSArray *)getTracksBetweenDate:(NSDate *)start_date
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
