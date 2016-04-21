//
//  IQTrack.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 21/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface IQTrack : NSObject <MKAnnotation>

@property (nonatomic, strong) CMMotionActivity      *activity;
@property (nonatomic, strong) CLLocation            *location;
@property (nonatomic, strong) NSDate                *date;

- (instancetype)initWithActivity:(CMMotionActivity *)activity location:(CLLocation *)location;

@end
