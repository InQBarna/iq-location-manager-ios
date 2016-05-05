//
//  TrackPoint.i.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 28/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "TrackPoint.h"

@class IQTrackPointManaged;

@interface TrackPoint (Internal)

- (instancetype)initWithIQTrackPoint:(IQTrackPointManaged *)iqTrackPointManaged;

@end
