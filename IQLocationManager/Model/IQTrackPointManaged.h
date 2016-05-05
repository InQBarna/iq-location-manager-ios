//
//  IQTrackPointManaged.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 22/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

@class IQTrackManaged;

NS_ASSUME_NONNULL_BEGIN

@interface IQTrackPointManaged : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (instancetype)createWithActivity:(CMMotionActivity *)activity
                          location:(CLLocation *)location
                        andTrackID:(NSManagedObjectID *)trackID
                         inContext:(NSManagedObjectContext *)ctxt;

- (NSString *)activityTypeString;
- (NSString *)confidenceString;

@end

NS_ASSUME_NONNULL_END

#import "IQTrackPointManaged+CoreDataProperties.h"
