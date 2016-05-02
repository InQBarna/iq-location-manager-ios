//
//  IQLocationPermissions.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 18/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

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

@interface IQLocationPermissions : NSObject

+ (IQLocationPermissions *)sharedManager;

- (void)requestLocationPermissionsForManager:(CLLocationManager *)locationManager
                       withSoftAccessRequest:(BOOL)softAccessRequest
                               andCompletion:(void(^)(IQLocationResult result))completion;

- (IQLocationResult)getLocationStatus;

@end

NS_ASSUME_NONNULL_END
