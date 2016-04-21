//
//  IQTracker.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 19/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQTrack;

typedef NS_ENUM(NSInteger, IQTrackerResult) {
    kIQTrackerResultError,
    kIQTrackerResultMotionError,
    kIQTrackerResultLocationError,
    kIQTrackerResultNoResult,
    kIQTrackerResultFound,
};

@interface IQTracker : NSObject

+ (IQTracker *)sharedManager;
- (void)startTrackerForActivity:(NSString *)activityString
                     completion:(void (^)(NSDictionary *track, IQTrackerResult result))completion;

- (void)startLIVETrackerForActivity:(NSString *)activityString
                             update:(void (^)(IQTrack *t, IQTrackerResult result))updateBlock;

- (void)stopTracker;

@end
