//
//  IQMotionActivityManager.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 14/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQMotionActivityManager.h"

@interface IQMotionActivityManager()

@property (nonatomic, strong) CMMotionActivityManager     *motionActivityManager;

@end

@implementation IQMotionActivityManager

static IQMotionActivityManager *__iqMotionActivityManager;

#pragma mark Initialization and destroy calls

+ (IQMotionActivityManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __iqMotionActivityManager = [[self alloc] init];
    });    
    return __iqMotionActivityManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.motionActivityManager = nil;
}

- (void)startActivityMonitoringWithUpdateBlock:(void(^)(CMMotionActivity *activity, IQMotionActivityResult result))updateBlock
{
    if([CMMotionActivityManager isActivityAvailable]) {
        if (!self.motionActivityManager) {
            self.motionActivityManager = [[CMMotionActivityManager alloc] init];
        }
        [self.motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue]
                                                    withHandler:^(CMMotionActivity * _Nullable activity) {
                                                        if (activity) {
                                                            updateBlock(activity, kIQMotionActivityResultFound);
                                                        } else {
                                                            updateBlock(nil, kIQMotionActivityResultNoResult);
                                                        }
                                                    }];
    } else {
        updateBlock(nil, kIQMotionActivityResultNotAvailable);
    }
}

- (void)stopActivityMonitoring
{
    [self.motionActivityManager stopActivityUpdates];
}

- (void)getMotionActivityFromDate:(NSDate *)start_date
                           toDate:(NSDate *)end_date
                       completion:(void(^)(NSArray *activities, IQMotionActivityResult result))completion
{
    [self getMotionActivityWithConfidence:CMMotionActivityConfidenceMedium
                                 fromDate:start_date
                                   toDate:end_date
                         forActivityTypes:nil
                               completion:^(NSArray *activities, IQMotionActivityResult result) {
                                   completion(activities, result);
                               }];
}

- (void)getMotionActivityWithConfidence:(CMMotionActivityConfidence)confidence
                               fromDate:(NSDate *)start_date
                                 toDate:(NSDate *)end_date
                       forActivityTypes:(NSArray *)activityTypes
                             completion:(void(^)(NSArray *activities, IQMotionActivityResult result))completion
{
    if([CMMotionActivityManager isActivityAvailable]) {
        if (!self.motionActivityManager) {
            self.motionActivityManager = [[CMMotionActivityManager alloc] init];
        }
        [self.motionActivityManager queryActivityStartingFromDate:start_date
                                                           toDate:end_date
                                                          toQueue:[NSOperationQueue mainQueue]
                                                      withHandler:^(NSArray *activities, NSError *error){
                                                          if (!error) {
                                                              if (!activityTypes) {
                                                                  completion(activities, (activities.count > 0 ?:kIQMotionActivityResultNoResult | kIQMotionActivityResultFound));
                                                              } else {
                                                                  NSPredicate *predicateConf = [NSPredicate predicateWithFormat:@"confidence >= %i", confidence];
                                                                  NSArray *temp = [activities filteredArrayUsingPredicate:predicateConf].copy;
                                                                  if (temp.count > 0) {
                                                                      NSMutableArray *preArray = [NSMutableArray array];
                                                                      for (NSString *str in activityTypes) {
                                                                          NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ == YES", str]];
                                                                          [preArray addObject:predicate];
                                                                      }
                                                                      NSCompoundPredicate *cmpPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:preArray];
                                                                      NSArray *results = [temp filteredArrayUsingPredicate:cmpPredicate];
                                                                      completion(results, (results.count > 0 ?:kIQMotionActivityResultNoResult | kIQMotionActivityResultFound));
                                              
                                                                  } else {
                                                                      completion(nil, kIQMotionActivityResultNoResult);
                                                                  }
                                                              }
                                                          } else {
                                                              completion(nil, kIQMotionActivityResultError);
                                                          }
                                                      }];
    } else {
        completion(nil, kIQMotionActivityResultNotAvailable);
    }
}

- (void)getMotionActivityStatus:(void(^)(IQMotionActivityResult result))completion
{
    if([CMMotionActivityManager isActivityAvailable]) {
        if (!self.motionActivityManager) {
            self.motionActivityManager = [[CMMotionActivityManager alloc] init];
        }
        [self.motionActivityManager queryActivityStartingFromDate:[NSDate date]
                                                           toDate:[NSDate date]
                                                          toQueue:[NSOperationQueue mainQueue]
                                                      withHandler:^(NSArray *activities, NSError *error){
                                                          if (!error) {
                                                              completion(kIQMotionActivityResultAvailable);
                                                              
                                                          } else {
                                                              if (error.code == CMErrorMotionActivityNotAuthorized) {
                                                                  completion(kIQMotionActivityResultNotAuthorized);
                                                              } else {
                                                                  completion(kIQMotionActivityResultError);
                                                              }
                                                              
                                                          }
                                                      }];
    } else {
        completion(kIQMotionActivityResultNotAvailable);
    }
}

@end
