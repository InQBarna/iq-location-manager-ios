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
#import <MessageUI/MessageUI.h>
#import "NSLogger.h"

#import "IQTracker.h"
#import "IQTrack.h"
#import "IQTrackPoint.h"

typedef NS_ENUM(NSInteger, IQTrackerMode) {
    kIQTrackerModeAutomatic,
    kIQTrackerModeManual,
};

@interface IQTrackerVC () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (weak, nonatomic) IBOutlet UILabel        *modeLabel;
@property (assign, nonatomic) IQTrackerMode         trackerMode;

@end

@implementation IQTrackerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.trackerMode = kIQTrackerModeManual;
    self.modeLabel.text = @"mode: manual (all)";
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

- (IBAction)triggerSendLogPressed:(UIButton *)sender
{
    NSData *data = [[NSLogger shared] logData];
    if (data) {
        MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
        [emailController setMailComposeDelegate:self];
        [emailController setToRecipients:[[NSArray alloc] initWithObjects:@"raul.penya@teameeng.com", nil]];
        [emailController setSubject:@"Log File"];
        [emailController setMessageBody:@"" isHTML:false];
        [emailController addAttachmentData:data mimeType:@"text/plain" fileName:@"log.txt"];
        [emailController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:emailController animated:true completion:nil];
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

- (void)showActionSheet
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tracker mode"
                                                                             message:@"Select tracker mode"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *automatic = [UIAlertAction actionWithTitle:@"Automatic"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          self.trackerMode = kIQTrackerModeAutomatic;
                                                          self.modeLabel.text = @"mode: automatic (automotive)";
                                                          [alertController dismissViewControllerAnimated:YES completion:nil];
                                                      }];
    
    UIAlertAction *manual = [UIAlertAction actionWithTitle:@"Manual"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       self.trackerMode = kIQTrackerModeManual;
                                                       self.modeLabel.text = @"mode: manual (all)";
                                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alertController addAction:automatic];
    [alertController addAction:manual];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)startTracker
{
    __weak __typeof(self) welf = self;
    IQMotionActivityType activity = kIQMotionActivityTypeNone;
    if (self.trackerMode == kIQTrackerModeAutomatic) {
        activity = kIQMotionActivityTypeAutomotive;
    }
    
    [[IQTracker sharedManager] startLIVETrackerForActivity:activity
                                                  userInfo:@{@"testing":@"holaaa"}
                                                  progress:^(IQTrackPoint * _Nullable p, IQLocationResult locationResult, IQMotionActivityResult motionResult) {
                                                      if (p) {
                                                          NSMutableArray *temp = welf.tracks.mutableCopy;
                                                          if (!temp) {
                                                              temp = [NSMutableArray array];
                                                          }
                                                          [temp addObject:p];
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              welf.tracks = temp.copy;
                                                              [self.tableView reloadData];
                                                          });
                                                      } else {
                                                          
                                                      }
                                                  } completion:^(IQTrack * _Nullable t, IQLocationResult locationResult, IQMotionActivityResult motionResult) {
                                                      if (t) {
                                                          NSString *title = [NSString stringWithFormat:@"Track Ended: %@", t.activityType];
                                                          NSString *dates = [NSString stringWithFormat:@"from: %@\nto: %@",
                                                                             [NSDateFormatter localizedStringFromDate:t.start_date
                                                                                                            dateStyle:NSDateFormatterShortStyle
                                                                                                            timeStyle:NSDateFormatterShortStyle],
                                                                             [NSDateFormatter localizedStringFromDate:t.end_date
                                                                                                            dateStyle:NSDateFormatterShortStyle
                                                                                                            timeStyle:NSDateFormatterShortStyle]];
                                                          UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                                                                   message:dates
                                                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                                          UIAlertAction* aceptar = [UIAlertAction actionWithTitle:@"Aceptar"
                                                                                                            style:UIAlertActionStyleDefault
                                                                                                          handler:^(UIAlertAction * action) {
                                                                                                              [alertController dismissViewControllerAnimated:YES
                                                                                                                                                  completion:nil];
                                                                                                          }];
                                                          [alertController addAction:aceptar];
                                                          [welf presentViewController:alertController animated:YES completion:nil];
                                                          
                                                      } else {
                                                          
                                                          NSString *message = [NSString stringWithFormat:@"location result = %li\nmotion result = %li", (long)locationResult, (long)motionResult];
                                                          
                                                          UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Track Ended"
                                                                                                                                   message:message
                                                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                                          UIAlertAction* aceptar = [UIAlertAction actionWithTitle:@"Aceptar"
                                                                                                            style:UIAlertActionStyleDefault
                                                                                                          handler:^(UIAlertAction * action) {
                                                                                                              [alertController dismissViewControllerAnimated:YES
                                                                                                                                                  completion:nil];
                                                                                                          }];
                                                          [alertController addAction:aceptar];
                                                          [welf presentViewController:alertController animated:YES completion:nil];
                                                          
                                                      }
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          welf.tracks = [NSArray array];
                                                          [self.tableView reloadData];
                                                      });
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
    return @"TrackPoints";
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
    
    IQTrackPoint *t = self.tracks[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%li. %@ %@",
                           t.order.integerValue,
                           [t activityTypeString],
                           [NSDateFormatter localizedStringFromDate:t.date
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, lat: %f - lon: %f",
                                 [t confidenceString],
                                 t.latitude.doubleValue,
                                 t.longitude.doubleValue];
    
    return cell;
}

#pragma mark MFMailComposeViewControllerDelegate Methods
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
