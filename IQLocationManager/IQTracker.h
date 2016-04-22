//
//  IQTracker.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 19/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQTrackPoint;

typedef NS_ENUM(NSInteger, IQTrackerResult) {
    kIQTrackerResultError,
    kIQTrackerResultMotionError,
    kIQTrackerResultLocationError,
    kIQTrackerResultNoResult,
    kIQTrackerResultFound,
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

- (void)startTrackerForActivity:(NSString *)activityString
                         update:(void (^)(IQTrackPoint *t, IQTrackerResult result))updateBlock;

- (void)stopTracker;

@end
