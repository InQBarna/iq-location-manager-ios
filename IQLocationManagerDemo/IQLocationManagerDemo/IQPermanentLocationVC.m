//
//  IQPermanentLocationVC.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 19/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQPermanentLocationVC.h"

#import "IQMotionActivityManager.h"
#import "CMMotionActivity+IQ.h"
#import "IQPermanentLocation.h"

@interface IQPermanentLocationVC ()

@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (strong, nonatomic) NSArray               *activities;
@property (strong, nonatomic) NSArray               *locationDates;

@end

@implementation IQPermanentLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)triggerButtonPressed:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"start"]) {
        [sender setTitle:@"stop" forState:UIControlStateNormal];
        self.locationDates = [NSArray array];
        self.locations = [NSArray array];
        self.activities = [NSArray array];
        [self startMonitoring];
        [self getBatteryLevelInitial:YES];
    } else if ([sender.titleLabel.text isEqualToString:@"stop"]) {
        [sender setTitle:@"start" forState:UIControlStateNormal];
        [self stopMonitoring];
        [self getBatteryLevelInitial:NO];
    }
}

- (void)getBatteryLevelInitial:(BOOL)initial
{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    NSString *value;
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    if (batteryLevel < 0.0) {
        // -1.0 means battery state is UIDeviceBatteryStateUnknown
        value = NSLocalizedString(@"Unknown", @"");
        
    } else {
        static NSNumberFormatter *numberFormatter = nil;
        if (numberFormatter == nil) {
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
            [numberFormatter setMaximumFractionDigits:1];
        }
        NSNumber *levelObj = [NSNumber numberWithFloat:batteryLevel];
        value = [numberFormatter stringFromNumber:levelObj];
        
    }
    if (initial) {
        self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"bat: %@", value];
    } else {
        self.navigationController.navigationBar.topItem.title = [self.navigationController.navigationBar.topItem.title stringByAppendingString:[NSString stringWithFormat:@" / %@", value]];
    }
    [UIDevice currentDevice].batteryMonitoringEnabled = NO;
}

- (void)startMonitoring
{
    __weak __typeof(self) welf = self;
    [[IQMotionActivityManager sharedManager] startActivityMonitoringWithUpdateBlock:^(CMMotionActivity *activity, IQMotionActivityResult result) {
        if (result != kIQMotionActivityResultNotAvailable && result != kIQMotionActivityResultNoResult) {
            NSMutableArray *temp = welf.activities.mutableCopy;
            if (!temp) {
                temp = [NSMutableArray array];
            }
            [temp addObject:activity];
            dispatch_async(dispatch_get_main_queue(), ^{
                welf.activities = temp.copy;
                [self.tableView reloadData];
            });
        } else {
            NSLog(@"startActivityMonitoringWithUpdateBlock :: %li", (long)result);
        }
    }];
    
    [[IQPermanentLocation sharedManager] startPermanentMonitoringLocationWithSoftAccessRequest:YES
                                                                                      accuracy:kCLLocationAccuracyBestForNavigation
                                                                                distanceFilter:100.0
                                                                                  activityType:CLActivityTypeAutomotiveNavigation
                                                               allowsBackgroundLocationUpdates:YES
                                                            pausesLocationUpdatesAutomatically:NO
                                                                                        update:^(CLLocation *locationOrNil, IQLocationResult result) {
                                                                                            if (result == kIQLocationResultFound && locationOrNil) {
                                                                                                NSMutableArray *temp1 = welf.locations.mutableCopy;
                                                                                                NSMutableArray *temp2 = welf.locationDates.mutableCopy;
                                                                                                if (!temp1) {
                                                                                                    temp1 = [NSMutableArray array];
                                                                                                }
                                                                                                if (!temp2) {
                                                                                                    temp2 = [NSMutableArray array];
                                                                                                }
                                                                                                
                                                                                                [temp1 addObject:locationOrNil];
                                                                                                [temp2 addObject:[NSDate date]];
                                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                    welf.locations = temp1.copy;
                                                                                                    welf.locationDates = temp2.copy;
                                                                                                    [self.tableView reloadData];
                                                                                                });
                                                                                            }
                                                                                        }];
}

- (void)stopMonitoring
{
    [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
    [[IQPermanentLocation sharedManager] stopPermanentMonitoring];
}

#pragma mark UITableView DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Location";
    } else {
        return @"Activity";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.locations.count;
    } else {
        return self.activities.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"locationIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0) {
        CLLocation *location = self.locations[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%ld. lat: %f - lon: %f", (long)indexPath.row, location.coordinate.latitude, location.coordinate.longitude];
        NSDate *date = self.locationDates[indexPath.row];
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:date
                                                                   dateStyle:NSDateFormatterShortStyle
                                                                   timeStyle:NSDateFormatterShortStyle];
        
    } else {
        CMMotionActivity *activity = self.activities[indexPath.row];
        cell.textLabel.text = [activity motionTypeStrings];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",
                                     [NSDateFormatter localizedStringFromDate:activity.startDate
                                                                    dateStyle:NSDateFormatterShortStyle
                                                                    timeStyle:NSDateFormatterShortStyle],
                                     [activity confidenceString]];
    }
    
    return cell;
}

@end
