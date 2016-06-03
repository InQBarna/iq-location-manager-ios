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
@property (nonatomic, copy) void (^completionBlock)(IQTrack *t, IQLocationResult locationResult, IQMotionActivityResult motionResult);
@property (nonatomic, assign) IQTrackerStatus       status;

// These properties are used in conjunction for authorize CMMotionActivity tracking
@property (nonatomic, assign) BOOL                  motionAuthorized;
@property (nonatomic, assign) BOOL                  motionRequested;
//

@end

@implementation IQTracker

static IQTracker *__iqTracker;

#pragma mark Initialization and destroy calls

+ (IQTracker *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __iqTracker = [[self alloc] init];
    });
    return __iqTracker;
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

- (BOOL)isTrackInProgress
{
    [self checkCurrentTrack];
    return self.currentTrack;
}

- (void)startForRealWithActivity:(IQMotionActivityType)activityType
                        userInfo:(nullable NSDictionary *)userInfo
                        progress:(void (^)(IQTrackPoint * _Nullable p, IQLocationResult locationResult, IQMotionActivityResult motionResult))progressBlock
                      completion:(void (^)(IQTrack * _Nullable t, IQLocationResult locationResult, IQMotionActivityResult motionResult))completionBlock {
    [self startMonitoringActivity:activityType
                         userInfo:userInfo
                         progress:progressBlock
                       completion:completionBlock];
}

- (void)startLIVETrackerForActivity:(IQMotionActivityType)activityType
                           userInfo:(nullable NSDictionary *)userInfo
                           progress:(void (^)(IQTrackPoint * _Nullable p, IQLocationResult locationResult, IQMotionActivityResult motionResult))progressBlock
                         completion:(void (^)(IQTrack * _Nullable t, IQLocationResult locationResult, IQMotionActivityResult motionResult))completionBlock
{
    [self checkCurrentTrack];
    
    if (self.currentTrack) {
        NSAssert(NO, @"startTrackerForActivity called twice without call stopTracker before");
        if (self.status == kIQTrackerStatusStopped) {
            [self closeCurrentTrack];
        }
        return;
    }
    
    if (activityType == kIQMotionActivityTypeNone || activityType == kIQMotionActivityTypeAll) {
        self.status = kIQTrackerStatusWorkingManual;
    } else {
        self.status = kIQTrackerStatusWorkingAutotracking;
    }
    
    if (activityType != kIQMotionActivityTypeNone && !(self.motionAuthorized && self.motionRequested)) {
        [[IQMotionActivityManager sharedManager] startActivityMonitoringWithUpdateBlock:^(CMMotionActivity * _Nullable activity, IQMotionActivityResult result) {
            [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
            self.motionRequested = YES;
            if (self.motionAuthorized && self.motionRequested) {
                [self startMonitoringActivity:activityType
                                     userInfo:userInfo
                                     progress:progressBlock
                                   completion:completionBlock];
            }
        }];
        [[IQMotionActivityManager sharedManager] getMotionActivityStatus:^(IQMotionActivityResult motionResult)
        {
            if (motionResult == kIQMotionActivityResultAvailable) {
                self.motionAuthorized = YES;
                if (self.motionAuthorized && self.motionRequested) {
                    [self startMonitoringActivity:activityType
                                         userInfo:userInfo
                                         progress:progressBlock
                                       completion:completionBlock];
                }
                
            } else if (motionResult == kIQMotionActivityResultNotAvailable || motionResult == kIQMotionActivityResultNotAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(nil, -1, motionResult);
                });
                self.status = kIQTrackerStatusStopped;
                
            } else {
                NSAssert(NO, @"No contemplated error");
            }
        }];
        
    } else {
        [self startMonitoringActivity:activityType
                             userInfo:userInfo
                             progress:progressBlock
                           completion:completionBlock];
    }
}

- (void)startMonitoringActivity:(IQMotionActivityType)activityType
                       userInfo:(nullable NSDictionary *)userInfo
                       progress:(void (^)(IQTrackPoint * _Nullable p, IQLocationResult locationResult, IQMotionActivityResult motionResult))progressBlock
                     completion:(void (^)(IQTrack * _Nullable t, IQLocationResult locationResult, IQMotionActivityResult motionResult))completionBlock
{
    NSParameterAssert(progressBlock);
    NSParameterAssert(completionBlock);
    __block CLLocation *lastLocation;
    __block CMMotionActivity *lastActivity;
    static int deflectionCounter = 0;
    
    CLLocationAccuracy desiredAccuracy;
    CLLocationDistance distanceFilter;
    CLActivityType clActivityType;
    BOOL pausesLocationUpdatesAutomatically;
    
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
        desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        distanceFilter = 5.f;
        clActivityType = CLActivityTypeAutomotiveNavigation;
        pausesLocationUpdatesAutomatically = NO;
        
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
        
    }
    
    self.completionBlock = completionBlock;
    [[IQPermanentLocation sharedManager] startPermanentMonitoringLocationWithSoftAccessRequest:YES
                                                                                      accuracy:desiredAccuracy
                                                                                distanceFilter:distanceFilter
                                                                                  activityType:clActivityType
                                                               allowsBackgroundLocationUpdates:YES
                                                            pausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically
                                                                                        update:^(CLLocation *locationOrNil, IQLocationResult locationResult) {
                                                                                            
    if (locationOrNil && locationResult == kIQLocationResultFound) {
        
        if (lastLocation && [lastLocation distanceFromLocation:locationOrNil] < 3.0) { // discard location if it has not changed significantly
        
            return;
        }
        lastLocation = locationOrNil;
        if (activityType != kIQMotionActivityTypeNone) {
            
            [[IQMotionActivityManager sharedManager] startActivityMonitoringWithUpdateBlock:^(CMMotionActivity *activity, IQMotionActivityResult motionResult)
             {
                 if (motionResult == kIQMotionActivityResultFound && activity) {
                                                                                                             
                     if (activityType != kIQMotionActivityTypeAll) { // CASE: AUTOMATIC
                                                                                                                 
                         // CASE: track finished, but it wasn't possible to determine because no location received after motion stop
                         if (lastActivity) {
                             NSTimeInterval seconds = [activity.startDate timeIntervalSinceDate:lastActivity.startDate];
                             if (seconds > 300) {
                                 // 5 minuts since last correct activity -> close current track
                                 deflectionCounter = 0;
                                 lastActivity = nil;
                                 [self closeCurrentTrack];
                             }
                         }
                                                                                                                 
                         if ([self activity:activity containsActivityType:activityType]) {
                             deflectionCounter = 0;
                             lastActivity = activity;
                                                                                                                     
                             __block IQTrackPoint *tp_temp;
                             [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
                                 if (!self.currentTrack) {
                                     self.currentTrack = [IQTrackManaged createWithStartDate:activity.startDate
                                                                                activityType:activityType
                                                                                 andUserInfo:userInfo
                                                                                   inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                 }
                                 IQTrackPointManaged *tp = [IQTrackPointManaged createWithActivity:lastActivity
                                                                                          location:locationOrNil
                                                                                        andTrackID:self.currentTrack.objectID
                                                                                         inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                                                                                                         
                                 tp_temp = [[IQTrackPoint alloc] initWithIQTrackPoint:tp];
                             }];
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 progressBlock(tp_temp, kIQLocationResultFound, kIQMotionActivityResultFound);
                             });
                                                                                                                     
                         } else if (lastActivity) {
                             // filters
                             if ((activity.running || activity.walking || activity.automotive || (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 && activity.cycling)) && activity.confidence > CMMotionActivityConfidenceLow) {
                                 deflectionCounter++;
                                 if (deflectionCounter == 3) {
                                     // 3 times with another valuable activity with at least ConfidenceMedium -> close current track
                                     deflectionCounter = 0;
                                     lastActivity = nil;
                                     [self closeCurrentTrack];
                                 }
                                                                                                                         
                             } else {
                                 NSTimeInterval seconds = [activity.startDate timeIntervalSinceDate:lastActivity.startDate];
                                 if (seconds > 300) {
                                     // 5 minuts since last correct activity -> close current track
                                     deflectionCounter = 0;
                                     lastActivity = nil;
                                     [self closeCurrentTrack];
                                 }
                             }
                                                                                                                     
                         }
                     } else { // CASE: MANUAL WITH ACTIVITY
                         if (activity.running || activity.walking || activity.automotive ||
                             (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 && activity.cycling)) {
                             lastActivity = activity;
                                                                                                                     
                             __block IQTrackPoint *tp_temp;
                             [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
                                 if (!self.currentTrack) {
                                     self.currentTrack = [IQTrackManaged createWithStartDate:activity.startDate
                                                                                activityType:activityType
                                                                                 andUserInfo:userInfo
                                                                                   inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                 }
                                 IQTrackPointManaged *tp = [IQTrackPointManaged createWithActivity:lastActivity
                                                                                          location:locationOrNil
                                                                                        andTrackID:self.currentTrack.objectID
                                                                                         inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                                                                                                         
                                 tp_temp = [[IQTrackPoint alloc] initWithIQTrackPoint:tp];
                             }];
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 progressBlock(tp_temp, locationResult, motionResult);
                             });
                         }
                     }
                 } else {
                     
                     if (motionResult == kIQMotionActivityResultNotAvailable || motionResult == kIQMotionActivityResultNotAuthorized) {
                         NSAssert(!self.currentTrack, @"currentTrack must be nil");
                         [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
                         [[IQPermanentLocation sharedManager] stopPermanentMonitoring];
                         self.status = kIQTrackerStatusStopped;
                         dispatch_async(dispatch_get_main_queue(), ^{
                             completionBlock(nil, locationResult, motionResult);
                         });
                         
                     } else {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             progressBlock(nil, locationResult, motionResult);
                         });
                         
                     }
                     
                 }
                 [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
             }];
                                                                                                    
        } else { // CASE: MANUAL WITHOUT ACTIVITY
            __block IQTrackPoint *tp_temp;
            [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
                if (!self.currentTrack) {
                    self.currentTrack = [IQTrackManaged createWithStartDate:locationOrNil.timestamp
                                                               activityType:activityType
                                                                andUserInfo:userInfo
                                                                  inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                }
                IQTrackPointManaged *tp = [IQTrackPointManaged createWithLocation:locationOrNil
                                                                       andTrackID:self.currentTrack.objectID
                                                                        inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                                                                                                        
                tp_temp = [[IQTrackPoint alloc] initWithIQTrackPoint:tp];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                progressBlock(tp_temp, locationResult, -1);
            });
        }
                                                                                                
    } else {
        
        if (locationResult == kIQLocationResultSoftDenied ||
            locationResult == kIQLocationResultSystemDenied ||
            locationResult == kIQLocationResultNotEnabled) {
            NSAssert(!self.currentTrack, @"currentTrack must be nil");
            [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
            [[IQPermanentLocation sharedManager] stopPermanentMonitoring];
            self.status = kIQTrackerStatusStopped;
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil, locationResult, -1);
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressBlock(nil, locationResult, -1);
            });
        }
    }
    }];
}

- (void)startTrackerForActivity:(IQMotionActivityType)activityType
                       userInfo:(nullable NSDictionary *)userInfo
{
    [self startLIVETrackerForActivity:activityType
                             userInfo:userInfo
                             progress:^(IQTrackPoint * _Nullable p, IQLocationResult locationResult, IQMotionActivityResult motionResult) {
                                 if (p) {
                                     NSLog(@"%@", [NSString stringWithFormat:@"Point: %li. %@ %@",
                                                   p.order.integerValue,
                                                   [p activityTypeString],
                                                   [NSDateFormatter localizedStringFromDate:p.date
                                                                                  dateStyle:NSDateFormatterShortStyle
                                                                                  timeStyle:NSDateFormatterShortStyle]]);
                                 } else {
                                     NSLog(@"NO POINT: %li - %li", (long)locationResult, (long)motionResult);
                                 }
                             } completion:^(IQTrack * _Nullable t, IQLocationResult locationResult, IQMotionActivityResult motionResult) {
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
                                     NSLog(@"NO TRACK: %li - %li", (long)locationResult, (long)motionResult);
                                 }
                             }];
}

- (void)stopTracker
{
    [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
    [[IQPermanentLocation sharedManager] stopPermanentMonitoring];
    self.status = kIQTrackerStatusStopped;
    [self closeCurrentTrack];
    NSAssert(self.currentTrack == nil, @"track should be nil");
}

- (void)closeCurrentTrack
{
    __block IQTrack *t_temp;
    if (self.currentTrack) {
        [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
            BOOL result = [self.currentTrack closeTrackInContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
            NSAssert(result, @"error closing track");
            t_temp = [[IQTrack alloc] initWithIQTrack:self.currentTrack];
        }];
    }
    
    // Delete track if points < 3
    if (t_temp.points.count < 3) {
        [self deleteTrackWithObjectId:t_temp.objectId];
        t_temp = nil;
    }
    
    if (self.completionBlock) {
        if (t_temp && t_temp.points.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionBlock(t_temp, kIQLocationResultFound, kIQMotionActivityResultFound);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionBlock(t_temp, kIQLocationResultNoResult, kIQMotionActivityResultNoResult);
            });
        }
    }
    self.currentTrack = nil;
}

- (void)checkCurrentTrack
{
    if (self.currentTrack &&
        (self.currentTrack.activityType.integerValue != kIQMotionActivityTypeNone ||
         self.currentTrack.activityType.integerValue != kIQMotionActivityTypeAll)) {
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

#pragma mark - GET IQTracks methods
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
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"start_date" ascending:YES];
    temp = [temp sortedArrayUsingDescriptors:@[sort]].copy;
    
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
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"start_date" ascending:YES];
    temp = [temp sortedArrayUsingDescriptors:@[sort]].copy;
    
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

- (IQTrack *)getTracksWithObjectId:(NSString *)objectId
{   
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IQTrackManaged"];
    request.predicate = [NSPredicate predicateWithFormat:@"end_date != nil AND objectId == %@", objectId];
    request.fetchLimit = 1;
    
    __block IQTrack *t;
    [[IQLocationDataSource sharedDataSource].managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        NSArray *tracks = [[IQLocationDataSource sharedDataSource].managedObjectContext executeFetchRequest:request error:&error].copy;
        
        if (tracks.count > 0) {
            t = [[IQTrack alloc] initWithIQTrack:tracks.firstObject];
        }
    }];
    
    return t;
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
