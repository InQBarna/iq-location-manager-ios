//
//  IQLocationManager.m
//  IQLocationManagerDemo
//
//  Created by Nacho Sánchez on 14/08/14.
//  Copyright (c) 2014 InQBarna. All rights reserved.
//

#import "IQLocationManager.h"

#import "IQLocationDataSource.h"
#import "IQLocationPermissions.h"
#import "IQGeocodingManager.h"

@interface IQLocationManager() /*<UIAlertViewDelegate>*/

@property (nonatomic, strong) CLLocationManager     *locationManager;
@property (nonatomic, copy) void (^progressBlock)(CLLocation *location, IQLocationResult result);
@property (nonatomic, copy) void (^completionBlock)(CLLocation *location, IQLocationResult result);
@property (nonatomic, assign) NSTimeInterval        maximumMeasurementAge;
@property (nonatomic, assign) NSTimeInterval        maximumTimeout;
@property (nonatomic, assign) BOOL             isGettingPermissions;

@end

@implementation IQLocationManager

static IQLocationManager *__iqLocationManager;

#pragma mark Initialization and destroy calls

+ (IQLocationManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __iqLocationManager = [[self alloc] init];
    });

    return __iqLocationManager;
}

- (id)init
{
     NSAssert([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationUsageDescription"] != nil, @"To use location services in iOS < 8+, your Info.plist must provide a value for NSLocationUsageDescription.");
    
    self = [super init];
    
    if (self) {
        self.isGettingLocation = NO;
        self.locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        self.bestEffortAtLocation = [self getLastKnownLocationFromDefaults];
        self.maximumMeasurementAge = kIQLocationMeasurementAgeDefault;
#ifdef DEBUG
        self.locationMeasurements = [NSMutableArray new];
        if (self.bestEffortAtLocation) {
            [_locationMeasurements addObject:self.bestEffortAtLocation];
        }
#endif
    }
    return self;
}

- (void)dealloc {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark Public location calls

- (void)getCurrentLocationWithCompletion:(void(^)(CLLocation *location, IQLocationResult result))completion {
    
    [self getCurrentLocationWithAccuracy: kCLLocationAccuracyHundredMeters
                          maximumTimeout: kIQLocationMeasurementTimeoutDefault
                   maximumMeasurementAge: kIQLocationMeasurementAgeDefault
                       softAccessRequest: YES
                                progress: nil
                              completion: completion];
}

- (void)getCurrentLocationWithAccuracy:(CLLocationAccuracy)desiredAccuracy
                        maximumTimeout:(NSTimeInterval)maxTimeout
                 maximumMeasurementAge:(NSTimeInterval)maxMeasurementAge
                     softAccessRequest:(BOOL)softAccessRequest
                              progress:(void (^)(CLLocation *locationOrNil, IQLocationResult result))progress
                            completion:(void(^)(CLLocation *locationOrNil, IQLocationResult result))completion
{
    
    if (_isGettingLocation) {
        if (completion) {
            completion(_bestEffortAtLocation,kIQLocationResultAlreadyGettingLocation);
        }
        return;
    }
    
    _locationManager.desiredAccuracy = [self checkAccuracy:desiredAccuracy];
    
    self.maximumTimeout = maxTimeout;
    self.maximumMeasurementAge = maxMeasurementAge;
    self.completionBlock = completion;
    self.progressBlock = progress;
   
    if (_bestEffortAtLocation) {
        if (_bestEffortAtLocation.timestamp.timeIntervalSinceReferenceDate > ([NSDate timeIntervalSinceReferenceDate] - self.maximumMeasurementAge) ) {
            [self saveLocationToDefaults:_bestEffortAtLocation];
            [self stopUpdatingLocationWithResult:kIQLocationResultFound];
            return;
        } else {
            _bestEffortAtLocation = nil;
        }
    }
    
    if ( ![CLLocationManager locationServicesEnabled] ) {
        [self stopUpdatingLocationWithResult:kIQLocationResultNotEnabled];
        return;
    }
    
    __weak __typeof(self) welf = self;
    IQLocationResult status = [[IQLocationPermissions sharedManager] getLocationStatus];
    if (status == kIQLocationResultNotDetermined || status == kIQLocationResultSoftDenied) {
        [[IQLocationPermissions sharedManager] requestLocationPermissionsForManager:self.locationManager
                                                              withSoftAccessRequest:softAccessRequest
                                                                      andCompletion:^(IQLocationResult result) {
                                                                          if (result == kIQlocationResultAuthorized) {
                                                                              [welf startUpdatingLocation];
                                                                          } else {
                                                                              [welf stopUpdatingLocationWithResult:result];
                                                                              completion(nil, result);
                                                                          }
                                                                      }];
        
    } else if ([[IQLocationPermissions sharedManager] getLocationStatus] == kIQlocationResultAuthorized) {
        [self startUpdatingLocation];
        
    } else {
        [self stopUpdatingLocationWithResult:[[IQLocationPermissions sharedManager] getLocationStatus]];
        completion(nil, [[IQLocationPermissions sharedManager] getLocationStatus]);
    }
}

- (void)getAddressFromLocation:(CLLocation*)location
                withCompletion:(void(^)(CLPlacemark *placemark, NSString *address, NSString *locality, NSError *error))completion
{
    [[IQGeocodingManager sharedManager] getAddressFromLocation:location
                                                distanceFilter:kIQGeocodingDistanceFilterMeter 
                                                withCompletion:^(BOOL isCachedAndThereforeSynchronous, CLPlacemark * _Nullable placemark, NSString * _Nullable address, NSString * _Nullable locality, NSError * _Nullable error) {
                                                    completion(placemark, address, locality, error);
                                                }];
}

- (IQLocationResult)getLocationStatus
{
    return [[IQLocationPermissions sharedManager] getLocationStatus];
}

#pragma mark Private location calls

- (void)stopUpdatingLocationWithTimeout {
    [self stopUpdatingLocationWithResult:kIQLocationResultTimeout];
}

- (void)stopUpdatingLocationWithResult:(IQLocationResult)result {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_locationManager stopUpdatingLocation];
    
    if (_completionBlock) {
        _completionBlock(_bestEffortAtLocation,result);
    }
    
    self.completionBlock = nil;
    self.progressBlock = nil;
    self.isGettingLocation = NO;
    
}

- (void)startUpdatingLocation {
    self.isGettingLocation = YES;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    [self performSelector: @selector(stopUpdatingLocationWithTimeout)
               withObject: nil
               afterDelay: self.maximumTimeout ?: kIQLocationMeasurementTimeoutDefault];
}

- (CLLocationAccuracy)checkAccuracy:(CLLocationAccuracy)desiredAccuracy {
    
    if ( desiredAccuracy == kCLLocationAccuracyHundredMeters ||
        desiredAccuracy == kCLLocationAccuracyBest ||
        desiredAccuracy == kCLLocationAccuracyBestForNavigation ||
        desiredAccuracy == kCLLocationAccuracyKilometer ||
        desiredAccuracy == kCLLocationAccuracyNearestTenMeters ||
        desiredAccuracy == kCLLocationAccuracyThreeKilometers) {
        return desiredAccuracy;
    }
    
    return kCLLocationAccuracyHundredMeters;
}

- (void)saveLocationToDefaults:(CLLocation*)location {
    
    NSData *locationAsData = [NSKeyedArchiver archivedDataWithRootObject:location];
    
    [[NSUserDefaults standardUserDefaults] setObject:locationAsData forKey:kIQLocationLastKnownLocation];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CLLocation*)getLastKnownLocationFromDefaults {

    NSData *userLoc = [[NSUserDefaults standardUserDefaults] objectForKey:kIQLocationLastKnownLocation];
    if (!userLoc) {
        return nil;
    }

    return [NSKeyedUnarchiver unarchiveObjectWithData:userLoc];
}

- (BOOL)getSoftDeniedFromDefaults
{
//    BOOL softDenied = [NSUserDefaults.standardUserDefaults boolForKey:kIQLocationSoftDenied];
//    return softDenied;
    return [[IQLocationPermissions sharedManager] getSoftDeniedFromDefaults];
}

- (BOOL)setSoftDenied:(BOOL)softDenied
{
//    NSUserDefaults *const standardUserDefaults = NSUserDefaults.standardUserDefaults;
//    [NSUserDefaults.standardUserDefaults setBool:softDenied forKey:kIQLocationSoftDenied];
//    return [standardUserDefaults synchronize];
    return [[IQLocationPermissions sharedManager] setSoftDenied:softDenied];
}

#pragma mark CLLocationManagerDelegate calls

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation;
    newLocation = [locations lastObject];
    
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    // store all of the measurements, just so we can see what kind of data we might receive
#ifdef DEBUG
    [_locationMeasurements addObject:newLocation];
#endif

    if (_progressBlock) {
        _progressBlock(newLocation, kIQLocationResultIntermediateFound);
    }
    
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (fabs(locationAge) > _maximumMeasurementAge) {
        return;
    }
    
    // test the measurement to see if it is more accurate than the previous measurement
    if (_bestEffortAtLocation == nil ||
        _bestEffortAtLocation.timestamp.timeIntervalSinceReferenceDate <= ([NSDate timeIntervalSinceReferenceDate] - self.maximumMeasurementAge) ||
                                                                          _bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        
        // store the location as the "best effort"
        self.bestEffortAtLocation = newLocation;
        
        // test the measurement to see if it meets the desired accuracy
        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
            // we have a measurement that meets our requirements, so we can stop updating the location
            //
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            //
            [self saveLocationToDefaults:newLocation];
            [self stopUpdatingLocationWithResult:kIQLocationResultFound];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    // The location "unknown" error simply means the manager is currently unable to get the location.
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocationWithResult:kIQLocationResultError];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if ( !_isGettingPermissions ) {
        return;
    }
    
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self getCurrentLocationWithAccuracy: self.locationManager.desiredAccuracy
                              maximumTimeout: self.maximumTimeout
                       maximumMeasurementAge: self.maximumMeasurementAge
                           softAccessRequest: NO
                                    progress: self.progressBlock
                                  completion: self.completionBlock];
        if (_progressBlock) {
            _progressBlock(nil, kIQlocationResultAuthorized);
        }
    } else {
        [self stopUpdatingLocationWithResult:[[IQLocationPermissions sharedManager] getLocationStatus]];
    }
    
    _isGettingPermissions = NO;
}

@end
