//
//  IQMotionActivityManager.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 14/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQMotionActivityManager.h"

#import "NSLogger.h"

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
    [[NSLogger shared] log:NSStringFromSelector(_cmd)
                properties:@{ @"line": @(__LINE__) }
                     error:NO];
    self.motionActivityManager = nil;
}

- (void)startActivityMonitoringWithUpdateBlock:(void(^)(CMMotionActivity *activity, IQMotionActivityResult result))updateBlock
{
    if([CMMotionActivityManager isActivityAvailable]) {
        [[NSLogger shared] log:NSStringFromSelector(_cmd)
                    properties:@{ @"line": @(__LINE__),
                                  @"case": @"[CMMotionActivityManager isActivityAvailable]" }
                         error:NO];
        if (!self.motionActivityManager) {
            [[NSLogger shared] log:NSStringFromSelector(_cmd)
                        properties:@{ @"line": @(__LINE__),
                                      @"case": @"!self.motionActivityManager" }
                             error:NO];
            self.motionActivityManager = [[CMMotionActivityManager alloc] init];
        } else {
            [[NSLogger shared] log:NSStringFromSelector(_cmd)
                        properties:@{ @"line": @(__LINE__),
                                      @"case": @"self.motionActivityManager" }
                             error:NO];
        }
        [self.motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue]
                                                    withHandler:^(CMMotionActivity * _Nullable activity) {
                                                        [[NSLogger shared] log:NSStringFromSelector(_cmd)
                                                                    properties:@{ @"line": @(__LINE__),
                                                                                  @"activity": activity?:@"nil" }
                                                                         error:NO];
                                                        if (activity) {
                                                            updateBlock(activity, kIQMotionActivityResultFound);
                                                        } else {
                                                            [[NSLogger shared] log:NSStringFromSelector(_cmd)
                                                                        properties:@{ @"line": @(__LINE__),
                                                                                      @"case": @"activity == nil" }
                                                                             error:YES];
                                                            updateBlock(nil, kIQMotionActivityResultNoResult);
                                                        }
                                                    }];
    } else {
        [[NSLogger shared] log:NSStringFromSelector(_cmd)
                    properties:@{ @"line": @(__LINE__),
                                  @"case": @"![CMMotionActivityManager isActivityAvailable]" }
                         error:NO];
        updateBlock(nil, kIQMotionActivityResultNotAvailable);
    }
}

- (void)stopActivityMonitoring
{
    [[NSLogger shared] log:NSStringFromSelector(_cmd)
                properties:@{ @"line": @(__LINE__) }
                     error:NO];
    [self.motionActivityManager stopActivityUpdates];
}

- (void)getMotionActivityFromDate:(NSDate *)start_date
                           toDate:(NSDate *)end_date
                       completion:(void(^)(NSArray *activities, IQMotionActivityResult result))completion
{
    [[NSLogger shared] log:NSStringFromSelector(_cmd)
                properties:@{ @"line": @(__LINE__),
                              @"FromDate": start_date?:@"nil",
                              @"toDate": end_date?:@"nil" }
                     error:NO];
    [self getMotionActivityWithConfidence:CMMotionActivityConfidenceMedium
                                 fromDate:start_date
                                   toDate:end_date
                         forActivityTypes:nil
                               completion:^(NSArray *activities, IQMotionActivityResult result) {
                                   [[NSLogger shared] log:NSStringFromSelector(_cmd)
                                               properties:@{ @"line": @(__LINE__),
                                                             @"activities": activities?:@"nil",
                                                             @"result": @(result) }
                                                    error:NO];
                                   completion(activities, result);
                               }];
}

- (void)getMotionActivityWithConfidence:(CMMotionActivityConfidence)confidence
                               fromDate:(NSDate *)start_date
                                 toDate:(NSDate *)end_date
                       forActivityTypes:(NSArray *)activityTypes
                             completion:(void(^)(NSArray *activities, IQMotionActivityResult result))completion
{
    [[NSLogger shared] log:NSStringFromSelector(_cmd)
                properties:@{ @"line": @(__LINE__),
                              @"Confidence": @(confidence),
                              @"fromDate": start_date?:@"nil",
                              @"toDate": end_date?:@"nil",
                              @"forActivityTypes": activityTypes?:@"nil",
                              @"completion": completion == nil ? @"nil" : @"block" }
                     error:NO];
    if([CMMotionActivityManager isActivityAvailable]) {
        [[NSLogger shared] log:NSStringFromSelector(_cmd)
                    properties:@{ @"line": @(__LINE__),
                                  @"case": @"[CMMotionActivityManager isActivityAvailable]" }
                         error:NO];
        if (!self.motionActivityManager) {
            [[NSLogger shared] log:NSStringFromSelector(_cmd)
                        properties:@{ @"line": @(__LINE__),
                                      @"case": @"!self.motionActivityManager" }
                             error:NO];
            self.motionActivityManager = [[CMMotionActivityManager alloc] init];
        } else {
            [[NSLogger shared] log:NSStringFromSelector(_cmd)
                        properties:@{ @"line": @(__LINE__),
                                      @"case": @"self.motionActivityManager" }
                             error:NO];
        }
        [self.motionActivityManager queryActivityStartingFromDate:start_date
                                                           toDate:end_date
                                                          toQueue:[NSOperationQueue mainQueue]
                                                      withHandler:^(NSArray *activities, NSError *error){
                                                          [[NSLogger shared] log:NSStringFromSelector(_cmd)
                                                                      properties:@{ @"line": @(__LINE__),
                                                                                    @"activities": activities?:@"nil",
                                                                                    @"error": error?:@"nil" }
                                                                           error:(error != nil)];
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
                                                                      [[NSLogger shared] log:NSStringFromSelector(_cmd)
                                                                                  properties:@{ @"line": @(__LINE__),
                                                                                                @"case": @"temp.count <= 0" }
                                                                                       error:YES];
                                                                      completion(nil, kIQMotionActivityResultNoResult);
                                                                  }
                                                              }
                                                          } else {
                                                              completion(nil, kIQMotionActivityResultError);
                                                          }
                                                      }];
    } else {
        [[NSLogger shared] log:NSStringFromSelector(_cmd)
                    properties:@{ @"line": @(__LINE__),
                                  @"case": @"![CMMotionActivityManager isActivityAvailable]" }
                         error:NO];
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
