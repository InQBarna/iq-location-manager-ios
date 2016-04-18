//
//  CMMotionActivity+IQ.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 18/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "CMMotionActivity+IQ.h"

@implementation CMMotionActivity (IQ)

- (NSString *)motionTypeStrings
{
    NSString *string = @"";
    if (self.stationary) {
        string = [string stringByAppendingString:@"stationary,"];
    }
    if (self.walking) {
        string = [string stringByAppendingString:@"walking,"];
    }
    if (self.running) {
        string = [string stringByAppendingString:@"running,"];
    }
    if (self.automotive) {
        string = [string stringByAppendingString:@"automotive,"];
    }
    if (self.cycling) {
        string = [string stringByAppendingString:@"cycling,"];
    }
    if (self.unknown) {
        string = [string stringByAppendingString:@"unknown"];
    }
    if ([string isEqualToString:@""]) {
        string = @"*not determined*";
    }
    return string;
}

- (NSString *)confidenceString
{
    NSString *string = @"";
    if (self.confidence == CMMotionActivityConfidenceLow) {
        string = @"ConfidenceLow";
    } else if (self.confidence == CMMotionActivityConfidenceMedium) {
        string = @"ConfidenceMedium";
    } else if (self.confidence == CMMotionActivityConfidenceHigh) {
        string = @"ConfidenceHigh";
    }
    return string;
}

@end
