//
//  IQLocationManager.h
//  IQLocationManagerDemo
//
//  Created by Nacho Sánchez on 14/08/14.
//  Copyright (c) 2014 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define kIQLocationLastKnownLocation @"kIQLocationLastKnownLocation"
#define kIQLocationSoftDenied @"kIQLocationSoftDenied"

#define kIQLocationMeasurementAgeDefault        300.0
#define kIQLocationMeasurementTimeoutDefault    5.0

typedef NS_ENUM(NSInteger, IQLocationResult) {
    kIQLocationResultNotEnabled,
    kIQLocationResultNotDetermined,
    kIQLocationResultSoftDenied,
    kIQLocationResultSystemDenied,
    kIQlocationResultAuthorized,
    kIQLocationResultError,
    kIQLocationResultNoResult,
    kIQLocationResultTimeout,
    kIQLocationResultIntermediateFound,
    kIQLocationResultFound,
    kIQLocationResultAlreadyGettingLocation
};

@interface IQLocationManager : NSObject <CLLocationManagerDelegate>

#ifdef DEBUG
@property (nonatomic, strong) NSMutableArray    *locationMeasurements;
#endif
/** Contains the best location, using the last valid location */
@property (nonatomic, strong) CLLocation        *bestEffortAtLocation;
@property (nonatomic, assign) BOOL                  isGettingLocation;

+ (IQLocationManager *)sharedManager;

/**
 This method will start requesting user's location. Will request for system's permissions.
 A final location will be returned with the required accuracy.
  @param completion this block will be called with final location
 */
- (void)getCurrentLocationWithCompletion:(void(^)(CLLocation *location, IQLocationResult result))completion;

/**
 This method will start requesting user's location. Will request for system's permissions.
 A final location will be returned with the required accuracy.
 
 @param required IQLocationAccuracy
 @param maxTimeout after timeout it returns the best accuracy possible
 @param softAccessRequest NO will request system's location permissions. YES will first ask for soft permission with an UIAlertView
 @param progress this block will be called with partial locations not matching the required accuracy until a final location is received
 @param completion this block will be called with final location
 */
- (void)getCurrentLocationWithAccuracy:(CLLocationAccuracy)desiredAccuracy
                        maximumTimeout:(NSTimeInterval)maxTimeout
                     softAccessRequest:(BOOL)softAccessRequest
                              progress:(void(^)(CLLocation *locationOrNil, IQLocationResult result))progress
                            completion:(void(^)(CLLocation *locationOrNil, IQLocationResult result))completion;
- (void)getAddressFromLocation:(CLLocation*)location
                withCompletion:(void(^)(CLPlacemark *placemark, NSString *address, NSString *locality, NSError *error))completion;
- (IQLocationResult)getLocationStatus;
- (BOOL)getSoftDeniedFromDefaults;
- (BOOL)setSoftDenied:(BOOL)softDenied;

@end

