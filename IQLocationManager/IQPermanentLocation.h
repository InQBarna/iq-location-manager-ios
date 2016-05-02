//
//  IQPermanentLocation.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 19/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "IQLocationPermissions.h"

NS_ASSUME_NONNULL_BEGIN

@interface IQPermanentLocation : NSObject

+ (IQPermanentLocation *)sharedManager;

- (void)startPermanentMonitoringLocationWithSoftAccessRequest:(BOOL)softAccessRequest
                                                     accuracy:(CLLocationAccuracy)desiredAccuracy
                                               distanceFilter:(CLLocationDistance)distanceFilter
                                                 activityType:(CLActivityType)activityType
                              allowsBackgroundLocationUpdates:(BOOL)allowsBackgroundLocationUpdates
                           pausesLocationUpdatesAutomatically:(BOOL)pausesLocationUpdatesAutomatically
                                                       update:(void (^)(CLLocation * _Nullable locationOrNil, IQLocationResult result))updateBlock;

- (void)stopPermanentMonitoring;

@end

NS_ASSUME_NONNULL_END
