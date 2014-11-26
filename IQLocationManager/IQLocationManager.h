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
@property (nonatomic, strong) CLLocation        *bestEffortAtLocation;
@property (nonatomic, assign) BOOL                  isGettingLocation;

+ (IQLocationManager *)sharedManager;
- (void)getCurrentLocationWithCompletion:(void(^)(CLLocation *location, IQLocationResult result))completion;
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

