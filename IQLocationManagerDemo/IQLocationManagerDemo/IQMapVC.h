//
//  IQMapVC.h
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 20/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQTrack;

@interface IQMapVC : UIViewController

- (void)addLocations:(NSArray *)locations;
- (void)addTrackPoints:(NSArray *)tracks;
- (void)configureWithTrack:(IQTrack *)IQTrack;

@end
