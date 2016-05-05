//
//  IQTracker.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 19/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTracker.h"

#import "IQMotionActivityManager.h"
#import "IQPermanentLocation.h"
#import "IQSignificantLocationChanges.h"

#import "IQTrackManaged.h"
#import "IQTrackPointManaged.h"
#import "IQLocationDataSource.h"

#import "IQTrack.i.h"
#import "IQTrackPoint.i.h"

#import <CoreMotion/CoreMotion.h>

@interface IQTracker()

@property (nonatomic, strong) IQTrackManaged        *currentTrack;
@property (nonatomic, copy) void (^completionBlock)(IQTrack *t, IQTrackerResult result);
@property (nonatomic, assign) IQTrackerStatus       status;

@end

@implementation IQTracker

static IQTracker *_iqTracker;

#pragma mark Initialization and destroy calls

+ (IQTracker *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _iqTracker = [[self alloc] init];
    });
    return _iqTracker;
}

- (id)init {
    self = [super init];
    if (self) {
        
        // For applications that support background execution, this method is generally not called when the user quits the application because the application simply moves to the background in that case. However, this method may be called in situations where the application is running in the background (not suspended) and the system needs to terminate it for some reason.        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopTracker)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    self.currentTrack = nil;
    self.completionBlock = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IQTrackerStatus)trackerStatus
{
    return self.status;
}

- (BOOL)isTrackInProcess
{
    [self checkCurrentTrack];
    return self.currentTrack;
}

//- (void)startTrackerForActivity:(NSString *)activityString
//                       progress:(void (^)(IQTrackPoint *t, IQTrackerResult result))progressBlock
//                     completion:(void (^)(IQTrack *t, IQTrackerResult result))completionBlock
//{
//    __block CMMotionActivity *currentActivity;
//    static int deflectionCounter = 0;
//    
//    CLLocationAccuracy desiredAccuracy;
//    CLLocationDistance distanceFilter;
//    CLActivityType activityType;
//    BOOL pausesLocationUpdatesAutomatically;
//    
//    // configure location settings for activity
//    if ([activityString isEqualToString:IQMotionActivityType.automotive]) {
//        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        distanceFilter = 100.f;
//        activityType = CLActivityTypeAutomotiveNavigation;
//        pausesLocationUpdatesAutomatically = NO;
//    
//    } else if ([activityString isEqualToString:IQMotionActivityType.walking] || [activityString isEqualToString:IQMotionActivityType.running]) {
//        desiredAccuracy = kCLLocationAccuracyBest;
//        distanceFilter = 5.f;
//        activityType = CLActivityTypeFitness;
//        pausesLocationUpdatesAutomatically = NO;
//        
//    } else if ([activityString isEqualToString:IQMotionActivityType.cycling]) {
//        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        distanceFilter = 30.f;
//        activityType = CLActivityTypeOtherNavigation;
//        pausesLocationUpdatesAutomatically = NO;
//        
//    } else {
//        // Default == Automotive
//        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        distanceFilter = 100.f;
//        activityType = CLActivityTypeAutomotiveNavigation;
//        pausesLocationUpdatesAutomatically = NO;
//        
//    }
//    
//    self.completionBlock = completionBlock;
//    __block __typeof(self) belf = self;
//    [[IQMotionActivityManager sharedManager] startActivityMonitoringWithUpdateBlock:^(CMMotionActivity *activity, IQMotionActivityResult result) {
//        if (result == kIQMotionActivityResultFound && activity) {
//            if (activityString) {
//                if ([activity containsActivityType:activityString]) {
//                    if (!belf.currentTrack) {
//                        belf.currentTrack = [IQTrack createWithStartDate:activity.startDate
//                                                         andActivityType:activityString
//                                                               inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
//                    }
//                    deflectionCounter = 0;
//                    currentActivity = activity;
//                    if (!belf.locationMonitoringStarted) {
//                        belf.locationMonitoringStarted = YES;
//                        [[IQPermanentLocation sharedManager] startPermanentMonitoringLocationWithSoftAccessRequest:YES
//                                                                                                          accuracy:desiredAccuracy
//                                                                                                    distanceFilter:distanceFilter
//                                                                                                      activityType:activityType
//                                                                                   allowsBackgroundLocationUpdates:YES
//                                                                                pausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically
//                                                                                                            update:^(CLLocation *locationOrNil, IQLocationResult result) {
//                                                                                                                if (locationOrNil && result == kIQLocationResultFound) {
//                                                                                                                    
//                                                                                                                    IQTrackPoint *tp = [IQTrackPoint createWithActivity:currentActivity location:locationOrNil andTrackID:belf.currentTrack.objectID inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
//                                                                                                                    progressBlock(tp, kIQTrackerResultFound);
//                                                                                                                    
//                                                                                                                } else {
//                                                                                                                    if (result == kIQLocationResultSoftDenied || result == kIQLocationResultSystemDenied) {
//                                                                                                                        belf.currentTrack = nil;
//                                                                                                                        [belf stopTracker];
//                                                                                                                        
//                                                                                                                    } else {
//                                                                                                                        progressBlock(nil, kIQTrackerResultLocationError);
//                                                                                                                        
//                                                                                                                    }
//                                                                                                                }
//                                                                                                            }];
//                    }
//                    
//                } else if (currentActivity) {
//                    if ((activity.running || activity.walking || activity.automotive || activity.cycling) && activity.confidence > CMMotionActivityConfidenceLow) {
//                        deflectionCounter++;
//                        if (deflectionCounter == 3) {
//                            // 3 times with another valuable activity with at least ConfidenceMedium -> close current track
//                            [[IQPermanentLocation sharedManager] stopPermanentMonitoring];
//                            belf.locationMonitoringStarted = NO;
//                            currentActivity = nil;
//                            [belf closeCurrentTrack];
//                            
//                        }
//                    } else {
//                        NSTimeInterval seconds = [activity.startDate timeIntervalSinceDate:currentActivity.startDate];
//                        if (seconds > 120) {
//                            // 2 minuts since last correct activity -> close current track
//                            [[IQPermanentLocation sharedManager] stopPermanentMonitoring];
//                            belf.locationMonitoringStarted = NO;
//                            currentActivity = nil;
//                            [belf closeCurrentTrack];
//                            
//                        }
//                    }
//                }
//                
//            } else {
//                if (!belf.currentTrack) {
//                    belf.currentTrack = [IQTrack createWithStartDate:activity.startDate
//                                                     andActivityType:@"all"
//                                                           inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
//                }
//                if (activity.running || activity.walking || activity.automotive || activity.cycling) {
//                    currentActivity = activity;
//                    if (!belf.locationMonitoringStarted) {
//                        belf.locationMonitoringStarted = YES;
//                        [[IQPermanentLocation sharedManager] startPermanentMonitoringLocationWithSoftAccessRequest:YES
//                                                                                                          accuracy:desiredAccuracy
//                                                                                                    distanceFilter:distanceFilter
//                                                                                                      activityType:activityType
//                                                                                   allowsBackgroundLocationUpdates:YES
//                                                                                pausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically
//                                                                                                            update:^(CLLocation *locationOrNil, IQLocationResult result) {
//                                                                                                                if (locationOrNil && result == kIQLocationResultFound) {
//                                                                                                                    
//                                                                                                                    IQTrackPoint *tp = [IQTrackPoint createWithActivity:currentActivity location:locationOrNil andTrackID:belf.currentTrack.objectID inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
//                                                                                                                    progressBlock(tp, kIQTrackerResultFound);
//                                                                                                                    
//                                                                                                                } else {
//                                                                                                                    if (result == kIQLocationResultSoftDenied || result == kIQLocationResultSystemDenied) {
//                                                                                                                        belf.currentTrack = nil;
//                                                                                                                        [belf stopTracker];
//                                                                                                                        
//                                                                                                                    } else {
//                                                                                                                        progressBlock(nil, kIQTrackerResultLocationError);
//                                                                                                                        
//                                                                                                                    }
//                                                                                                                }
//                                                                                                            }];
//                    }
//                }
//            }
//        } else {
//            progressBlock(nil, kIQTrackerResultMotionError);
//            
//        }
//    }];
//}

- (void)startLIVETrackerForActivity:(IQMotionActivityType)activityType
                           userInfo:(nullable NSDictionary *)userInfo
                           progress:(void (^)(IQTrackPoint *p, IQTrackerResult result))progressBlock
                         completion:(void (^)(IQTrack *t, IQTrackerResult result))completionBlock
{
    if (self.currentTrack) {
        NSAssert(NO, @"startTrackerForActivity called twice without call stopTracker before");
        return;
    }
    
    __block CMMotionActivity *lastActivity;
    static int deflectionCounter = 0;
    
    CLLocationAccuracy desiredAccuracy;
    CLLocationDistance distanceFilter;
    CLActivityType clActivityType;
    BOOL pausesLocationUpdatesAutomatically;
    
    self.status = kIQTrackerStatusWorkingAutotracking;
    
    // configure location settings for activity
    if (activityType == kIQMotionActivityTypeAutomotive) {
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 100.f;
        clActivityType = CLActivityTypeAutomotiveNavigation;
        pausesLocationUpdatesAutomatically = NO;
        
    } else if (activityType == kIQMotionActivityTypeWalking || activityType == kIQMotionActivityTypeRunning) {
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 5.f;
        clActivityType = CLActivityTypeFitness;
        pausesLocationUpdatesAutomatically = NO;
        
        // TEST
//        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        distanceFilter = 5.f;
//        clActivityType = CLActivityTypeAutomotiveNavigation;
//        pausesLocationUpdatesAutomatically = NO;
        
    } else if (activityType == kIQMotionActivityTypeCycling) {
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 30.f;
        clActivityType = CLActivityTypeOtherNavigation;
        pausesLocationUpdatesAutomatically = NO;
        
    } else {
        // Default == Automotive
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 100.f;
        clActivityType = CLActivityTypeAutomotiveNavigation;
        pausesLocationUpdatesAutomatically = NO;
        
        self.status = kIQTrackerStatusWorkingManual;
        
    }
    
    self.completionBlock = completionBlock;
    __block __typeof(self) belf = self;
    [[IQPermanentLocation sharedManager] startPermanentMonitoringLocationWithSoftAccessRequest:YES
                                                                                      accuracy:desiredAccuracy
                                                                                distanceFilter:distanceFilter
                                                                                  activityType:clActivityType
                                                               allowsBackgroundLocationUpdates:YES
                                                            pausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically
                                                                                        update:^(CLLocation *locationOrNil, IQLocationResult result) {
                                                                                            
        if (locationOrNil && result == kIQLocationResultFound) {
            [[IQMotionActivityManager sharedManager] startActivityMonitoringWithUpdateBlock:^(CMMotionActivity *activity, IQMotionActivityResult result)
            {
                if (result == kIQMotionActivityResultFound && activity) {
                    if (activityType != kIQMotionActivityTypeAll) { // CASE: AUTOMATIC
                        
                        // CASE: track finished, but it wasn't possible to determine because no location received after motion stop
                        if (lastActivity) {
                            NSTimeInterval seconds = [activity.startDate timeIntervalSinceDate:lastActivity.startDate];
                            if (seconds > 300) {
                                // 5 minuts since last correct activity -> close current track
                                deflectionCounter = 0;
                                lastActivity = nil;
                                [belf closeCurrentTrack];
                                
                            }
                        }
                        
                        if ([self activity:activity containsActivityType:activityType]) {
                            deflectionCounter = 0;
                            lastActivity = activity;
                            
                            __block IQTrackPoint *tp_temp;
                            [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
                                if (!belf.currentTrack) {
                                    belf.currentTrack = [IQTrackManaged createWithStartDate:activity.startDate
                                                                        activityType:activityType
                                                                         andUserInfo:userInfo
                                                                           inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                }
                                IQTrackPointManaged *tp = [IQTrackPointManaged createWithActivity:lastActivity
                                                                           location:locationOrNil
                                                                         andTrackID:belf.currentTrack.objectID
                                                                          inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                
                                tp_temp = [[IQTrackPoint alloc] initWithIQTrackPoint:tp];
                            }];
                            
                            progressBlock(tp_temp, kIQTrackerResultFound);
                            
                        } else if (lastActivity) {
                            // filters
                            if ((activity.running || activity.walking || activity.automotive || (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 && activity.cycling)) && activity.confidence > CMMotionActivityConfidenceLow) {
                                deflectionCounter++;
                                if (deflectionCounter == 3) {
                                    // 3 times with another valuable activity with at least ConfidenceMedium -> close current track
                                    deflectionCounter = 0;
                                    lastActivity = nil;
                                    [belf closeCurrentTrack];
                                    
                                }
                            } else {
                                NSTimeInterval seconds = [activity.startDate timeIntervalSinceDate:lastActivity.startDate];
                                if (seconds > 120) {
                                    // 2 minuts since last correct activity -> close current track
                                    deflectionCounter = 0;
                                    lastActivity = nil;
                                    [belf closeCurrentTrack];
                                    
                                }
                            }

                        }
                    } else { // CASE: MANUAL
                        if (activity.running || activity.walking || activity.automotive || (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 && activity.cycling)) {
                            lastActivity = activity;
                            
                            __block IQTrackPoint *tp_temp;
                            [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
                                if (!belf.currentTrack) {
                                    belf.currentTrack = [IQTrackManaged createWithStartDate:activity.startDate
                                                                        activityType:activityType
                                                                         andUserInfo:userInfo
                                                                           inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                }                                
                                IQTrackPointManaged *tp = [IQTrackPointManaged createWithActivity:lastActivity
                                                                           location:locationOrNil
                                                                         andTrackID:belf.currentTrack.objectID
                                                                          inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                
                                tp_temp = [[IQTrackPoint alloc] initWithIQTrackPoint:tp];
                            }];
                            progressBlock(tp_temp, kIQTrackerResultFound);
                        }
                    }
                } else {
                    progressBlock(nil, kIQTrackerResultMotionError);
                    
                }
                [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
            }];
                                                                                                
        } else {
            if (result == kIQLocationResultSoftDenied || result == kIQLocationResultSystemDenied) {
                belf.currentTrack = nil;
                [belf stopTracker];
                
            } else {
                progressBlock(nil, kIQTrackerResultLocationError);
            }
        }
    }];
}

- (void)startTrackerForActivity:(IQMotionActivityType)activityType
                       userInfo:(nullable NSDictionary *)userInfo
{
    [self startLIVETrackerForActivity:activityType
                             userInfo:userInfo
                             progress:^(IQTrackPoint *t, IQTrackerResult result) {
                                 if (t) {
                                     NSLog(@"%@", [NSString stringWithFormat:@"Point: %li. %@ %@",
                                                   t.order.integerValue,
                                                   [t activityTypeString],
                                                   [NSDateFormatter localizedStringFromDate:t.date
                                                                                  dateStyle:NSDateFormatterShortStyle
                                                                                  timeStyle:NSDateFormatterShortStyle]]);
                                 } else {
                                     NSLog(@"NO POINT: %li", (long)result);
                                 }
                                 
                             } completion:^(IQTrack *t, IQTrackerResult result) {
                                 if (t) {
                                     NSLog(@"\n%@\n%@",
                                           [NSString stringWithFormat:@"activityType: %@ Ended", t.activityType],
                                           [NSString stringWithFormat:@"from: %@\nto: %@",
                                            [NSDateFormatter localizedStringFromDate:t.start_date
                                                                           dateStyle:NSDateFormatterShortStyle
                                                                           timeStyle:NSDateFormatterShortStyle],
                                            [NSDateFormatter localizedStringFromDate:t.end_date
                                                                           dateStyle:NSDateFormatterShortStyle
                                                                           timeStyle:NSDateFormatterShortStyle]]);
                                 } else {
                                     NSLog(@"NO TRACK: %li", (long)result);
                                 }
                                 
                             }];
}

- (void)stopTracker
{
    [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
    [[IQPermanentLocation sharedManager] stopPermanentMonitoring];
    self.status = kIQTrackerStatusStopped;
    [self closeCurrentTrack];
}

- (void)closeCurrentTrack
{
    __block IQTrack *t_temp;
    if (self.currentTrack) {
        __block __typeof(self) belf = self;
        [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
            BOOL result = [belf.currentTrack closeTrackInContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
            NSAssert(result, @"error closing track");
            t_temp = [[IQTrack alloc] initWithIQTrack:belf.currentTrack];
        }];
    }    
    if (self.completionBlock) {
        if (t_temp && t_temp.points.count > 0) {
            self.completionBlock(t_temp, kIQTrackerResultNoResult);
        } else {
            self.completionBlock(t_temp, kIQTrackerResultTrackEnd);
        }
    }
    self.currentTrack = nil;
}

- (void)checkCurrentTrack
{
    if (self.currentTrack && self.currentTrack.activityType != kIQMotionActivityTypeAll) {
        NSArray *points = [self.currentTrack sortedPoints];
        IQTrackPointManaged *lastP = [points lastObject];
        NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:lastP.date];
        if (seconds > 300) {
            // 5 minuts since last correct activity -> close current track
            [self closeCurrentTrack];
        }
    }
}

- (BOOL)activity:(CMMotionActivity *)activity containsActivityType:(IQMotionActivityType)activityType
{
    BOOL result = NO;
    if (activity.walking && activityType == kIQMotionActivityTypeWalking) {
        result = YES;
    }
    if (activity.running && activityType == kIQMotionActivityTypeRunning) {
        result = YES;
    }
    if (activity.automotive && activityType == kIQMotionActivityTypeAutomotive) {
        result = YES;
    }
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 && activity.cycling && activityType == kIQMotionActivityTypeCycling) {
        result = YES;
    }
    return result;
}

#pragma mark - GET Tracks methods
- (NSArray <IQTrack *> *)getCompletedTracks
{
    [self checkCurrentTrack];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IQTrackManaged"];
    request.predicate = [NSPredicate predicateWithFormat:@"end_date != nil"];
    
    __block NSMutableArray *temp = [NSMutableArray array];
    [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        NSArray *tracks = [[IQLocationDataSource sharedDataSource].managedObjectContext executeFetchRequest:request error:&error].copy;
        
        for (IQTrackManaged *iqTrackManaged in tracks) {
            IQTrack *t = [[IQTrack alloc] initWithIQTrack:iqTrackManaged];
            [temp addObject:t];
        }
    }];
    
    return temp.copy;
}

- (NSInteger)getCountCompletedTracks
{
    [self checkCurrentTrack];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IQTrackManaged"];
    request.predicate = [NSPredicate predicateWithFormat:@"end_date != nil"];
    
    __block NSUInteger count = 0;
    [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        count = [[IQLocationDataSource sharedDataSource].managedObjectContext countForFetchRequest:request error:&error];
    }];
    
    return count;
}

- (NSArray <IQTrack *> *)getTracksBetweenDate:(NSDate *)start_date
                                    andDate:(NSDate *)end_date
{
    [self checkCurrentTrack];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IQTrackManaged"];
    request.predicate = [NSPredicate predicateWithFormat:@"end_date != nil AND start_date <= %@ AND end_date >= %@", start_date, end_date];
    
    NSMutableArray *temp = [NSMutableArray array];
    [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        NSArray *tracks = [[IQLocationDataSource sharedDataSource].managedObjectContext executeFetchRequest:request error:&error].copy;
        
        for (IQTrackManaged *iqTrackManaged in tracks) {
            IQTrack *t = [[IQTrack alloc] initWithIQTrack:iqTrackManaged];
            [temp addObject:t];
        }
    }];
    
    return temp.copy;
}

- (IQTrack *)getLastCompletedTrack
{
    NSArray *array = [self getCompletedTracks].copy;
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"end_date" ascending:YES];
    NSArray *temp = [array sortedArrayUsingDescriptors:@[sort]].copy;    
    if (temp.count > 0) {
        return temp.lastObject;
    }
    return nil;
}

#pragma mark - DELETE IQTracks method
- (void)deleteTrackWithObjectId:(NSString *)objectId
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IQTrackManaged"];
    request.predicate = [NSPredicate predicateWithFormat:@"end_date != nil AND objectId == %@", objectId];
    
    [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        NSArray *tracks = [[IQLocationDataSource sharedDataSource].managedObjectContext executeFetchRequest:request error:&error].copy;
        for (IQTrackManaged *iqTrackManaged in tracks) {
            [[IQLocationDataSource sharedDataSource].managedObjectContext deleteObject:iqTrackManaged];
        }
        
        [[IQLocationDataSource sharedDataSource].managedObjectContext save:&error];
    }];
}

- (void)deleteTracks
{
    if (self.currentTrack) {
        [self closeCurrentTrack];
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IQTrackManaged"];
    [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        NSArray *tracks = [[IQLocationDataSource sharedDataSource].managedObjectContext executeFetchRequest:request error:&error].copy;
        
        for (IQTrackManaged *iqTrackManaged in tracks) {
            [[IQLocationDataSource sharedDataSource].managedObjectContext deleteObject:iqTrackManaged];
        }
        
        [[IQLocationDataSource sharedDataSource].managedObjectContext save:&error];        
    }];
}

@end
