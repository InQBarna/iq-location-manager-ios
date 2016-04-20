//
//  IQSignificantContainerVC.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 20/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQSignificantContainerVC.h"

#import "IQSignificantLocationVC.h"
#import "IQSignificantMapVC.h"

@interface IQSignificantContainerVC ()

@property (weak, nonatomic) IBOutlet UIView *containerMap;
@property (weak, nonatomic) IBOutlet UIView *containerTable;

@end

@implementation IQSignificantContainerVC

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
        [[self mapViewController] addLocations:[self tableViewController].locations];
        
    } else if (self.containerTable.hidden == YES) {
        self.containerTable.hidden = NO;
        self.containerMap.hidden = YES;
        
    }
}

- (IQSignificantMapVC *)mapViewController {
    IQSignificantMapVC *vc;
    for (IQSignificantMapVC *const candidate in self.childViewControllers) {
        if ([candidate isKindOfClass:IQSignificantMapVC.class]) {
            vc = candidate;
            break;
        }
    }
    NSAssert(vc, @"IQSignificantMapVC view controller not found");
    return vc;
}

- (IQSignificantLocationVC *)tableViewController {
    IQSignificantLocationVC *vc;
    for (IQSignificantLocationVC *const candidate in self.childViewControllers) {
        if ([candidate isKindOfClass:IQSignificantLocationVC.class]) {
            vc = candidate;
            break;
        }
    }
    NSAssert(vc, @"IQSignificantLocationVC view controller not found");
    return vc;
}

@end
