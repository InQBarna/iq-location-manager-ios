//
//  IQMotionActivityVC.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 18/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQMotionActivityVC.h"

#import "IQMotionActivityManager.h"
#import "CMMotionActivity+IQ.h"

@interface IQMotionActivityVC ()

@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (strong, nonatomic) NSArray               *activities;

@end

@implementation IQMotionActivityVC

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
        [[IQMotionActivityManager sharedManager] stopActivityMonitoring];
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
                CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
                if (offset.y > 0) {
                    [self.tableView setContentOffset:offset animated:YES];
                }
            });
        } else {
            NSLog(@"startActivityMonitoringWithUpdateBlock :: %li", (long)result);
        }
    }];
}

#pragma mark UITableView DataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.activities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"locationIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CMMotionActivity *activity = self.activities[indexPath.row];
    
    cell.textLabel.text = [activity motionTypeStrings];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [NSDateFormatter localizedStringFromDate:activity.startDate
                                                                                                      dateStyle:NSDateFormatterShortStyle
                                                                                                      timeStyle:NSDateFormatterShortStyle],
                                 [activity confidenceString]];
    
    return cell;
}

@end
