//
//  IQMapVC.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 20/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface IQMapVC : UIViewController

- (void)addLocations:(NSArray *)locations;
- (void)addTracks:(NSArray *)tracks;
- (void)configureWithTrackID:(NSManagedObjectID *)trackID;

@end
