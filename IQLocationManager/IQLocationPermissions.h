//
//  IQLocationPermissions.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 18/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

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

- (void)requestLocationPermissionsForManager:(CLLocationManager *)locationManager
                       withSoftAccessRequest:(BOOL)softAccessRequest
                               andCompletion:(void(^)(IQLocationResult result))completion;

- (IQLocationResult)getLocationStatus;

@end
