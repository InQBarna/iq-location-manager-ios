//
//  IQMotionActivityManager.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 14/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreMotion/CoreMotion.h>

typedef NS_ENUM(NSInteger, IQMotionActivityResult) {
    kIQMotionActivityResultNotAvailable,
    kIQMotionActivityResultError,
    kIQMotionActivityResultNoResult,
    kIQMotionActivityResultFound,
};

@interface IQMotionActivityManager : NSObject

+ (IQMotionActivityManager *)sharedManager;

- (void)startActivityMonitoringWithUpdateBlock:(void(^)(CMMotionActivity *activity, IQMotionActivityResult result))updateBlock;

- (void)stopActivityMonitoring;

- (void)getMotionActivityFromDate:(NSDate *)start_date
                           toDate:(NSDate *)end_date
                       completion:(void(^)(NSArray *activities, IQMotionActivityResult result))completion;

- (void)getMotionActivityWithConfidence:(CMMotionActivityConfidence)confidence
                               fromDate:(NSDate *)start_date
                                 toDate:(NSDate *)end_date
                       forActivityTypes:(NSArray *)activityTypes
                             completion:(void(^)(NSArray *activities, IQMotionActivityResult result))completion;

@end
