//
//  IQAddressManaged.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 04/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IQAddressManaged : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (instancetype)createWithLocation:(CLLocation *)location
                      andPlacemark:(CLPlacemark *)placemark
                         inContext:(NSManagedObjectContext *)ctxt;

@end

NS_ASSUME_NONNULL_END

#import "IQAddressManaged+CoreDataProperties.h"
