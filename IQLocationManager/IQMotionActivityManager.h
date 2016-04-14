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
//    kIQLocationResultNotDetermined,
//    kIQLocationResultSoftDenied,
//    kIQLocationResultSystemDenied,
//    kIQlocationResultAuthorized,
    kIQMotionActivityResultError,
    kIQMotionActivityResultNoResult,
//    kIQLocationResultTimeout,
//    kIQLocationResultIntermediateFound,
    kIQMotionActivityResultFound,
//    kIQLocationResultAlreadyGettingLocation
};

extern const struct IQMotionActivityTypes {
    __unsafe_unretained NSString * stationary;
    __unsafe_unretained NSString * walking;
    __unsafe_unretained NSString * running;
    __unsafe_unretained NSString * automotive;
    __unsafe_unretained NSString * cycling;
    __unsafe_unretained NSString * unknown;
} IQMotionActivityType;

@interface IQMotionActivityManager : NSObject

+ (IQMotionActivityManager *)sharedManager;

- (void)getMotionActivityFromDate:(NSDate *)start_date
                           toDate:(NSDate *)end_date
                       completion:(void(^)(NSArray *activities, IQMotionActivityResult result))completion;

- (void)getMotionActivityWithConfidence:(CMMotionActivityConfidence)confidence
                               fromDate:(NSDate *)start_date
                                 toDate:(NSDate *)end_date
                       forActivityTypes:(NSArray *)activityTypes
                             completion:(void(^)(NSArray *activities, IQMotionActivityResult result))completion;


@end
