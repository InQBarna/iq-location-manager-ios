//
//  IQLocationManager.h
//  IQLocationManagerDemo
//
//  Created by Nacho Sánchez on 14/08/14.
//  Copyright (c) 2014 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "IQLocationPermissions.h"

#define kIQLocationLastKnownLocation @"kIQLocationLastKnownLocation"
#define kIQLocationSoftDenied @"kIQLocationSoftDenied"

#define kIQLocationMeasurementAgeDefault        300.0
#define kIQLocationMeasurementTimeoutDefault    5.0

//typedef NS_ENUM(NSInteger, IQLocationResult) {
//    kIQLocationResultNotEnabled,
//    kIQLocationResultNotDetermined,
//    kIQLocationResultSoftDenied,
//    kIQLocationResultSystemDenied,
//    kIQlocationResultAuthorized,
//    kIQLocationResultError,
//    kIQLocationResultNoResult,
//    kIQLocationResultTimeout,
//    kIQLocationResultIntermediateFound,
//    kIQLocationResultFound,
//    kIQLocationResultAlreadyGettingLocation
//};

@interface IQLocationManager : NSObject <CLLocationManagerDelegate>

#ifdef DEBUG
@property (nonatomic, strong) NSMutableArray    *locationMeasurements;
#endif
/** Contains the best location, using the last valid location */
@property (nonatomic, strong) CLLocation        *bestEffortAtLocation;
@property (nonatomic, assign) BOOL                  isGettingLocation;
@property (nonatomic, readonly) BOOL             isGettingPermissions;

+ (IQLocationManager *)sharedManager;

/**
 This method will start requesting user's location. It uses default values for accuracy, timeout and softAccess.
 Accuracy = kCLLocationAccuracyHundredMeters
 Timeout = kIQLocationMeasurementTimeoutDefault
 SoftAccess = YES
 A final location will be returned with the required accuracy.

 @param completion this block will be called with final location
 */
- (void)getCurrentLocationWithCompletion:(void(^)(CLLocation *location, IQLocationResult result))completion;

/**
 This method will start requesting user's location. Will request for system's permissions.
 A final location will be returned with the required accuracy.
 
 @param desiredAccuracy requires value in CLLocationAccuracy
 @param maxTimeout after timeout it returns a location that is fresh but does not match the accuracy
 @param maxMeasurementAge if the new request is not older that maxMeasurementAge, the last obtained result is returned
 @param softAccessRequest NO will request system's location permissions. YES will first ask for soft permission with an UIAlertView
 @param progress this block will be called with partial locations not matching the required accuracy until a final location is received
 @param completion this block will be called with final location or timeout
 */
- (void)getCurrentLocationWithAccuracy:(CLLocationAccuracy)desiredAccuracy
                        maximumTimeout:(NSTimeInterval)maxTimeout
                 maximumMeasurementAge:(NSTimeInterval)maxMeasurementAge
                     softAccessRequest:(BOOL)softAccessRequest
                              progress:(void(^)(CLLocation *locationOrNil, IQLocationResult result))progress
                            completion:(void(^)(CLLocation *locationOrNil, IQLocationResult result))completion;
- (void)getAddressFromLocation:(CLLocation*)location
                withCompletion:(void(^)(CLPlacemark *placemark, NSString *address, NSString *locality, NSError *error))completion;

- (IQLocationResult)getLocationStatus DEPRECATED_MSG_ATTRIBUTE("Use IQLocationPermissions :: getLocationStatus instead.");
- (BOOL)getSoftDeniedFromDefaults DEPRECATED_MSG_ATTRIBUTE("Use IQLocationPermissions :: getSoftDeniedFromDefaults instead.");
- (BOOL)setSoftDenied:(BOOL)softDenied DEPRECATED_MSG_ATTRIBUTE("Use IQLocationPermissions :: setSoftDeniedinstead.");

@end
