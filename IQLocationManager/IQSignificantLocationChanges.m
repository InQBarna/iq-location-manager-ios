//
//  IQSignificantLocationChanges.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 18/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQSignificantLocationChanges.h"

#import "IQLocationPermissions.h"

@interface IQSignificantLocationChanges() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager     *locationManager;
@property (nonatomic, copy) void (^updateBlock)(CLLocation *locationOrNil, IQLocationResult result);

@end

@implementation IQSignificantLocationChanges

//// Delegate method from the CLLocationManagerDelegate protocol.
//- (void)locationManager:(CLLocationManager *)manager
//     didUpdateLocations:(NSArray *)locations {
//    // If it's a relatively recent event, turn off updates to save power.
//    CLLocation* location = [locations lastObject];
//    NSDate* eventDate = location.timestamp;
//    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
//    if (abs(howRecent) < 15.0) {
//        // If the event is recent, do something with it.
//        NSLog(@"latitude %+.6f, longitude %+.6f\n",
//              location.coordinate.latitude,
//              location.coordinate.longitude);
//    }
//}

- (id)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    return self;
}

- (void)startMonitoringLocationWithAccuracy:(CLLocationAccuracy)desiredAccuracy
                             maximumTimeout:(NSTimeInterval)maxTimeout
                      maximumMeasurementAge:(NSTimeInterval)maxMeasurementAge
                          softAccessRequest:(BOOL)softAccessRequest
                                     update:(void (^)(CLLocation *locationOrNil, IQLocationResult result))updateBlock
{
    self.locationManager.desiredAccuracy = desiredAccuracy;
    self.updateBlock = updateBlock;
    
    __weak __typeof(self) welf = self;
    IQLocationPermissions *permissions = [[IQLocationPermissions alloc] init];
    if ([permissions getLocationStatus] == kIQLocationResultNotDetermined) {
        [permissions requestLocationPermissionsForManager:self.locationManager
                                    withSoftAccessRequest:softAccessRequest
                                            andCompletion:^(IQLocationResult result) {
                                                if (result == kIQlocationResultAuthorized) {
                                                    [welf startSignificantChangeUpdates];
                                                } else {
                                                    updateBlock(nil, result);
                                                }
                                            }];
        
    } else if ([permissions getLocationStatus] == kIQlocationResultAuthorized) {
        [welf startSignificantChangeUpdates];
        
    } else {
        updateBlock(nil, [permissions getLocationStatus]);
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


#pragma mark CLLocationManagerDelegate calls

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

@end
