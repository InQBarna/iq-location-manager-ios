//
//  IQAddress.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 04/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQAddress.h"

@implementation IQAddress

// Insert code here to add functionality to your managed object subclass

+ (instancetype)createWithLocation:(CLLocation *)location
                      andPlacemark:(CLPlacemark *)placemark
                         inContext:(NSManagedObjectContext *)ctxt
{
    IQAddress *a = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                                 inManagedObjectContext:ctxt];
    
    a.objectId = [[NSProcessInfo processInfo] globallyUniqueString];
    
    a.latitude = [NSString stringWithFormat:@"%.6f", location.coordinate.latitude];
    a.longitude = [NSString stringWithFormat:@"%.6f", location.coordinate.longitude];
    
    a.address = [placemark.addressDictionary objectForKey:@"Name"];
    a.locality = [placemark.addressDictionary objectForKey:@"City"];
    
    a.placemark = placemark;
    
    NSError *error;
    [ctxt save:&error];
    return a;
}

@end
