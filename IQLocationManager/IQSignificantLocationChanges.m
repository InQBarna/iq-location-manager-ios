//
//  IQSignificantLocationChanges.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 18/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQSignificantLocationChanges.h"

@interface IQSignificantLocationChanges() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager     *locationManager;
@property (nonatomic, copy) void (^updateBlock)(CLLocation *locationOrNil, IQLocationResult result);

@end

@implementation IQSignificantLocationChanges

static IQSignificantLocationChanges *__iqSignificantLocationChanges;

#pragma mark Initialization and destroy calls

+ (IQSignificantLocationChanges *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __iqSignificantLocationChanges = [[self alloc] init];
    });
    return __iqSignificantLocationChanges;
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

- (void)startMonitoringLocationWithSoftAccessRequest:(BOOL)softAccessRequest
                                              update:(void (^)(CLLocation *locationOrNil, IQLocationResult result))updateBlock
{
    self.updateBlock = updateBlock;
    
    __weak __typeof(self) welf = self;
    if ([[IQLocationPermissions sharedManager] getLocationStatus] == kIQLocationResultNotDetermined ||
        [[IQLocationPermissions sharedManager] getLocationStatus] == kIQLocationResultSoftDenied) {
        [[IQLocationPermissions sharedManager] requestLocationPermissionsForManager:self.locationManager
                                                              withSoftAccessRequest:softAccessRequest
                                                                      andCompletion:^(IQLocationResult result) {
                                                                          if (result == kIQlocationResultAuthorized) {
                                                                              [welf startSignificantChangeUpdates];
                                                                          } else {
                                                                              updateBlock(nil, result);
                                                                          }
                                                                      }];
        
    } else if ([[IQLocationPermissions sharedManager] getLocationStatus] == kIQlocationResultAuthorized) {
        [self startSignificantChangeUpdates];
        
    } else {
        updateBlock(nil, [[IQLocationPermissions sharedManager] getLocationStatus]);
    }
}

- (void)startSignificantChangeUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == _locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }    
    self.locationManager.delegate = self;
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopMonitoringLocation
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
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
    self.updateBlock(location, kIQLocationResultFound);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"IQSignificantLocationChanges :: didFailWithError :: %@", error);
}

@end
