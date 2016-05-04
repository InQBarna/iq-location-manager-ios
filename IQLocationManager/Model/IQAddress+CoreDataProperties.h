//
//  IQAddress+CoreDataProperties.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 04/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "IQAddress.h"

NS_ASSUME_NONNULL_BEGIN

@interface IQAddress (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSString *locality;
@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) id placemark;
@property (nullable, nonatomic, retain) NSString *latitude;
@property (nullable, nonatomic, retain) NSString *longitude;

@end

NS_ASSUME_NONNULL_END
