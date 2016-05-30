//
//  IQPermanentLocation.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 19/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQPermanentLocation.h"

#import "NSLogger.h"

@interface IQPermanentLocation() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager     *locationManager;
@property (nonatomic, copy) void (^updateBlock)(CLLocation *locationOrNil, IQLocationResult result);

@end

@implementation IQPermanentLocation

static IQPermanentLocation *__iqPermanentLocation;

#pragma mark Initialization and destroy calls

+ (IQPermanentLocation *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __iqPermanentLocation = [[self alloc] init];
    });
    return __iqPermanentLocation;
}

- (id)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[NSLogger shared] log:NSStringFromSelector(_cmd)
                properties:@{ @"line": @(__LINE__) }
                     error:NO];
    self.locationManager = nil;
    self.updateBlock = nil;
}

- (void)startPermanentMonitoringLocationWithSoftAccessRequest:(BOOL)softAccessRequest
                                                     accuracy:(CLLocationAccuracy)desiredAccuracy
                                               distanceFilter:(CLLocationDistance)distanceFilter
                                                 activityType:(CLActivityType)activityType
                              allowsBackgroundLocationUpdates:(BOOL)allowsBackgroundLocationUpdates
                           pausesLocationUpdatesAutomatically:(BOOL)pausesLocationUpdatesAutomatically
                                                       update:(void (^)(CLLocation *locationOrNil, IQLocationResult result))updateBlock
{
    [[NSLogger shared] log:NSStringFromSelector(_cmd)
                properties:@{ @"line": @(__LINE__),
                              @"softAccessRequest": @(softAccessRequest),
                              @"accuracy": @(desiredAccuracy),
                              @"distanceFilter": @(distanceFilter),
                              @"activityType": @(activityType),
                              @"allowsBackgroundLocationUpdates": @(allowsBackgroundLocationUpdates),
                              @"pausesLocationUpdatesAutomatically": @(pausesLocationUpdatesAutomatically),
                              @"update": (updateBlock == nil ? @"nil" : @"block") }
                     error:NO];
    self.locationManager.desiredAccuracy = desiredAccuracy;
    self.locationManager.distanceFilter = distanceFilter;
    self.locationManager.activityType = activityType;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4) {
        if (allowsBackgroundLocationUpdates) {
            BOOL plistCheck = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"] containsObject:@"location"];
            NSAssert(plistCheck, @"Apps that want to receive location updates when suspended must include:\n\"UIBackgroundModes\" key with \"location\" value\nin their app’s Info.plist file");
            self.locationManager.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates;
        } else {
            [[NSLogger shared] log:NSStringFromSelector(_cmd)
                        properties:@{ @"line": @(__LINE__),
                                      @"case": @"!allowsBackgroundLocationUpdates" }
                             error:NO];
        }
    } else {
        [[NSLogger shared] log:NSStringFromSelector(_cmd)
                    properties:@{ @"line": @(__LINE__),
                                  @"case": @"floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_8_4" }
                         error:NO];
    }
    
    self.locationManager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically;
    self.updateBlock = updateBlock;
    
    __weak __typeof(self) welf = self;
    if ([[IQLocationPermissions sharedManager] getLocationStatus] == kIQLocationResultNotDetermined ||
        [[IQLocationPermissions sharedManager] getLocationStatus] == kIQLocationResultSoftDenied) {
        [[IQLocationPermissions sharedManager] requestLocationPermissionsForManager:self.locationManager
                                                              withSoftAccessRequest:softAccessRequest
                                                                      andCompletion:^(IQLocationResult result) {
                                                                          if (result == kIQlocationResultAuthorized) {
                                                                              
                                                                              [welf startMonitoringUpdates];
                                                                          } else {
                                                                              updateBlock(nil, result);
                                                                          }
                                                                      }];
        
    } else if ([[IQLocationPermissions sharedManager] getLocationStatus] == kIQlocationResultAuthorized) {
        [self startMonitoringUpdates];
        
    } else {
        [[NSLogger shared] log:NSStringFromSelector(_cmd)
                    properties:@{ @"line": @(__LINE__),
                                  @"case": @"[[IQLocationPermissions sharedManager] getLocationStatus] != kIQlocationResultAuthorized" }
                         error:NO];
        updateBlock(nil, [[IQLocationPermissions sharedManager] getLocationStatus]);
    }
}

- (void)startMonitoringUpdates
{
    [[NSLogger shared] log:NSStringFromSelector(_cmd)
                properties:@{ @"line": @(__LINE__),
                              @"case": @"[[IQLocationPermissions sharedManager] getLocationStatus] == kIQlocationResultAuthorized" }
                     error:NO];

    // Create the location manager if this object does not
    // already have one.
    if (nil == _locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)stopPermanentMonitoring
{
    [[NSLogger shared] log:NSStringFromSelector(_cmd)
                properties:@{ @"line": @(__LINE__) }
                     error:NO];
    [self.locationManager stopUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate calls

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [[NSLogger shared] log:NSStringFromSelector(_cmd)
                properties:@{ @"line": @(__LINE__),
                              @"manager": manager?: @"nil",
                              @"locations": locations?:@"nil" }
                     error:NO];
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 60.0) {
        // If the event is recent, do something with it.

        self.updateBlock(location, kIQLocationResultFound);
    } else {
        [[NSLogger shared] log:NSStringFromSelector(_cmd)
                    properties:@{ @"line": @(__LINE__),
                                  @"case": @"fabs(howRecent) >= 60.0" }
                         error:NO];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[NSLogger shared] log:NSStringFromSelector(_cmd)
                properties:@{ @"line": @(__LINE__),
                              @"manager": manager?: @"nil",
                              @"error": error?:@"nil" }
                     error:YES];
    NSLog(@"IQPermanentLocation :: didFailWithError :: %@", error);
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [[NSLogger shared] log:NSStringFromSelector(_cmd)
                properties:@{ @"line": @(__LINE__),
                              @"manager": manager?: @"nil",
                              @"status": @(status),
                              @"info": @"VERY BAD THING"}
                     error:YES];
}

@end
