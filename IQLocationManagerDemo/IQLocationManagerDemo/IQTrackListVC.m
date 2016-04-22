//
//  IQTrackListVC.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 22/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTrackListVC.h"

#import "IQTrack.h"
#import "IQLocationDataSource.h"
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
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"IQTrack"];
    NSError *error = nil;
    self.tracks = [[IQLocationDataSource sharedDataSource].managedObjectContext executeFetchRequest:request error:&error].copy;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showMap"] && [sender isKindOfClass:[NSManagedObjectID class]]) {
        IQTrackMapVC *vc = (IQTrackMapVC *)segue.destinationViewController;
        [vc configureWithTrackID:(NSManagedObjectID *)sender];
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
    
    IQTrack *t = self.tracks[indexPath.row];
    cell.textLabel.text = t.activityType;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@ - Points: %lu",
                                 [NSDateFormatter localizedStringFromDate:t.start_date
                                                                dateStyle:NSDateFormatterShortStyle
                                                                timeStyle:NSDateFormatterShortStyle],
                                 [NSDateFormatter localizedStringFromDate:t.end_date
                                                                dateStyle:NSDateFormatterShortStyle
                                                                timeStyle:NSDateFormatterShortStyle],
                                 [t.points allObjects].count];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQTrack *t = self.tracks[indexPath.row];
    [self performSegueWithIdentifier:@"showMap" sender:t.objectID];
}

@end
