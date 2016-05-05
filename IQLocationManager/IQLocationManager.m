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

#import "Address.h"
#import "Address.i.h"
#import "IQAddressManaged.h"

#import <CoreData/CoreData.h>

@interface IQLocationManager() /*<UIAlertViewDelegate>*/

@property (nonatomic, strong) CLLocationManager     *locationManager;
@property (nonatomic, copy) void (^progressBlock)(CLLocation *location, IQLocationResult result);
@property (nonatomic, copy) void (^completionBlock)(CLLocation *location, IQLocationResult result);
@property (nonatomic, assign) NSTimeInterval        maximumMeasurementAge;
@property (nonatomic, assign) NSTimeInterval        maximumTimeout;
@property (nonatomic, assign) BOOL             isGettingPermissions;

@end

@implementation IQLocationManager

static IQLocationManager *_iqLocationManager;

#pragma mark Initialization and destroy calls

+ (IQLocationManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _iqLocationManager = [[self alloc] init];
    });

    return _iqLocationManager;
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
    
    if (_isGettingLocation) {
        if (_completionBlock) {
            _completionBlock(_bestEffortAtLocation,kIQLocationResultAlreadyGettingLocation);
        }
        return;
    }
    
    if ( ![CLLocationManager locationServicesEnabled] ) {
        [self stopUpdatingLocationWithResult:kIQLocationResultNotEnabled];
        return;
    }
    
//    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
//    
//    if ( status ==  kCLAuthorizationStatusNotDetermined ) {
//        if (softAccessRequest) {
//            
//            NSString *localizedTitle = NSLocalizedString(@"location_request_alert_title", @"");
//            if ([localizedTitle isEqualToString:@"location_request_alert_title"]) {
//                localizedTitle = NSLocalizedStringFromTable(@"location_request_alert_title",@"IQLocationManager",nil);
//            }
//            
//            NSString *localizedDescription = NSLocalizedString(@"location_request_alert_description", @"");
//            if ([localizedDescription isEqualToString:@"location_request_alert_description"]) {
//                localizedDescription = NSLocalizedStringFromTable(@"NSLocationUsageDescription", @"InfoPlist", nil);
//                if ([localizedDescription isEqualToString:@"NSLocationUsageDescription"]) {
//                    localizedDescription = NSLocalizedStringFromTable(@"location_request_alert_description",@"IQLocationManager",nil);
//                }
//            }
//            NSString *localizedCancel = NSLocalizedString(@"location_request_alert_cancel",nil);
//            NSString *localizedAccept = NSLocalizedString(@"location_request_alert_accept",nil);
//            
//            
//            [[[UIAlertView alloc] initWithTitle: localizedTitle
//                                        message: localizedDescription
//                                       delegate: self
//                              cancelButtonTitle: ([localizedCancel isEqualToString:@"location_request_alert_cancel"] ?
//                                                  [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:@"Cancel" value:nil table:nil] : localizedCancel)
//                              otherButtonTitles: ([localizedAccept isEqualToString:@"location_request_alert_accept"] ?
//                                                  [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:@"OK" value:nil table:nil] : localizedAccept) , nil] show];
//            
//            return;
//        } else {
//            _isGettingPermissions = YES;
//            if ([UIDevice currentDevice].systemVersion.floatValue > 7.1) {
//                [self requestSystemPermissionForLocation];
//            } else {
//                // for iOS 7, startUpdating forces the request to the user
//                [_locationManager startUpdatingLocation];
//            }
//            return;
//        }
//    } else if ( status == kCLAuthorizationStatusDenied ) {
//        [self stopUpdatingLocationWithResult:kIQLocationResultSystemDenied];
//        return;
//    }
//    
//    [_locationManager startUpdatingLocation];
//    
//    if ( self.getLocationStatus == kIQlocationResultAuthorized ) {
//        [self startUpdatingLocation];
//    }
    
    __weak __typeof(self) welf = self;
    if ([[IQLocationPermissions sharedManager] getLocationStatus] == kIQLocationResultNotDetermined ||
        [[IQLocationPermissions sharedManager] getLocationStatus] == kIQLocationResultSoftDenied) {
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
    [[IQLocationDataSource sharedDataSource].managedObjectContext performBlock:^{
        
        NSString *value_lat = [NSString stringWithFormat:@"%.7f", location.coordinate.latitude];
        value_lat = [value_lat substringToIndex:value_lat.length-2];
        NSString *value_long = [NSString stringWithFormat:@"%.7f", location.coordinate.longitude];
        value_long = [value_long substringToIndex:value_long.length-2];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IQAddressManaged"];
        request.predicate = [NSPredicate predicateWithFormat:@"latitude BEGINSWITH %@ AND longitude BEGINSWITH %@",
                             value_lat,
                             value_long];
        
        NSError *error = nil;
        NSArray *tracks = [[IQLocationDataSource sharedDataSource].managedObjectContext executeFetchRequest:request error:&error].copy;
        if (tracks.count > 0) {
            Address *a = [[Address alloc] initWithIQAddress:tracks.lastObject];
            if (completion != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(a.placemark, a.address, a.locality, nil);
                });
            }
        } else {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:location
                           completionHandler:^(NSArray *cl_placemarks, NSError *cl_error) {
                               
                               CLPlacemark* placemark = [cl_placemarks lastObject];
                               
                               [[IQLocationDataSource sharedDataSource].managedObjectContext performBlock:^{
                                   [IQAddressManaged createWithLocation:location
                                                    andPlacemark:placemark
                                                       inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                               }];
                               
                               if (completion != nil) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completion(placemark,
                                                  [placemark.addressDictionary objectForKey:@"Name"],
                                                  [placemark.addressDictionary objectForKey:@"City"],
                                                  cl_error);
                                   });
                               }
                           }];
        }
    }];
}

- (IQLocationResult)getLocationStatus
{
//    if (!CLLocationManager.locationServicesEnabled) {
//        return kIQLocationResultNotEnabled;
//    } else {
//        CLAuthorizationStatus const status = CLLocationManager.authorizationStatus;
//        
//        if (status == kCLAuthorizationStatusNotDetermined) {
//            if (self.getSoftDeniedFromDefaults){
//                return kIQLocationResultSoftDenied;
//            } else {
//                return kIQLocationResultNotDetermined;
//            }
//        } else {
//            if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
//                return kIQLocationResultSystemDenied;
//            } else if (status == kCLAuthorizationStatusAuthorized) {
//                return kIQlocationResultAuthorized;
//            }
//            
//            if ([UIDevice currentDevice].systemVersion.floatValue > 7.1) {
//                if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
//                    return kIQlocationResultAuthorized;
//                }
//            }
//            
//            if (self.getSoftDeniedFromDefaults){
//                return kIQLocationResultSoftDenied;
//            }
//        }
//    }
//    return kIQLocationResultNotDetermined;
    
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
    
    if ([UIDevice currentDevice].systemVersion.floatValue > 7.1) {
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
    } else {
        if (status == kCLAuthorizationStatusAuthorized) {
            [self startUpdatingLocation];
        } else {
            [self stopUpdatingLocationWithResult:[[IQLocationPermissions sharedManager] getLocationStatus]];
        }
    }
    
    _isGettingPermissions = NO;
}

//#pragma mark - UIAlertViewDelegate methods
//
//- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if ( buttonIndex == [alertView cancelButtonIndex] ) {
//        [self stopUpdatingLocationWithResult:kIQLocationResultSoftDenied];
//        [self setSoftDenied:YES];
//    } else {
//        [self setSoftDenied:NO];
//        _isGettingPermissions = YES;
//        if ([UIDevice currentDevice].systemVersion.floatValue > 7.1) {
//            [self requestSystemPermissionForLocation];
//            return;
//        } else {
//            [self getCurrentLocationWithAccuracy: self.locationManager.desiredAccuracy
//                                  maximumTimeout: self.maximumTimeout
//                           maximumMeasurementAge: self.maximumMeasurementAge
//                               softAccessRequest: NO
//                                        progress: self.progressBlock
//                                      completion: self.completionBlock];
//        }
//
//    }
//}
//
//- (void)requestSystemPermissionForLocation {
//    // As of iOS 8, apps must explicitly request location services permissions. IQLocationManager supports both levels, "Always" and "When In Use".
//    // IQLocationManager determines which level of permissions to request based on which description key is present in your app's Info.plist
//    // If you provide values for both description keys, the more permissive "Always" level is requested.
//    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
//        BOOL hasAlwaysKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] != nil;
//        BOOL hasWhenInUseKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
//        if (hasAlwaysKey) {
//            [self.locationManager requestAlwaysAuthorization];
//        } else if (hasWhenInUseKey) {
//            [self.locationManager requestWhenInUseAuthorization];
//        } else {
//            // At least one of the keys NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription MUST be present in the Info.plist file to use location services on iOS 8+.
//            NSAssert(hasAlwaysKey || hasWhenInUseKey, @"To use location services in iOS 8+, your Info.plist must provide a value for either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription.");
//        }
//    }
//}

@end
