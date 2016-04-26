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
 The tracker starts first the IQMotionActivityManager :: startActivityMonitoring and when there's a match starts IQPermanentLocation :: startPermanentMonitoringLocation. When there's a result, create IQTrackPoint.
 
 @fact The tracker result depends on activity
 
 @alert Doesn't working in background
 */
- (void)startTrackerForActivity:(NSString *)activityString
                       progress:(void (^)(IQTrackPoint *t, IQTrackerResult result))progressBlock
                     completion:(void (^)(IQTrack *t, IQTrackerResult result))completionBlock;

/**
 The tracker starts first the IQPermanentLocation :: startPermanentMonitoringLocation and when there's a result, starts IQMotionActivityManager :: startActivityMonitoring. If there's an activity match, create IQTrackPoint.
 
 @fact: The tracker result depends on location
 */
- (void)reverseStartTrackerForActivity:(NSString *)activityString
                              progress:(void (^)(IQTrackPoint *t, IQTrackerResult result))progressBlock
                            completion:(void (^)(IQTrack *t, IQTrackerResult result))completionBlock;

- (void)stopTracker;


- (NSArray *)getCompletedTracks;
- (NSArray *)getTracksBetweenDate:(NSDate *)start_date
                          andDate:(NSDate *)end_date;
- (id)getLastTrack;

@end
