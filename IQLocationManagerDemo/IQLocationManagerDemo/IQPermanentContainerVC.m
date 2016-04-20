//
//  IQPermanentContainerVC.m
//  IQLocationManagerDemo
//
//  Created by Raul Peña on 20/04/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "IQPermanentContainerVC.h"

#import "IQPermanentLocationVC.h"
#import "IQPermanentMapVC.h"

@interface IQPermanentContainerVC ()

@property (weak, nonatomic) IBOutlet UIView *containerMap;
@property (weak, nonatomic) IBOutlet UIView *containerTable;

@end

@implementation IQPermanentContainerVC

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

- (IQPermanentMapVC *)mapViewController {
    IQPermanentMapVC *vc;
    for (IQPermanentMapVC *const candidate in self.childViewControllers) {
        if ([candidate isKindOfClass:IQPermanentMapVC.class]) {
            vc = candidate;
            break;
        }
    }
    NSAssert(vc, @"IQPermanentMapVC view controller not found");
    return vc;
}

- (IQPermanentLocationVC *)tableViewController {
    IQPermanentLocationVC *vc;
    for (IQPermanentLocationVC *const candidate in self.childViewControllers) {
        if ([candidate isKindOfClass:IQPermanentLocationVC.class]) {
            vc = candidate;
            break;
        }
    }
    NSAssert(vc, @"IQPermanentLocationVC view controller not found");
    return vc;
}

@end
