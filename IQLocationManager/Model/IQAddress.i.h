//
//  IQAddress.i.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 04/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQAddress.h"

@class IQAddressManaged;

@interface IQAddress (Internal)

- (instancetype)initWithIQAddress:(IQAddressManaged *)iqAddressManaged;

@end