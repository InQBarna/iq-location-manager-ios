//
//  Address.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 04/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "Address.h"

#import "IQAddress.h"

@implementation Address

- (instancetype)initWithIQAddress:(IQAddress *)iqAddress
{
    self = [super init];
    
    self.objectId = iqAddress.objectId;
    self.locality = iqAddress.locality;
    self.address = iqAddress.address;
    self.latitude = iqAddress.latitude;
    self.longitude = iqAddress.longitude;
    self.placemark = [NSKeyedUnarchiver unarchiveObjectWithData:iqAddress.placemark];
    
    return self;
}

@end
