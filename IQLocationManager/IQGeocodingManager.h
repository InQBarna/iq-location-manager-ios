//
//  IQGeocodingManager.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 06/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, IQGeocodingDistanceFilter) {
    kIQGeocodingDistanceFilterHundredKilometers,
    kIQGeocodingDistanceFilterTenKilometers,
    kIQGeocodingDistanceFilterKilometer,
    kIQGeocodingDistanceFilterHundredMeters,
    kIQGeocodingDistanceFilterTenMeters,
    kIQGeocodingDistanceFilterMeter,
    kIQGeocodingDistanceFilterTenCentimeters
};


@interface IQGeocodingManager : NSObject

+ (IQGeocodingManager *)sharedManager;

/**
 
 Sometimes asyncrhonous and other times synchronous method that returns a CLPlacemark, an address and a locality of the @param location.
 
 @param location where to apply the reverse geocode.
 @param distanceFilter is a IQGeocodingDistanceFilter. Use it to specify the accuracy of the result.
 @param completion block that returns the address. The `isCachedAndThereforeSynchronous` parameter determines whether the block is invoked synchronously or asynchronously.
 
 decimal
 places   degrees          distance
 -------  -------          --------
 0        1                111  km
 1        0.1              11.1 km
 2        0.01             1.11 km
 3        0.001            111  m
 4        0.0001           11.1 m
 5        0.00001          1.11 m
 6        0.000001         11.1 cm
 
 */

- (void)getAddressFromLocation:(CLLocation*)location
                distanceFilter:(IQGeocodingDistanceFilter)distanceFilter
                withCompletion:(void(^)(BOOL isCachedAndThereforeSynchronous,
                                        CLPlacemark * _Nullable placemark,
                                        NSString * _Nullable address,
                                        NSString * _Nullable locality,
                                        NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END