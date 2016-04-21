//
//  IQTrackerVC.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 21/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTrackerVC.h"

#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

#import "IQTracker.h"
#import "IQTrack.h"
#import "CMMotionActivity+IQ.h"

@interface IQTrackerVC ()

@property (weak, nonatomic) IBOutlet UITableView    *tableView;

@end

@implementation IQTrackerVC

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
        self.tracks = [NSArray array];
        [self startTracker];
        [self getBatteryLevelInitial:YES];
    } else if ([sender.titleLabel.text isEqualToString:@"stop"]) {
        [sender setTitle:@"start" forState:UIControlStateNormal];
        [self stopTracker];
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

- (void)startTracker
{
    __weak __typeof(self) welf = self;
    [[IQTracker sharedManager] startLIVETrackerForActivity:nil
                                                    update:^(IQTrack *t, IQTrackerResult result) {
                                                        if (result == kIQTrackerResultFound && t) {
                                                            NSMutableArray *temp = welf.tracks.mutableCopy;
                                                            if (!temp) {
                                                                temp = [NSMutableArray array];
                                                            }
                                                            [temp addObject:t];
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                welf.tracks = temp.copy;
                                                                [self.tableView reloadData];
                                                            });
                                                        }
                                                    }];
}

- (void)stopTracker
{
    [[IQTracker sharedManager] stopTracker];
}

#pragma mark UITableView DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Tracks";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"locationIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    IQTrack *t = self.tracks[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [t.activity motionTypeStrings], [NSDateFormatter localizedStringFromDate:t.date
                                                                                                                                dateStyle:NSDateFormatterShortStyle
                                                                                                                                timeStyle:NSDateFormatterShortStyle]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld. lat: %.4f - lon: %.4f", (long)indexPath.row, t.location.coordinate.latitude, t.location.coordinate.longitude];
    
    return cell;
}

@end
