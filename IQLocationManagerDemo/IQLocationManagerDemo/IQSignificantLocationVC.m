//
//  IQSignificantLocationVC.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 18/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQSignificantLocationVC.h"

#import "IQMotionActivityManager.h"
#import "CMMotionActivity+IQ.h"
#import "IQSignificantLocationChanges.h"

@interface IQSignificantLocationVC ()

@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (strong, nonatomic) NSArray               *activities;
@property (strong, nonatomic) NSArray               *locations;

@end

@implementation IQSignificantLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)triggerButtonPressed:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"start"]) {
        [sender setTitle:@"stop" forState:UIControlStateNormal];
        [self startMonitoring];
    } else if ([sender.titleLabel.text isEqualToString:@"stop"]) {
        [sender setTitle:@"start" forState:UIControlStateNormal];
        [self stopMonitoring];
    }
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
    
    [[IQSignificantLocationChanges sharedManager] startMonitoringLocationWithSoftAccessRequest:YES
                                                                                        update:^(CLLocation *locationOrNil, IQLocationResult result) {
                                                                                            if (result == kIQLocationResultFound) {
                                                                                               NSMutableArray *temp = welf.locations.mutableCopy;
                                                                                               if (!temp) {
                                                                                                   temp = [NSMutableArray array];
                                                                                               }
                                                                                               [temp addObject:locationOrNil];
                                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                   welf.locations = temp.copy;
                                                                                                   [self.tableView reloadData];
                                                                                               });
                                                                                           }
                                                                                        }];
}

- (void)stopMonitoring
{
    [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
    [[IQSignificantLocationChanges sharedManager] stopMonitoringLocation];
}

#pragma mark UITableView DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
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
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:[NSDate date]
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
