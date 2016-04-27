//
//  IQTracker.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 19/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQTrackPoint, IQTrack;

typedef NS_ENUM(NSInteger, IQTrackerResult) {
    kIQTrackerResultError,
    kIQTrackerResultMotionError,
    kIQTrackerResultLocationError,
    kIQTrackerResultNoResult,
    kIQTrackerResultFound,
    kIQTrackerResultTrackEnd,
};

extern const struct IQMotionActivityTypes {
    __unsafe_unretained NSString * stationary;
    __unsafe_unretained NSString * walking;
    __unsafe_unretained NSString * running;
    __unsafe_unretained NSString * automotive;
    __unsafe_unretained NSString * cycling;
    __unsafe_unretained NSString * unknown;
} IQMotionActivityType;

@interface IQTracker : NSObject

+ (IQTracker *)sharedManager;


/**
 The tracker starts first the IQPermanentLocation :: startPermanentMonitoringLocation and when there's a result, starts IQMotionActivityManager :: startActivityMonitoring. If there's an activity match, create IQTrackPoint.
 
 @fact: The tracker result depends on location
 
 @param activityString is an IQMotionActivityType. If it's nil the tracker will track every valuable activity: running || walking || automotive || cycling.
 Doesn't expect activityString == unknown || activityString == stationary, don't be that bright spark, huh?
 */
- (void)startLIVETrackerForActivity:(NSString *)activityString
                           progress:(void (^)(IQTrackPoint *p, IQTrackerResult result))progressBlock
                         completion:(void (^)(IQTrack *t, IQTrackerResult result))completionBlock;
- (void)startTrackerForActivity:(NSString *)activityString;

/**
 The tracker calls IQPermanentLocation :: stopPermanentMonitoring and IQMotionActivityManager :: stopActivityMonitoring. If there's an active currentTrack, it closes it. */
- (void)stopTracker;


- (id)getLastTrack;
- (NSArray *)getCompletedTracks;
- (NSArray *)getTracksBetweenDate:(NSDate *)start_date
                          andDate:(NSDate *)end_date;

@end
