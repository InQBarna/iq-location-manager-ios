//
//  IQAddressManaged+CoreDataProperties.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 05/05/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "IQAddressManaged.h"

NS_ASSUME_NONNULL_BEGIN

@interface IQAddressManaged (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSString *latitude;
@property (nullable, nonatomic, retain) NSString *locality;
@property (nullable, nonatomic, retain) NSString *longitude;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) id placemark;

@end

NS_ASSUME_NONNULL_END
