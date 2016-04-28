//
//  IQTrackListVC.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 22/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTrackListVC.h"

#import "Track.h"
#import "IQTracker.h"
#import <CoreData/CoreData.h>
#import "IQTrackMapVC.h"

@interface IQTrackListVC ()

@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (strong, nonatomic) NSArray               *tracks;

@end

@implementation IQTrackListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.tracks = [[IQTracker sharedManager] getCompletedTracks].copy;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteModel:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete all tracks"
                                                                             message:@"This action will stop the current track and will delete it with the rest of the tracks."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* aceptar = [UIAlertAction actionWithTitle:@"Aceptar"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        [[IQTracker sharedManager] deleteTracks];
                                                        self.tracks = [NSArray array];
                                                        [self.tableView reloadData];
                                                        [alertController dismissViewControllerAnimated:YES
                                                                                            completion:nil];
                                                    }];
    
    UIAlertAction* cancelar = [UIAlertAction actionWithTitle:@"Cancelar"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alertController dismissViewControllerAnimated:YES
                                                                                             completion:nil];
                                                     }];
    
    [alertController addAction:aceptar];
    [alertController addAction:cancelar];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMap"] && [sender isKindOfClass:[Track class]]) {
        IQTrackMapVC *vc = (IQTrackMapVC *)segue.destinationViewController;
        [vc configureWithTrack:(Track *)sender];
    }
}

#pragma mark UITableView DataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"trackIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Track *t = self.tracks[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %2.f meters",
                           t.activityType,
                           t.distance.floatValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@ - Points: %lu",
                                 [NSDateFormatter localizedStringFromDate:t.start_date
                                                                dateStyle:NSDateFormatterShortStyle
                                                                timeStyle:NSDateFormatterShortStyle],
                                 [NSDateFormatter localizedStringFromDate:t.end_date
                                                                dateStyle:NSDateFormatterShortStyle
                                                                timeStyle:NSDateFormatterShortStyle],
                                 (unsigned long)t.points.count];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQTrack *t = self.tracks[indexPath.row];
    [self performSegueWithIdentifier:@"showMap" sender:t];
}

@end
