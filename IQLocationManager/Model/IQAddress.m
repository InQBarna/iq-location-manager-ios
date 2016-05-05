//
//  IQAddress.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 04/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQAddress.h"

#import "IQAddressManaged.h"

@implementation IQAddress

- (instancetype)initWithIQAddress:(IQAddressManaged *)iqAddressManaged
{
    self = [super init];
    
    self.objectId = iqAddressManaged.objectId;
    self.locality = iqAddressManaged.locality;
    self.address = iqAddressManaged.address;
    self.latitude = iqAddressManaged.latitude;
    self.longitude = iqAddressManaged.longitude;
    self.placemark = iqAddressManaged.placemark;
    
    return self;
}

@end
