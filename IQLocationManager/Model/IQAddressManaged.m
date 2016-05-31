//
//  IQAddressManaged.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 04/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQAddressManaged.h"

@implementation IQAddressManaged

// Insert code here to add functionality to your managed object subclass

+ (instancetype)createWithLocation:(CLLocation *)location
                      andPlacemark:(CLPlacemark *)placemark
                         inContext:(NSManagedObjectContext *)ctxt
{
    IQAddressManaged *a = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                                        inManagedObjectContext:ctxt];
    
    a.objectId = [[NSProcessInfo processInfo] globallyUniqueString];
    
    // save lat & long with 6 decimals in a string for predicate use.
    NSString *value = [NSString stringWithFormat:@"%.7f", location.coordinate.latitude];
    a.latitude = [value substringToIndex:value.length-1];
    value = [NSString stringWithFormat:@"%.7f", location.coordinate.longitude];
    a.longitude = [value substringToIndex:value.length-1];
    
    a.address = [placemark.addressDictionary objectForKey:@"Name"];
    a.locality = [placemark.addressDictionary objectForKey:@"City"];
    
    a.placemark = placemark;
    
    NSError *error;
    [ctxt save:&error];
    NSAssert(error == nil, @"unhandled error: %@", error);
    
    return a;
}

@end
