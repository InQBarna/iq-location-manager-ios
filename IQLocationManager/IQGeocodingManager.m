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

#pragma mark Public

+ (IQGeocodingManager *)sharedManager
{
    static IQGeocodingManager *__iqGeocodingManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __iqGeocodingManager = [[self alloc] init];
    });
    
    return __iqGeocodingManager;
}

- (void)getAddressFromLocation:(CLLocation*)location
                distanceFilter:(IQGeocodingDistanceFilter)distanceFilter
                withCompletion:(void(^)(BOOL isCachedAndThereforeSynchronous, CLPlacemark *placemark, NSString *address, NSString *locality, NSError *error))completion
{
    NSParameterAssert(location);
    
    if (location == nil) {
        if (completion) {
            NSError *error = [self buildParameterError];
            completion(YES, nil, nil, nil, error);
        }
        
        return;
    }
    
    NSManagedObjectContext *moc = [IQLocationDataSource sharedDataSource].managedObjectContext;
    __block IQAddress *a = nil;
    [moc performBlockAndWait:^{
        
        NSFetchRequest *request = [self fetchRequestWithLocation:location
                                                  distanceFilter:distanceFilter];
        NSError *error = nil;
        NSArray *tracks = [moc executeFetchRequest:request error:&error];
        NSAssert(error == nil, @"unhandled error: %@", error);
        if (tracks.count > 0) {
            a = [[IQAddress alloc] initWithIQAddress:tracks.lastObject];
        } else {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:location
                           completionHandler:
             ^(NSArray *cl_placemarks, NSError *cl_error) {
                 
                 CLPlacemark* placemark = [cl_placemarks lastObject];
                 [moc performBlock:^{
                     [IQAddressManaged createWithLocation:location
                                             andPlacemark:placemark
                                                inContext:moc];
                 }];
                 
                 if (completion != nil) {
                     NSString *name = [placemark.addressDictionary objectForKey:@"Name"];
                     NSString *city = [placemark.addressDictionary objectForKey:@"City"];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         completion(NO, placemark, name, city, cl_error);
                     });
                 }
             }];
        }
    }];
    
    if (a && completion) {
        completion(YES, a.placemark, a.address, a.locality, nil);
    }
}

#pragma mark Private

- (NSFetchRequest *)fetchRequestWithLocation:(CLLocation*)location
                              distanceFilter:(IQGeocodingDistanceFilter)distanceFilter
{
    NSParameterAssert(location);
    
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
            break;
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
    
    NSString *value_lat = [NSString stringWithFormat:@"%.7f", location.coordinate.latitude];
    value_lat = [value_lat substringToIndex:value_lat.length-tail];
    NSString *value_long = [NSString stringWithFormat:@"%.7f", location.coordinate.longitude];
    value_long = [value_long substringToIndex:value_long.length-tail];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([IQAddressManaged class])];
    request.predicate = [NSPredicate predicateWithFormat:@"latitude BEGINSWITH %@ AND longitude BEGINSWITH %@",
                         value_lat,
                         value_long];
    request.fetchLimit = 1;
    
    return request;
}

- (NSError *)buildParameterError
{
    NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:__LINE__
                                     userInfo:nil];
    
    return error;
}

@end
