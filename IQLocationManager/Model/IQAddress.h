//
//  IQAddress.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 04/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface IQAddress : NSObject

@property (nonnull, nonatomic, retain) NSString *objectId;
@property (nonnull, nonatomic, retain) NSString *locality;
@property (nonnull, nonatomic, retain) NSString *address;
@property (nonnull, nonatomic, retain) CLPlacemark *placemark;
@property (nonnull, nonatomic, retain) NSString *latitude;
@property (nonnull, nonatomic, retain) NSString *longitude;

- (nullable instancetype) init __unavailable;

@end
