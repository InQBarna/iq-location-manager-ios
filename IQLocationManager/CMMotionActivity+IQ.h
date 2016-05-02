//
//  CMMotionActivity+IQ.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 18/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMMotionActivity (IQ)

- (NSString *)motionTypeStrings;
- (NSString *)confidenceString;
- (BOOL)containsActivityType:(NSString *)activityType;

@end

NS_ASSUME_NONNULL_END
