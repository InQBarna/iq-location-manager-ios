//
//  IQTrackPoint+CoreDataProperties.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 22/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "IQTrackPoint+CoreDataProperties.h"

@implementation IQTrackPoint (CoreDataProperties)

@dynamic objectId;
@dynamic latitude;
@dynamic longitude;
@dynamic date;
@dynamic running;
@dynamic cycling;
@dynamic automotive;
@dynamic walking;
@dynamic unknown;
@dynamic stationary;
@dynamic confidence;
@dynamic track;

@end
