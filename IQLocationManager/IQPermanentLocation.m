//
//  IQPermanentLocation.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 19/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQPermanentLocation.h"

@interface IQPermanentLocation() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager     *locationManager;
@property (nonatomic, copy) void (^updateBlock)(CLLocation *locationOrNil, IQLocationResult result);

@end

@implementation IQPermanentLocation

static IQPermanentLocation *_iqPermanentLocation;

#pragma mark Initialization and destroy calls

+ (IQPermanentLocation *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _iqPermanentLocation = [[self alloc] init];
    });
    return _iqPermanentLocation;
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
    self.locationManager.desiredAccuracy = desiredAccuracy;
    self.locationManager.distanceFilter = distanceFilter;
    self.locationManager.activityType = activityType;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4) {
        if (allowsBackgroundLocationUpdates) {
            BOOL plistCheck = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"] containsObject:@"location"];
            NSAssert(plistCheck, @"Apps that want to receive location updates when suspended must include:\n\"UIBackgroundModes\" key with \"location\" value\nin their app’s Info.plist file");
            self.locationManager.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates;
        }
    }    
    
    self.locationManager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically;
    self.updateBlock = updateBlock;
    
    __weak __typeof(self) welf = self;
    if ([[IQLocationPermissions sharedManager] getLocationStatus] == kIQLocationResultNotDetermined ||
        [[IQLocationPermissions sharedManager] getLocationStatus] == kIQLocationResultSoftDenied ) {
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
        updateBlock(nil, [[IQLocationPermissions sharedManager] getLocationStatus]);
    }
}

- (void)startMonitoringUpdates
{
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
    [self.locationManager stopUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate calls

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 60.0) {
        // If the event is recent, do something with it.

        self.updateBlock(location, kIQLocationResultFound);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"IQPermanentLocation :: didFailWithError :: %@", error);
}

@end
