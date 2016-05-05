//
//  IQTrackPoint.i.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 28/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTrackPoint.h"

@class IQTrackPointManaged;

@interface IQTrackPoint (Internal)

- (instancetype)initWithIQTrackPoint:(IQTrackPointManaged *)iqTrackPointManaged;

@end
