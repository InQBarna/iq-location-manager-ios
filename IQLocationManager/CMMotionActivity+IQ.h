//
//  CMMotionActivity+IQ.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 18/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

@interface CMMotionActivity (IQ)

- (NSString *)motionTypeStrings;
- (NSString *)confidenceString;

@end
