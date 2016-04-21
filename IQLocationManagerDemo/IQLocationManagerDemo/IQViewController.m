//
//  IQViewController.m
//  IQLocationManagerDemo
//
//  Created by Nacho Sánchez on 14/08/14.
//  Copyright (c) 2014 InQBarna. All rights reserved.
//

#import "IQViewController.h"
#import "IQLocationManager.h"

@interface IQViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *address;

@end

@implementation IQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.address = @"No location";
    
    // start getting locations, first ask the user
    [[IQLocationManager sharedManager] getCurrentLocationWithAccuracy: kCLLocationAccuracyHundredMeters
                                                       maximumTimeout: 15.0
                                                maximumMeasurementAge: 60.0
                                                    softAccessRequest: YES
                                                             progress: ^(CLLocation *locationOrNil, IQLocationResult result) {
                                                                 [self.tableView reloadData];
                                                             } completion:^(CLLocation *locationOrNil, IQLocationResult result) {
                                                                 if ( result == kIQLocationResultFound ) {
                                                                     [self.tableView reloadData];
                                                                     
                                                                     [[IQLocationManager sharedManager]getAddressFromLocation:locationOrNil
                                                                                                               withCompletion:^(CLPlacemark *placemark, NSString *address, NSString *locality, NSError *error) {
                                                                                                                   if (!error) {
                                                                                                                       self.address = [NSString stringWithFormat:@"%@, %@",address,locality];
                                                                                                                   } else {
                                                                                                                       self.address = @"Geocoding error";
                                                                                                                   }
                                                                                                                   
                                                                                                                   [self.tableView reloadData];
                                                                                                               }];
                                                                 } else if( result == kIQLocationResultTimeout) {
                                                                     self.address = @"Timeout";
                                                                     [self.tableView reloadData];
                                                                 }
                                                             }];
    
    // this loads the last known location from disk
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Address";
    } else {
        return @"Coordinates";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return [IQLocationManager sharedManager].locationMeasurements.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"locationIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = self.address;
    } else {
        CLLocation *location = [[IQLocationManager sharedManager].locationMeasurements objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%ld. lat: %f - lon: %f", (long)indexPath.row, location.coordinate.latitude, location.coordinate.longitude];
    }
    
    return cell;
}

@end
