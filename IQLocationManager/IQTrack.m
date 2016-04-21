//
//  IQTrack.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 21/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTrack.h"

#import "CMMotionActivity+IQ.h"

@implementation IQTrack

- (instancetype)initWithActivity:(CMMotionActivity *)activity location:(CLLocation *)location
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.activity = activity;
        self.location = location;
        self.date = [NSDate date];
    }
    return self;
}

#pragma mark - MKAnnotation protocol
- (NSString *)title
{
    return [self.activity motionTypeStrings];
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"lat: %.4f - lon: %.4f", self.location.coordinate.latitude, self.location.coordinate.longitude];
}

- (CLLocationCoordinate2D)coordinate
{
    return self.location.coordinate;
}

@end
