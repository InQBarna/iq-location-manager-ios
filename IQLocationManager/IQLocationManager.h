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

typedef NS_ENUM(NSInteger, IQLocationResult) {
    kIQLocationResultNotEnabled,
    kIQLocationResultError,
    kIQLocationResultSoftDenied,
    kIQLocationResultSystemDenied,
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

+ (IQLocationManager *)sharedManager;
- (void)getCurrentLocationWithCompletion:(void(^)(CLLocation *location, IQLocationResult result))completion;
- (void)getCurrentLocationWithAccuracy:(CLLocationAccuracy)desiredAccuracy
                        maximumTimeout:(NSTimeInterval)maxTimeout
                     softAccessRequest:(BOOL)softAccessRequest
                              progress:(void(^)(CLLocation *location))progress
                            completion:(void(^)(CLLocation *location, IQLocationResult result))completion;

- (void)getAddressFromLocation:(CLLocation*)location
                withCompletion:(void(^)(CLPlacemark *placemark, NSString *address, NSString *locality, NSError *error))completion;

@end

