//
//  IQTrackerContainerVC.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 21/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQTrackerContainerVC.h"

#import "IQTrackerVC.h"
#import "IQTrackerMapVC.h"

@interface IQTrackerContainerVC ()

@property (weak, nonatomic) IBOutlet UIView *containerMap;
@property (weak, nonatomic) IBOutlet UIView *containerTable;

@end

@implementation IQTrackerContainerVC

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

- (IBAction)changeView:(UIBarButtonItem *)sender
{
    if (self.containerMap.hidden == YES) {
        self.containerMap.hidden = NO;
        self.containerTable.hidden = YES;
        [[self mapViewController] addTracks:[self tableViewController].tracks];
        
    } else if (self.containerTable.hidden == YES) {
        self.containerTable.hidden = NO;
        self.containerMap.hidden = YES;
        
    }
}

- (IBAction)changeTrackerMode:(id)sender
{
    [[self tableViewController] showActionSheet];
}

- (IQTrackerMapVC *)mapViewController {
    IQTrackerMapVC *vc;
    for (IQTrackerMapVC *const candidate in self.childViewControllers) {
        if ([candidate isKindOfClass:IQTrackerMapVC.class]) {
            vc = candidate;
            break;
        }
    }
    NSAssert(vc, @"IQTrackerMapVC view controller not found");
    return vc;
}

- (IQTrackerVC *)tableViewController {
    IQTrackerVC *vc;
    for (IQTrackerVC *const candidate in self.childViewControllers) {
        if ([candidate isKindOfClass:IQTrackerVC.class]) {
            vc = candidate;
            break;
        }
    }
    NSAssert(vc, @"IQTrackerVC view controller not found");
    return vc;
}

@end
