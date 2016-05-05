//
//  Address.i.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 04/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "Address.h"

@class IQAddressManaged;

@interface Address (Internal)

- (instancetype)initWithIQAddress:(IQAddressManaged *)iqAddressManaged;

@end