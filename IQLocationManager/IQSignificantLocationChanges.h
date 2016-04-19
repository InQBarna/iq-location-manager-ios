//
//  IQSignificantLocationChanges.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 18/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "IQLocationPermissions.h"

@interface IQSignificantLocationChanges : NSObject 

+ (IQSignificantLocationChanges *)sharedManager;

- (void)startMonitoringLocationWithAccuracy:(CLLocationAccuracy)desiredAccuracy
                             maximumTimeout:(NSTimeInterval)maxTimeout
                      maximumMeasurementAge:(NSTimeInterval)maxMeasurementAge
                          softAccessRequest:(BOOL)softAccessRequest
                                     update:(void (^)(CLLocation *locationOrNil, IQLocationResult result))updateBlock;

- (void)stopMonitoringLocation;

@end
