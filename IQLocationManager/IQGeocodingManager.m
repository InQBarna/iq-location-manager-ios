//
//  IQGeocodingManager.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 06/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQGeocodingManager.h"

#import "IQLocationDataSource.h"
#import <CoreData/CoreData.h>

#import "IQAddress.h"
#import "IQAddress.i.h"
#import "IQAddressManaged.h"

@implementation IQGeocodingManager

static IQGeocodingManager *__iqGeocodingManager;

#pragma mark Initialization and destroy calls

+ (IQGeocodingManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __iqGeocodingManager = [[self alloc] init];
    });
    return __iqGeocodingManager;
}

- (void)getAddressFromLocation:(CLLocation*)location
                distanceFilter:(IQGeocodingDistanceFilter)distanceFilter
                withCompletion:(void(^)(CLPlacemark *placemark, NSString *address, NSString *locality, NSError *error))completion
{
    NSInteger tail = 1;
    switch (distanceFilter) {
        case kIQGeocodingDistanceFilterHundredKilometers:
            tail = 7;
            break;
        case kIQGeocodingDistanceFilterTenKilometers:
            tail = 6;
            break;
        case kIQGeocodingDistanceFilterKilometer:
            tail = 5;
            break;
        case kIQGeocodingDistanceFilterHundredMeters:
            tail = 4;
        case kIQGeocodingDistanceFilterTenMeters:
            tail = 3;
            break;
        case kIQGeocodingDistanceFilterMeter:
            tail = 2;
            break;
        case kIQGeocodingDistanceFilterTenCentimeters:
            tail = 1;
            break;
    }
    
    [[IQLocationDataSource sharedDataSource].managedObjectContext performBlock:^{
        
        NSString *value_lat = [NSString stringWithFormat:@"%.7f", location.coordinate.latitude];
        value_lat = [value_lat substringToIndex:value_lat.length-tail];
        NSString *value_long = [NSString stringWithFormat:@"%.7f", location.coordinate.longitude];
        value_long = [value_long substringToIndex:value_long.length-tail];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IQAddressManaged"];
        request.predicate = [NSPredicate predicateWithFormat:@"latitude BEGINSWITH %@ AND longitude BEGINSWITH %@",
                             value_lat,
                             value_long];
        
        NSError *error = nil;
        NSArray *tracks = [[IQLocationDataSource sharedDataSource].managedObjectContext executeFetchRequest:request error:&error].copy;
        if (tracks.count > 0) {
            IQAddress *a = [[IQAddress alloc] initWithIQAddress:tracks.lastObject];
            if (completion != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(a.placemark, a.address, a.locality, nil);
                });
            }
        } else {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:location
                           completionHandler:^(NSArray *cl_placemarks, NSError *cl_error) {
                               
                               CLPlacemark* placemark = [cl_placemarks lastObject];
                               
                               [[IQLocationDataSource sharedDataSource].managedObjectContext performBlock:^{
                                   [IQAddressManaged createWithLocation:location
                                                           andPlacemark:placemark
                                                              inContext:[IQLocationDataSource sharedDataSource].managedObjectContext];
                               }];
                               
                               if (completion != nil) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completion(placemark,
                                                  [placemark.addressDictionary objectForKey:@"Name"],
                                                  [placemark.addressDictionary objectForKey:@"City"],
                                                  cl_error);
                                   });
                               }
                           }];
        }
    }];
}


@end
