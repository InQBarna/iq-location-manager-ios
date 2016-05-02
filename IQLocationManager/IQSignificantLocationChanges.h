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

NS_ASSUME_NONNULL_BEGIN

@interface IQSignificantLocationChanges : NSObject 

+ (IQSignificantLocationChanges *)sharedManager;

- (void)startMonitoringLocationWithSoftAccessRequest:(BOOL)softAccessRequest
                                              update:(void (^)(CLLocation * _Nullable locationOrNil, IQLocationResult result))updateBlock;

- (void)stopMonitoringLocation;

@end

NS_ASSUME_NONNULL_END
